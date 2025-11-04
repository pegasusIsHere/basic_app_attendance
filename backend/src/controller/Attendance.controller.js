const mongoose = require('mongoose');
const User = require('../model/User');
const Division = require('../model/Division');
const Attendance = require('../model/Attendance');

const toId = (id) => (mongoose.isValidObjectId(id) ? new mongoose.Types.ObjectId(id) : null);

async function checkIn(req, res) {
  try {
    // actor from token
    const actorId = toId(req.userId || req.user?.id || req.user?._id);
    if (!actorId) return res.status(401).json({ error: 'unauthorized' });

    // allow admins to act on behalf of someone else, else default to self
    const isAdmin = req.user?.role === 'admin';
    const targetIdRaw = isAdmin ? (req.body?.asUserId || actorId) : actorId;
    const uid = toId(targetIdRaw);

    const lon = Number(req.body?.lng);
    const lat = Number(req.body?.lat);
    const status = req.body?.status || 'present';

    if (!uid || !Number.isFinite(lon) || !Number.isFinite(lat)) {
      return res.status(400).json({ error: 'lng/lat required' });
    }

    // validate target user still exists / active
    // const user = await User.findOne({ _id: uid, isActive: true }, { _id: 1 }).lean();
    const user = await User.findOne({ _id: uid }, { _id: 1 }).lean();
    if (!user) return res.status(404).json({ error: 'User not found or inactive' });

    const point = { type: 'Point', coordinates: [lon, lat] };
    console.log("point",point)
    const division = await Division.findOne(
      { location: { $geoIntersects: { $geometry: point } } },
      { name: 1 }
    ).lean();
    if (!division) return res.status(403).json({ error: 'Outside any division polygon' });
    const attendance = await Attendance.create({
      userId: uid,
      divisionId: division._id,
      coord: point,
      status,
      checkedAt: new Date(),
    });

    return res.json({
      ok: true,
      attendanceId: attendance._id,
      userId: uid,
      divisionId: division._id,
      divisionName: division.name,
      checkedAt: attendance.checkedAt,
    });
  } catch (e) {
    console.error('checkIn error:', e);
    return res.status(500).json({ error: 'internal', details: e.message });
  }
}


async function listMyAttendance(req, res) {
  try {
    const uid = toId(req.user?.id || req.user?._id);
    if (!uid) return res.status(401).json({ error: 'unauthorized' });

    const rows = await Attendance.find({ userId: uid }, { divisionId: 1, coord: 1, status: 1, checkedAt: 1 })
      .sort({ checkedAt: -1 })
      .limit(100)
      .lean();

    return res.json(rows);
  } catch (e) {
    console.error('listMyAttendance error:', e);
    return res.status(500).json({ error: 'internal', details: e.message });
  }
}

async function listUserAttendance(req, res) {
  try {
    const uid = toId(req.params.userId);
    if (!uid) return res.status(400).json({ error: 'invalid user id' });

    const rows = await Attendance.find({ userId: uid }, { divisionId: 1, coord: 1, status: 1, checkedAt: 1 })
      .sort({ checkedAt: -1 })
      .limit(200)
      .lean();

    return res.json(rows);
  } catch (e) {
    console.error('listUserAttendance error:', e);
    return res.status(500).json({ error: 'internal', details: e.message });
  }
}

module.exports = { checkIn, listMyAttendance, listUserAttendance };
