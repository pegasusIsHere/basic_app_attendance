const { Router } = require('express');
const { register, login, refresh, me, logout } = require('../controller/Auth.controller');
const requireAuth = require('../middleware/requireAuth');

const authRouter = Router();

// Remove /register in prod if you seed users differently
authRouter.post('/register', register);
authRouter.post('/login', login);
authRouter.post('/refresh', refresh);
authRouter.get('/me', requireAuth(), me);
authRouter.post('/logout', requireAuth(), logout);

module.exports = authRouter;
