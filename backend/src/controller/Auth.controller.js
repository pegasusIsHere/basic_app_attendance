const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const { z } = require('zod');
const User = require('../model/User');


const {
  signAccessToken,
  signRefreshToken,
  verifyRefresh,
} = require('../utils/jwt');

const registerSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
  name: z.string().optional(),
});

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
});

const refreshSchema = z.object({
  refreshToken: z.string().min(1),
});

// hash refresh tokens before storing (token rotation + reuse detection)
function hashToken(token) {
  return new Promise((resolve, reject) => {
    crypto.pbkdf2(token, 'refresh_salt', 100000, 64, 'sha512', (err, dk) => {
      if (err) reject(err);
      else resolve(dk.toString('hex'));
    });
  });
}

async function register(req, res) {
  const parsed = registerSchema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ message: parsed.error.message });

  const { email, password, name } = parsed.data;

  const existing = await User.findOne({ email });
  if (existing) return res.status(409).json({ message: 'Email already in use' });

  const passwordHash = await bcrypt.hash(password, 12);
  const user = await User.create({ email, name, passwordHash, role: 'employee' });

  return res.status(201).json({ id: user.id, email: user.email });
}

async function login(req, res) {
    console.log("login req.body:",req.body)
  const parsed = loginSchema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ message: parsed.error.message });

  const { email, password } = parsed.data;
  const user = await User.findOne({ email });
  if (!user) return res.status(401).json({ message: 'Invalid credentials' });

  const ok = await bcrypt.compare(password, user.passwordHash);
  if (!ok) return res.status(401).json({ message: 'Invalid credentials' });
  const accessToken = signAccessToken(user);
  const refreshToken = signRefreshToken(user);

  user.refreshTokenHash = await hashToken(refreshToken);
  await user.save();

  return res.json({ accessToken, refreshToken });
}

async function me(req, res) {
  const userId = req.userId;
  if (!userId) return res.status(401).json({ message: 'Unauthorized' });

  const user = await User.findById(userId).select('id email name role');
  if (!user) return res.status(404).json({ message: 'User not found' });

  return res.json({ id: user.id, email: user.email, name: user.name, role: user.role });
}

async function refresh(req, res) {
  const parsed = refreshSchema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ message: parsed.error.message });

  const { refreshToken } = parsed.data;

  let payload;
  try {
    payload = verifyRefresh(refreshToken);
    if (payload.typ !== 'refresh') throw new Error('Bad token type');
  } catch {
    return res.status(401).json({ message: 'Invalid refresh token' });
  }

  const user = await User.findById(payload.sub);
  if (!user || !user.refreshTokenHash) {
    return res.status(401).json({ message: 'No active session' });
  }

  const incomingHash = await hashToken(refreshToken);
  if (incomingHash !== user.refreshTokenHash) {
    // token reuse/rotation mismatch: invalidate
    user.refreshTokenHash = null;
    await user.save();
    return res.status(401).json({ message: 'Refresh token mismatch' });
  }

  const newAccess = signAccessToken(user._id);
  const newRefresh = signRefreshToken(user._id);
  user.refreshTokenHash = await hashToken(newRefresh);
  await user.save();

  return res.json({ accessToken: newAccess, refreshToken: newRefresh });
}

async function logout(req, res) {
  const userId = req.userId;
  if (!userId) return res.status(401).json({ message: 'Unauthorized' });

  const user = await User.findById(userId);
  if (user) {
    user.refreshTokenHash = null;
    await user.save();
  }
  return res.json({ ok: true });
}

module.exports = {
  register,
  login,
  me,
  refresh,
  logout,
};
