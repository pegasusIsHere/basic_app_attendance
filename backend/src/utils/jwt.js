const jwt = require('jsonwebtoken');

function reqEnv(key) {
  const v = process.env[key];
  if (!v) throw new Error(`Missing env ${key}`);
  return v;
}

const ACCESS_SECRET = reqEnv('JWT_ACCESS_SECRET');
const REFRESH_SECRET = reqEnv('JWT_REFRESH_SECRET');
const ACCESS_EXPIRES = process.env.JWT_ACCESS_EXPIRES || '15m';
const REFRESH_EXPIRES = process.env.JWT_REFRESH_EXPIRES || '30d';

function signAccessToken(user) {
    console.log("signAccessToken user:",user)
  return jwt.sign(
    { sub: String(user._id), typ: 'access', role: user.role, email: user.email },
    ACCESS_SECRET,
    { expiresIn: process.env.JWT_ACCESS_EXPIRES || '15m' }
  );
}
function signRefreshToken(user) {
  return jwt.sign(
    { sub: String(user._id), typ: 'refresh' },
    REFRESH_SECRET,
    { expiresIn: process.env.JWT_REFRESH_EXPIRES || '30d' }
  );
}

function verifyAccess(token)  { return jwt.verify(token, ACCESS_SECRET);  }
function verifyRefresh(token) { return jwt.verify(token, REFRESH_SECRET); }

module.exports = {
  signAccessToken,
  signRefreshToken,
  verifyAccess,
  verifyRefresh,
};

