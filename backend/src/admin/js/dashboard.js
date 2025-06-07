// src/admin/js/dashboard.js

console.log("🛠 dashboard.js loaded");

(async function () {
  const token = localStorage.getItem('admin_jwt');

  if (!token) {
    window.location.href = 'login.html';
    return;
  }

  async function authFetch(url, options = {}) {
    options.headers = options.headers || {};
    options.headers['Content-Type'] = 'application/json';
    options.headers['Authorization'] = 'Bearer ' + token;

    const r = await fetch(url, options);

    if (r.status === 401 || r.status === 403) {
      localStorage.removeItem('admin_jwt');
      window.location.href = 'login.html';
      return;
    }
    return r;
  }

  document.getElementById('logout-button').addEventListener('click', () => {
    localStorage.removeItem('admin_jwt');
    window.location.href = 'login.html';
  });

  try {
    const meResp = await authFetch('/api/auth/me', { method: 'GET' });
    if (!meResp.ok) {
      throw new Error('Failed to fetch your profile');
    }
    const { user } = await meResp.json();
    document.getElementById('welcome-msg').textContent =
      `Hello, ${user.full_name || user.email}! (Role: ${user.role})`;
  } catch (err) {
    document.getElementById('welcome-msg').textContent = 'Hello, Admin!';
  }

  async function loadUsers() {
    const tbody = document.querySelector('#users-table tbody');
    tbody.innerHTML = '';
    document.getElementById('table-error').textContent = '';

    try {
      const resp = await authFetch('/api/admin/users', { method: 'GET' });
      if (!resp) {
        return;
      }
      if (!resp.ok) {
        const e = await resp.json();
        throw new Error(e.message || 'Failed to load users');
      }

      const { users } = await resp.json();

      users.forEach((user) => {
        const tr = document.createElement('tr');

        const tdId = document.createElement('td');
        tdId.textContent = user.user_id;
        tr.appendChild(tdId);

        const tdEmail = document.createElement('td');
        tdEmail.textContent = user.email;
        tr.appendChild(tdEmail);

        const tdName = document.createElement('td');
        tdName.textContent = user.full_name || '—';
        tr.appendChild(tdName);

        const tdRole = document.createElement('td');
        tdRole.textContent = user.role;
        tr.appendChild(tdRole);

        const tdVerified = document.createElement('td');
        if (user.role === 'specialist') {
          const isVerified = user.specialistProfile?.verified === true;
          const btn = document.createElement('button');
          btn.classList.add('verify-toggle', isVerified ? 'verified' : 'not-verified');
          btn.textContent = isVerified ? '✔ Verified' : '✖ Not Verified';
          btn.addEventListener('click', async () => {
            const newVerified = !isVerified;
            await updateUserField(user.user_id, { verified: newVerified });
          });
          tdVerified.appendChild(btn);
        } else {
          tdVerified.textContent = '—';
        }
        tr.appendChild(tdVerified);

        const tdSubsidy = document.createElement('td');

        if (user.role === 'client') {
          const container = document.createElement('div');
          container.classList.add('subsidy-cell');

          const currentPct = user.subsidy !== null ? user.subsidy : 0;
          const input = document.createElement('input');
          input.type = 'number';
          input.value = currentPct;
          input.classList.add('subsidy-input');
          input.min = '0';

          const checkbox = document.createElement('input');
          checkbox.type = 'checkbox';
          checkbox.checked = user.subsidy_active === true;

          const label = document.createElement('label');
          label.classList.add('subsidy-label');
          label.textContent = 'Active';

          const saveBtn = document.createElement('button');
          saveBtn.textContent = 'Save';
          saveBtn.classList.add('subsidy-save');
          saveBtn.addEventListener('click', async () => {
            const amt = parseFloat(input.value) || 0;
            const isActive = checkbox.checked;
            await updateUserField(user.user_id, {
              subsidy: amt,
              active: isActive
            });
          });

          container.appendChild(input);
          container.appendChild(checkbox);
          container.appendChild(label);
          container.appendChild(saveBtn);

          tdSubsidy.appendChild(container);
        } else {
          tdSubsidy.textContent = '—';
        }

        tr.appendChild(tdSubsidy);

        const tdActions = document.createElement('td');
        tdActions.innerHTML = '—';
        tr.appendChild(tdActions);

        tbody.appendChild(tr);
      });
    } catch (error) {
      document.getElementById('table-error').textContent =
        error.message || 'Failed to load users';
    }
  }

  await loadUsers();

  async function updateUserField(userId, fields) {
    try {
      const resp = await authFetch(`/api/admin/users/${userId}`, {
        method: 'PUT',
        body: JSON.stringify(fields)
      });
      if (!resp.ok) {
        const err = await resp.json();
        throw new Error(err.message || 'Update failed');
      }
      await loadUsers();
      applySearchFilter();
    } catch (error) {
      alert('Update failed: ' + (error.message || ''));
    }
  }

  const searchInput = document.getElementById('search-input');
  searchInput.addEventListener('input', applySearchFilter);

  function applySearchFilter() {
    const filterValue = searchInput.value.trim().toLowerCase();
    const rows = document.querySelectorAll('#users-table tbody tr');
    rows.forEach(row => {
      const text = row.textContent.trim().toLowerCase();
      row.style.display = text.includes(filterValue) ? '' : 'none';
    });
  }
})();
