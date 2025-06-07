// src/admin/js/register.js

console.log("register.js loaded");

const registerForm = document.getElementById('register-form');
const registerError = document.getElementById('register-error');

registerForm.addEventListener('submit', async (e) => {
  e.preventDefault();
  registerError.textContent = '';

  const email = document.getElementById('email').value.trim();
  const password = document.getElementById('password').value;
  const full_name = document.getElementById('full_name').value.trim();
  const phone = document.getElementById('phone').value.trim();

  if (!email || !password || !full_name || !phone) {
    registerError.textContent = 'All fields are required.';
    return;
  }
  if (password.length < 6) {
    registerError.textContent = 'Password must be at least 6 characters.';
    return;
  }

  try {
    const resp = await fetch('/api/auth/register', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        email,
        password,
        full_name,
        phone,
        role: 'admin',
        fcm_token: null
      })
    });

    if (!resp.ok) {
      const errData = await resp.json();
      throw new Error(errData.message || 'Registration failed');
    }

    alert('Admin registered successfully! Please log in.');
    window.location.href = 'login.html';
  } catch (error) {
    console.error('Admin register error:', error);
    registerError.textContent = error.message || 'Registration failed';
  }
});
