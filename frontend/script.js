
// Constants
const API_BASE_URL = ''; // Relative path for ALB routing

document.addEventListener('DOMContentLoaded', () => {
    const userForm = document.getElementById('userForm');
    const submitBtn = document.getElementById('submitBtn');
    const userList = document.getElementById('userList');
    const refreshBtn = document.getElementById('refreshBtn');

    // Handle Form Submission
    userForm.addEventListener('submit', async (e) => {
        e.preventDefault();

        // Reset errors (if any were implemented)
        submitBtn.disabled = true;
        const originalBtnText = submitBtn.innerHTML;
        submitBtn.innerHTML = '<span>Creating...</span>';

        try {
            const formData = new FormData(userForm);

            // Log for debugging
            for (let [key, value] of formData.entries()) {
                console.log(`${key}:`, value);
            }

            const response = await fetch(`${API_BASE_URL}/users`, {
                method: 'POST',
                body: formData // allow browser to set Content-Type header with boundary
            });

            if (!response.ok) {
                throw new Error(`Error: ${response.statusText}`);
            }

            const result = await response.json();
            console.log('User created:', result);

            // Success
            userForm.reset();
            alert('User created successfully!');
            fetchUsers(); // Refresh the list

        } catch (error) {
            console.error('Submission failed:', error);
            alert('Failed to create user. See console for details.');
        } finally {
            submitBtn.disabled = false;
            submitBtn.innerHTML = originalBtnText;
        }
    });

    // Handle Refresh
    refreshBtn.addEventListener('click', fetchUsers);

    // Fetch and Render Users
    async function fetchUsers() {
        userList.innerHTML = '<div class="loading-state">Loading users...</div>';

        try {
            const response = await fetch(`${API_BASE_URL}/users`);
            if (!response.ok) throw new Error('Failed to fetch users');

            const users = await response.json();
            renderUsers(users);

        } catch (error) {
            console.error('Fetch error:', error);
            userList.innerHTML = `
                <div class="error-state">
                    <p>Failed to load users.</p>
                    <button onclick="location.reload()" class="btn btn-sm btn-secondary" style="margin-top: 10px">Retry</button>
                </div>
            `;
        }
    }

    function renderUsers(users) {
        if (!users || users.length === 0) {
            userList.innerHTML = '<div class="empty-state">No users found. Be the first to join!</div>';
            return;
        }

        userList.innerHTML = users.map(user => createUserCard(user)).join('');
    }

    function createUserCard(user) {
        // Fallback or validation for image URL
        const imageUrl = user.image_url || 'https://via.placeholder.com/80?text=User';
        const bio = user.bio || 'No bio provided.';

        // Sanitize inputs to basic extent (innerText would be safer in React/Vue, here we template literal carefully)
        // ideally we'd use textContent assignment for safety, but innerHTML is requested for dynamic injection simplicity

        return `
            <div class="card user-card">
                <img src="${imageUrl}" alt="${user.username}" class="user-avatar" loading="lazy">
                <div class="user-info">
                    <h3 class="user-name">${escapeHtml(user.username)}</h3>
                    <p class="user-email">${escapeHtml(user.email)}</p>
                    <p class="user-bio">${escapeHtml(bio)}</p>
                </div>
            </div>
        `;
    }

    // Basic XSS prevention helper
    function escapeHtml(text) {
        if (!text) return '';
        return text
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");
    }

    // Initial Load
    // Note: This will fail until backend is running, which is expected
    fetchUsers();
});
