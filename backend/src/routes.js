const express = require('express');
const router = express.Router();
const { ObjectId } = require('mongodb');
const { getCollections } = require('./models');

// Helpers
const toObjectId = (id) => {
  try { return new ObjectId(id); } catch { return null; }
};

// Health
router.get('/health', (req, res) => res.json({ ok: true }));

/**
 * Create a user (minimal)
 * POST /users
 * { "name": "Alice" }
 */
router.post('/users', async (req, res) => {
  const { name } = req.body || {};
  if (!name) return res.status(400).json({ error: 'name required' });
  const { users } = await getCollections();
  const { insertedId } = await users.insertOne({ name });
  res.json({ _id: insertedId, name });
});

/**
 * Create a division (polygon or multipolygon)
 * POST /divisions
 * {
 *   "name": "HQ",
 *   "location": {
 *     "type": "Polygon",
 *     "coordinates": [[[lon,lat],[lon,lat],[lon,lat],[lon,lat],[lon,lat]]]
 *   }
 * }
 */
router.post('/divisions', async (req, res) => {
  const { name, location } = req.body || {};
  if (!name || !location || !location.type || !location.coordinates) {
    return res.status(400).json({ error: 'name and valid GeoJSON location required' });
  }
  const { divisions } = await getCollections();
  const { insertedId } = await divisions.insertOne({ name, location });
  res.json({ _id: insertedId, name, location });
});

/**
 * Check-in (attendance)
 * POST /attendance/check-in
 * {
 *   "userId": "<ObjectId string>",
 *   "lng": -7.6201,
 *   "lat": 33.5802,
 *   "status": "present"   // optional, defaults to "present"
 * }
 *
 * Logic:
 * - Build Point
 * - Find a division whose polygon covers the point ($geoIntersects)
 * - If found, create Attendance
 */
router.post('/attendance/check-in', async (req, res) => {
  const { userId, lng, lat, status } = req.body || {};
  const lon = parseFloat(lng);
  const la = parseFloat(lat);
  const uid = toObjectId(userId);

  if (!uid || !Number.isFinite(lon) || !Number.isFinite(la)) {
    return res.status(400).json({ error: 'userId, lng, lat are required' });
  }

  const { users, divisions, attendance } = await getCollections();

  const user = await users.findOne({ _id: uid });
  if (!user) return res.status(404).json({ error: 'User not found' });

  const point = { type: 'Point', coordinates: [lon, la] };

  // Find the FIRST division containing the point
  const division = await divisions.findOne({
    location: { $geoIntersects: { $geometry: point } }
  }, { projection: { name: 1 } });

  if (!division) {
    return res.status(403).json({ error: 'Outside any division polygon' });
  }

  const doc = {
    userId: uid,
    divisionId: division._id,
    coord: point,
    status: status || 'present',
    checkedAt: new Date()
  };

  const { insertedId } = await attendance.insertOne(doc);
  res.json({
    ok: true,
    attendanceId: insertedId,
    userId: uid,
    divisionId: division._id,
    divisionName: division.name,
    checkedAt: doc.checkedAt
  });
});

/**
 * Get a user's attendance (latest first)
 * GET /users/:id/attendance
 */
router.get('/users/:id/attendance', async (req, res) => {
  const uid = toObjectId(req.params.id);
  if (!uid) return res.status(400).json({ error: 'invalid user id' });

  const { attendance } = await getCollections();
  const rows = await attendance.find({ userId: uid })
    .project({ _id: 1, divisionId: 1, coord: 1, status: 1, checkedAt: 1 })
    .sort({ checkedAt: -1 })
    .limit(50)
    .toArray();

  res.json(rows);
});

module.exports = router;
