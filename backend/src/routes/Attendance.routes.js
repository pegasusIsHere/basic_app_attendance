const { Router } = require('express');
const requireAuth = require('../middleware/requireAuth');
const { listUserAttendance, listMyAttendance, checkIn } = require('../controller/Attendance.controller');
// const { checkIn, listMyAttendance, listUserAttendance } = require('../controllers/attendance.controller');

const attendanceRouter = Router();

const allowRoles = (...roles) => (req, res, next) => {
  if (!req.user || !roles.includes(req.user.role)) {
    return res.status(403).json({ error: 'forbidden' });
  }
  next();
};

attendanceRouter.post('/check-in', requireAuth(), checkIn);
attendanceRouter.get('/me', requireAuth(), listMyAttendance);
attendanceRouter.get('/user/:userId', requireAuth(), allowRoles('admin'), listUserAttendance);

module.exports = attendanceRouter;
