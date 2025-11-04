// middleware/requireAuth.js
const { verifyAccess } = require('../utils/jwt');

function requireAuth() {
  return (req, res, next) => {
    const hdr = req.headers.authorization;
    if (!hdr || !hdr.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'Missing Authorization header' });
    }
    try {
      const payload = verifyAccess(hdr.slice(7));
      if (payload.typ !== 'access') throw new Error('Invalid token type');
      req.userId = payload.sub;
      req.user   = { id: payload.sub, email: payload.email, role: payload.role };
      console.log("requireAuth req.user:",req.user)
      next();
    } catch {
      return res.status(401).json({ message: 'Invalid or expired token' });
    }
  };
}

module.exports = requireAuth;
