const { Router } = require('express');
const requireAuth = require('../middleware/requireAuth');
const { createDivision, listDivisions, getDivision } = require('../controller/division.controller');

const divisionRouter = Router();

const allowRoles = (...roles) => (req, res, next) => {
  if (!req.user || !roles.includes(req.user.role)) {
    return res.status(403).json({ error: 'forbidden' });
  }
  next();
};

// Admin-only here (adjust as you wish)
divisionRouter.post('/', requireAuth(), allowRoles('admin'), createDivision);
divisionRouter.get('/', requireAuth(), allowRoles('admin'), listDivisions);
divisionRouter.get('/:id', requireAuth(), allowRoles('admin'), getDivision);

module.exports = divisionRouter;
