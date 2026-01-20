const API_URL = 'http://4.240.103.27:30005/api/users';
const NOTE_API_URL = 'http://4.240.103.27:30006/api/notes';

export async function login(usernameOrEmail, password) {
  const res = await fetch(`${API_URL}/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ usernameOrEmail, password }),
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(text || 'Đăng nhập thất bại');
  }
  return res.json();
}

export async function register(payload) {
  const res = await fetch(API_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(text || 'Đăng ký thất bại');
  }
  return res.json();
}

export async function fetchProfile(id) {
  const res = await fetch(`${API_URL}/${id}`);
  if (!res.ok) {
    const text = await res.text();
    throw new Error(text || 'Không lấy được thông tin tài khoản');
  }
  return res.json();
}

// Note API functions
export async function fetchNotesByUserId(userId) {
  const res = await fetch(`${NOTE_API_URL}/user/${userId}`);
  if (!res.ok) {
    throw new Error('Không thể tải danh sách ghi chú');
  }
  return res.json();
}

export async function createNote(userId, title, content) {
  const res = await fetch(NOTE_API_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ userId, title, content }),
  });
  if (!res.ok) {
    throw new Error('Không thể tạo ghi chú');
  }
  return res.json();
}

export async function updateNote(id, title, content) {
  const res = await fetch(`${NOTE_API_URL}/${id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ title, content }),
  });
  if (!res.ok) {
    throw new Error('Không thể cập nhật ghi chú');
  }
  return res.json();
}

export async function deleteNote(id) {
  const res = await fetch(`${NOTE_API_URL}/${id}`, {
    method: 'DELETE',
  });
  if (!res.ok) {
    throw new Error('Không thể xóa ghi chú');
  }
  return res.json();
}
