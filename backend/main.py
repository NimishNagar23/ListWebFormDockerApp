import os
import time
import boto3
import psycopg2
from fastapi import FastAPI, UploadFile, Form, HTTPException, File
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from typing import List, Optional
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = FastAPI()

# CORS Configuration
# Allow all origins for simplicity in development/verification as requested
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Configuration from Environment Variables
AWS_ACCESS_KEY_ID = os.getenv("AWS_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")
AWS_REGION = os.getenv("AWS_REGION", "us-east-1")
S3_BUCKET_NAME = os.getenv("S3_BUCKET_NAME")
DATABASE_URL = os.getenv("DATABASE_URL")

# S3 Client
s3_client = boto3.client(
    "s3",
    aws_access_key_id=AWS_ACCESS_KEY_ID,
    aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
    region_name=AWS_REGION,
)

# Database Connection Helper
def get_db_connection():
    try:
        conn = psycopg2.connect(DATABASE_URL)
        return conn
    except Exception as e:
        print(f"Database connection error: {e}")
        raise HTTPException(status_code=500, detail="Database connection failed")

# Initialize Database Table
@app.on_event("startup")
def startup_event():
    if not DATABASE_URL:
        print("WARNING: DATABASE_URL is not set.")
        return
        
    retries = 5
    while retries > 0:
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            break
        except Exception as e:
            retries -= 1
            print(f"Database connection failed, retrying in 5s... ({retries} retries left)")
            time.sleep(5)
    
    if retries == 0:
        print("Could not connect to database after retries.")
        return

    try:
        cur.execute("""
            CREATE TABLE IF NOT EXISTS users (
                id SERIAL PRIMARY KEY,
                username VARCHAR(100) NOT NULL,
                email VARCHAR(255) NOT NULL,
                password VARCHAR(255) NOT NULL,
                bio TEXT,
                image_url TEXT
            );
        """)
        conn.commit()
        cur.close()
        conn.close()
        print("Database initialized successfully.")
    except Exception as e:
        print(f"Initialization error: {e}")

# Routes

@app.get("/")
def read_root():
    return {"message": "User Directory API is running"}

@app.get("/users")
def get_users():
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        cur.execute("SELECT username, email, bio, image_url FROM users ORDER BY id DESC")
        rows = cur.fetchall()
        
        users = []
        for row in rows:
            users.append({
                "username": row[0],
                "email": row[1],
                "bio": row[2],
                "image_url": row[3]
            })
        return users
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cur.close()
        conn.close()

@app.post("/users")
async def create_user(
    username: str = Form(...),
    email: str = Form(...),
    password: str = Form(...),
    bio: Optional[str] = Form(None),
    profile_image: UploadFile = File(...)
):
    # 1. Upload Image to S3
    try:
        file_extension = profile_image.filename.split(".")[-1]
        file_key = f"{username}_{profile_image.filename}"
        
        s3_client.upload_fileobj(
            profile_image.file,
            S3_BUCKET_NAME,
            file_key,
            ExtraArgs={"ContentType": profile_image.content_type} # ACL='public-read' requires bucket settings, relying on URL construction or bucket policy usually. 
        )
        
        # Construct URL (assuming standard public bucket or presigned URL needed? 
        # Req said "Image files must be uploaded... database must store only the S3 image URL")
        # Generating standard public URL format:
        image_url = f"https://{S3_BUCKET_NAME}.s3.{AWS_REGION}.amazonaws.com/{file_key}"
        
    except Exception as e:
        print(f"S3 Upload Error: {e}")
        raise HTTPException(status_code=500, detail=f"Image upload failed: {str(e)}")

    # 2. Insert into PostgreSQL
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        query = """
            INSERT INTO users (username, email, password, bio, image_url)
            VALUES (%s, %s, %s, %s, %s)
            RETURNING id;
        """
        cur.execute(query, (username, email, password, bio, image_url))
        new_user_id = cur.fetchone()[0]
        conn.commit()
        cur.close()
        conn.close()
        
        return {
            "id": new_user_id,
            "username": username,
            "image_url": image_url,
            "message": "User created successfully"
        }
        
    except Exception as e:
        print(f"Database Insert Error: {e}")
        raise HTTPException(status_code=500, detail=f"Database insertion failed: {str(e)}")
