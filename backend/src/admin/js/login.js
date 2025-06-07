// src/admin/js/login.js

const loginForm = document.getElementById('login-form');
const loginError = document.getElementById('login-error');

loginForm.addEventListener('submit', async (e) => {
  e.preventDefault();
  loginError.textContent = '';

  const email = document.getElementById('email').value.trim();
  const password = document.getElementById('password').value;

  try {
    const userCredential = await firebase.auth().signInWithEmailAndPassword(email, password);
    const idToken = await userCredential.user.getIdToken();
    const resp = await fetch('/api/auth/login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ token: idToken })
    });

    if (!resp.ok) {
      const err = await resp.json();
      throw new Error(err.message || 'Login failed');
    }

    await resp.json();
    localStorage.setItem('admin_jwt', idToken);

    window.location.href = 'dashboard.html';
  } catch (error) {
    console.error('Admin login error:', error);
    loginError.textContent = error.message || 'Login failed';
  }
});
