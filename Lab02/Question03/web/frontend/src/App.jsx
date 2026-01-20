import { useEffect, useState } from 'react';
import { login, register, fetchProfile, fetchNotesByUserId, createNote, updateNote, deleteNote } from './api';

function App() {
  const [mode, setMode] = useState('login');
  const [authUser, setAuthUser] = useState(null);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState(null);
  const [tab, setTab] = useState('note');

  const [loginForm, setLoginForm] = useState({ usernameOrEmail: '', password: '' });
  const [registerForm, setRegisterForm] = useState({
    username: '',
    email: '',
    password: '',
    fullName: '',
    phone: '',
    address: '',
    role: 'USER',
  });

  // Notes state
  const [notes, setNotes] = useState([]);
  const [noteForm, setNoteForm] = useState({ title: '', content: '' });
  const [editingNoteId, setEditingNoteId] = useState(null);

  useEffect(() => {
    const stored = localStorage.getItem('authUser');
    if (stored) {
      const user = JSON.parse(stored);
      setAuthUser(user);
      loadUserNotes(user.id);
    }
  }, []);

  const loadUserNotes = async (userId) => {
    try {
      const userNotes = await fetchNotesByUserId(userId);
      setNotes(userNotes);
    } catch (err) {
      console.error('Error loading notes:', err);
      setMessage({ type: 'error', text: 'Không thể tải ghi chú' });
    }
  };

  const handleLogin = async (e) => {
    e.preventDefault();
    setLoading(true);
    setMessage(null);
    try {
      const user = await login(loginForm.usernameOrEmail, loginForm.password);
      setAuthUser(user);
      localStorage.setItem('authUser', JSON.stringify(user));
      await loadUserNotes(user.id);
      setMessage({ type: 'success', text: 'Đăng nhập thành công' });
      setTab('note');
    } catch (err) {
      setMessage({ type: 'error', text: err.message });
    } finally {
      setLoading(false);
    }
  };

  const handleRegister = async (e) => {
    e.preventDefault();
    setLoading(true);
    setMessage(null);
    try {
      await register({ ...registerForm, role: registerForm.role || 'USER' });
      setMessage({ type: 'success', text: 'Đăng ký thành công. Vui lòng đăng nhập.' });
      setMode('login');
      setLoginForm({ usernameOrEmail: registerForm.username || registerForm.email, password: '' });
      setTab('note');
    } catch (err) {
      setMessage({ type: 'error', text: err.message });
    } finally {
      setLoading(false);
    }
  };

  const refreshProfile = async () => {
    if (!authUser) return;
    try {
      const user = await fetchProfile(authUser.id);
      setAuthUser(user);
      localStorage.setItem('authUser', JSON.stringify(user));
      setMessage({ type: 'success', text: 'Đã tải lại thông tin tài khoản' });
    } catch (err) {
      setMessage({ type: 'error', text: err.message });
    }
  };

  const logout = () => {
    setAuthUser(null);
    setNotes([]);
    localStorage.removeItem('authUser');
    setMessage({ type: 'success', text: 'Đã đăng xuất' });
    setTab('note');
  };

  // Note functions
  const handleAddNote = async (e) => {
    e.preventDefault();
    if (!noteForm.title.trim() || !noteForm.content.trim()) {
      setMessage({ type: 'error', text: 'Tiêu đề và nội dung không được trống' });
      return;
    }

    setLoading(true);
    try {
      if (editingNoteId) {
        const updatedNote = await updateNote(editingNoteId, noteForm.title, noteForm.content);
        const updatedNotes = notes.map(note =>
          note.id === editingNoteId ? updatedNote : note
        );
        setNotes(updatedNotes);
        setMessage({ type: 'success', text: 'Cập nhật ghi chú thành công' });
        setEditingNoteId(null);
      } else {
        const newNote = await createNote(authUser.id, noteForm.title, noteForm.content);
        setNotes([newNote, ...notes]);
        setMessage({ type: 'success', text: 'Thêm ghi chú thành công' });
      }
      setNoteForm({ title: '', content: '' });
    } catch (err) {
      setMessage({ type: 'error', text: err.message });
    } finally {
      setLoading(false);
    }
  };

  const handleEditNote = (note) => {
    setNoteForm({ title: note.title, content: note.content });
    setEditingNoteId(note.id);
  };

  const handleDeleteNote = async (id) => {
    if (!confirm('Bạn có chắc muốn xóa ghi chú này?')) return;
    
    setLoading(true);
    try {
      await deleteNote(id);
      const updatedNotes = notes.filter(note => note.id !== id);
      setNotes(updatedNotes);
      setMessage({ type: 'success', text: 'Xóa ghi chú thành công' });
    } catch (err) {
      setMessage({ type: 'error', text: err.message });
    } finally {
      setLoading(false);
    }
  };

  const handleCancelEdit = () => {
    setNoteForm({ title: '', content: '' });
    setEditingNoteId(null);
  };

  return (
    <div className="page">
      <header className="hero">
        <div>
          <p className="eyebrow">User Service</p>
          <h1>Quản lý tài khoản</h1>
          <p className="sub">Đăng nhập, đăng ký và xem thông tin tài khoản.</p>
        </div>
      </header>

      <main className="grid">
        {!authUser && (
          <section className="card">
            <div className="tabs">
              <button
                className={mode === 'login' ? 'tab active' : 'tab'}
                onClick={() => setMode('login')}
              >
                Đăng nhập
              </button>
              <button
                className={mode === 'register' ? 'tab active' : 'tab'}
                onClick={() => setMode('register')}
              >
                Đăng ký
              </button>
            </div>

            {message && (
              <div className={`alert ${message.type}`}>
                {message.text}
              </div>
            )}

            {mode === 'login' ? (
              <form className="form" onSubmit={handleLogin}>
                <label>
                  Tên đăng nhập / Email
                  <input
                    type="text"
                    required
                    value={loginForm.usernameOrEmail}
                    onChange={(e) => setLoginForm({ ...loginForm, usernameOrEmail: e.target.value })}
                    placeholder="username hoặc email"
                  />
                </label>
                <label>
                  Mật khẩu
                  <input
                    type="password"
                    required
                    value={loginForm.password}
                    onChange={(e) => setLoginForm({ ...loginForm, password: e.target.value })}
                    placeholder="••••••••"
                  />
                </label>
                <button className="btn primary" type="submit" disabled={loading}>
                  {loading ? 'Đang xử lý...' : 'Đăng nhập'}
                </button>
              </form>
            ) : (
              <form className="form" onSubmit={handleRegister}>
                <div className="two-cols">
                  <label>
                    Username
                    <input
                      type="text"
                      required
                      value={registerForm.username}
                      onChange={(e) => setRegisterForm({ ...registerForm, username: e.target.value })}
                    />
                  </label>
                  <label>
                    Email
                    <input
                      type="email"
                      required
                      value={registerForm.email}
                      onChange={(e) => setRegisterForm({ ...registerForm, email: e.target.value })}
                    />
                  </label>
                </div>
                <label>
                  Mật khẩu
                  <input
                    type="password"
                    required
                    value={registerForm.password}
                    onChange={(e) => setRegisterForm({ ...registerForm, password: e.target.value })}
                  />
                </label>
                <label>
                  Họ tên
                  <input
                    type="text"
                    required
                    value={registerForm.fullName}
                    onChange={(e) => setRegisterForm({ ...registerForm, fullName: e.target.value })}
                  />
                </label>
                <div className="two-cols">
                  <label>
                    Số điện thoại
                    <input
                      type="text"
                      value={registerForm.phone}
                      onChange={(e) => setRegisterForm({ ...registerForm, phone: e.target.value })}
                    />
                  </label>
                  <label>
                    Role
                    <select
                      value={registerForm.role}
                      onChange={(e) => setRegisterForm({ ...registerForm, role: e.target.value })}
                    >
                      <option value="USER">USER</option>
                      <option value="ADMIN">ADMIN</option>
                    </select>
                  </label>
                </div>
                <label>
                  Địa chỉ
                  <input
                    type="text"
                    value={registerForm.address}
                    onChange={(e) => setRegisterForm({ ...registerForm, address: e.target.value })}
                  />
                </label>
                <button className="btn primary" type="submit" disabled={loading}>
                  {loading ? 'Đang xử lý...' : 'Đăng ký'}
                </button>
              </form>
            )}
          </section>
        )}

        {authUser && (
          <section className="card secondary">
            <div className="tabs three">
              <button className={tab === 'note' ? 'tab active' : 'tab'} onClick={() => setTab('note')}>
                Ghi chú
              </button>
              <button className={tab === 'account' ? 'tab active' : 'tab'} onClick={() => setTab('account')}>
                Thông tin tài khoản
              </button>
            </div>

            {message && (
              <div className={`alert ${message.type}`}>
                {message.text}
              </div>
            )}

            {tab === 'note' && (
              <div>
                <form className="form" onSubmit={handleAddNote}>
                  <label>
                    Tiêu đề
                    <input
                      type="text"
                      value={noteForm.title}
                      onChange={(e) => setNoteForm({ ...noteForm, title: e.target.value })}
                      placeholder="Nhập tiêu đề ghi chú..."
                      required
                    />
                  </label>
                  <label>
                    Nội dung
                    <textarea
                      value={noteForm.content}
                      onChange={(e) => setNoteForm({ ...noteForm, content: e.target.value })}
                      placeholder="Nhập nội dung ghi chú..."
                      rows="4"
                      style={{
                        width: '100%',
                        padding: '12px',
                        border: '2px solid #1f2937',
                        borderRadius: '10px',
                        background: '#0f172a',
                        color: '#e5e7eb',
                        fontSize: '15px',
                        fontFamily: 'inherit',
                        resize: 'vertical'
                      }}
                      required
                    />
                  </label>
                  <div className="actions inline">
                    <button className="btn primary" type="submit">
                      {editingNoteId ? 'Cập nhật' : 'Thêm ghi chú'}
                    </button>
                    {editingNoteId && (
                      <button className="btn ghost" type="button" onClick={handleCancelEdit}>
                        Hủy
                      </button>
                    )}
                    <button className="btn danger" type="button" onClick={logout}>
                      Đăng xuất
                    </button>
                  </div>
                </form>

                <div style={{ marginTop: '20px' }}>
                  <h3 style={{ marginBottom: '12px' }}>Danh sách ghi chú ({notes.length})</h3>
                  {notes.length === 0 ? (
                    <div className="placeholder">
                      <p className="muted">Chưa có ghi chú nào. Hãy tạo ghi chú đầu tiên!</p>
                    </div>
                  ) : (
                    <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                      {notes.map(note => (
                        <div
                          key={note.id}
                          style={{
                            background: '#0f172a',
                            padding: '16px',
                            borderRadius: '12px',
                            border: '1px solid #1f2937'
                          }}
                        >
                          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'start', marginBottom: '8px' }}>
                            <h4 style={{ margin: 0, color: '#e5e7eb' }}>{note.title}</h4>
                            <div style={{ display: 'flex', gap: '8px' }}>
                              <button
                                className="btn ghost"
                                style={{ padding: '6px 12px', fontSize: '14px' }}
                                onClick={() => handleEditNote(note)}
                              >
                                Sửa
                              </button>
                              <button
                                className="btn danger"
                                style={{ padding: '6px 12px', fontSize: '14px' }}
                                onClick={() => handleDeleteNote(note.id)}
                              >
                                Xóa
                              </button>
                            </div>
                          </div>
                          <p style={{ margin: '8px 0', color: '#9ca3af', whiteSpace: 'pre-wrap' }}>
                            {note.content}
                          </p>
                          <p style={{ margin: 0, fontSize: '12px', color: '#6b7280' }}>
                            Cập nhật: {new Date(note.updatedAt).toLocaleString('vi-VN')}
                          </p>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              </div>
            )}

            {tab === 'account' && (
              <div className="profile">
                <div className="profile-row">
                  <span>Họ tên</span>
                  <strong>{authUser.fullName}</strong>
                </div>
                <div className="profile-row">
                  <span>Username</span>
                  <strong>{authUser.username}</strong>
                </div>
                <div className="profile-row">
                  <span>Email</span>
                  <strong>{authUser.email}</strong>
                </div>
                <div className="profile-row">
                  <span>Điện thoại</span>
                  <strong>{authUser.phone || '-'}</strong>
                </div>
                <div className="profile-row">
                  <span>Địa chỉ</span>
                  <strong>{authUser.address || '-'}</strong>
                </div>
                <div className="profile-row">
                  <span>Trạng thái</span>
                  <strong className={authUser.active ? 'pill success' : 'pill danger'}>
                    {authUser.active ? 'Active' : 'Inactive'}
                  </strong>
                </div>
                <div className="actions inline">
                  <button className="btn ghost" onClick={refreshProfile}>Tải lại</button>
                  <button className="btn danger" onClick={logout}>Đăng xuất</button>
                </div>
              </div>
            )}
          </section>
        )}
      </main>
    </div>
  );
}

export default App;
