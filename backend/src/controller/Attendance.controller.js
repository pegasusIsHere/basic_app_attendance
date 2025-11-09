// src/controller/attendance.controller.js
const mongoose = require('mongoose');
const crypto = require('crypto');

const User = require('../model/User');
const Division = require('../model/Division');
const Attendance = require('../model/Attendance');

const BUCKET_MS = Number(process.env.CHECKIN_BUCKET_MS || 60_000); // 1 minute default

const toId = (id) => (mongoose.isValidObjectId(id) ? new mongoose.Types.ObjectId(id) : null);
const makeBucket = (ts = Date.now()) => Math.floor(ts / BUCKET_MS);
const makeKey = ({ userId, divisionId, status, bucket }) =>
  crypto.createHash('sha256').update(`${userId}:${divisionId}:${status}:${bucket}`).digest('hex');

async function checkIn(req, res) {
  try {
    // 1) Actor from token (secure)
    const actorId = toId(req.userId || req.user?.id || req.user?._id);
    if (!actorId) return res.status(401).json({ error: 'unauthorized' });

    // 2) Admins can act on behalf of another user explicitly via asUserId
    const isAdmin = req.user?.role === 'admin';
    const targetIdRaw = isAdmin ? (req.body?.asUserId || actorId) : actorId;
    const uid = toId(targetIdRaw);

    // 3) Inputs
    const lon = Number(req.body?.lng);
    const lat = Number(req.body?.lat);
    const status = req.body?.status || 'present';
    if (!uid || !Number.isFinite(lon) || !Number.isFinite(lat)) {
      return res.status(400).json({ error: 'lng/lat required' });
    }

    // 4) Validate user exists (and optionally active)
    const user = await User.findOne({ _id: uid }, { _id: 1 }).lean();
    if (!user) return res.status(404).json({ error: 'User not found' });

    // 5) Determine division containing the point
    const point = { type: 'Point', coordinates: [lon, lat] };
    const division = await Division.findOne(
      { location: { $geoIntersects: { $geometry: point } } },
      { _id: 1, name: 1 }
    ).lean();
    if (!division) return res.status(403).json({ error: 'Outside any division polygon' });

    // 6) Server-derived idempotency key (time-bucketed)
    const bucket = makeBucket();
    const idempotencyKey = makeKey({
      userId: uid.toString(),
      divisionId: division._id.toString(),
      status,
      bucket
    });

    // 7) Upsert: dedupe within the bucket window
    const now = new Date();
    const attendance = await Attendance.findOneAndUpdate(
      { userId: uid, idempotencyKey },
      {
        $setOnInsert: {
          userId: uid,
          divisionId: division._id,
          coord: point,
          status,
          checkedAt: now,
          idempotencyKey
        }
      },
      { upsert: true, new: true }
    ).lean();

    return res.json({
      ok: true,
      attendanceId: attendance._id,
      userId: uid,
      divisionId: division._id,
      divisionName: division.name,
      checkedAt: attendance.checkedAt,
      idempotencyKey,
      bucketMs: BUCKET_MS
    });
  } catch (e) {
    console.error('checkIn error:', e);
    return res.status(500).json({ error: 'internal', details: e.message });
  }
}

async function listMyAttendance(req, res) {
  try {
    const uid = toId(req.userId || req.user?.id || req.user?._id);
    if (!uid) return res.status(401).json({ error: 'unauthorized' });

    const rows = await Attendance.aggregate([
      { $match: { userId: uid } },
      {
        $lookup: {
          from: 'divisions',
          localField: 'divisionId',
          foreignField: '_id',
          as: 'division'
        }
      },
      {
        $unwind: {
          path: '$division',
          preserveNullAndEmptyArrays: true
        }
      },
      {
        $project: {
          _id: 1,
          divisionId: 1,
          divisionName: '$division.name',
          coord: 1,
          status: 1,
          checkedAt: 1
        }
      },
      { $sort: { checkedAt: -1 } },
      { $limit: 100 }
    ]);

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

    const rows = await Attendance.find(
      { userId: uid },
      { divisionId: 1, coord: 1, status: 1, checkedAt: 1 }
    )
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
