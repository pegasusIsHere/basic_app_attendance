@echo off
REM ==================================================
REM  Create src/ folder and all Node.js files
REM  For Attendance Mongo Project
REM ==================================================

REM Create src folder
if not exist src mkdir src
cd src

REM ---------- db.js ----------
(
echo const { MongoClient } = require('mongodb');
echo const { MONGODB_URI } = process.env;
echo.
echo let client;
echo let db;
echo.
echo async function connect() {
echo   if (db) return db;
echo   client = new MongoClient(MONGODB_URI, { maxPoolSize: 10, serverSelectionTimeoutMS: 5000 });
echo   await client.connect();
echo   db = client.db();
echo   return db;
echo }
echo.
echo function getDb() {
echo   if (!db) throw new Error('DB not initialized. Call connect() first.');
echo   return db;
echo }
echo.
echo async function close() {
echo   if (client) await client.close();
echo }
echo.
echo module.exports = { connect, getDb, close };
) > db.js

REM ---------- models.js ----------
(
echo const { getDb } = require('./db');
echo.
echo async function getCollections() {
echo   const db = getDb();
echo   const users = db.collection('users');
echo   const divisions = db.collection('divisions');
echo   const attendance = db.collection('attendance');
echo.
echo   await Promise.all([
echo     divisions.createIndex({ location: '2dsphere' }),
echo     attendance.createIndex({ coord: '2dsphere' }),
echo     attendance.createIndex({ userId: 1, checkedAt: -1 }),
echo     attendance.createIndex({ divisionId: 1, checkedAt: -1 })
echo   ]);
echo.
echo   return { users, divisions, attendance };
echo }
echo.
echo module.exports = { getCollections };
) > models.js

REM ---------- routes.js ----------
(
echo const express = require('express');
echo const router = express.Router();
echo const { ObjectId } = require('mongodb');
echo const { getCollections } = require('./models');
echo.
echo const toObjectId = (id) =^> {
echo   try { return new ObjectId(id); } catch { return null; }
echo };
echo.
echo router.get('/health', (req, res) =^> res.json({ ok: true }));
echo.
echo router.post('/users', async (req, res) =^> {
echo   const { name } = req.body || {};
echo   if (!name) return res.status(400).json({ error: 'name required' });
echo   const { users } = await getCollections();
echo   const { insertedId } = await users.insertOne({ name });
echo   res.json({ _id: insertedId, name });
echo });
echo.
echo router.post('/divisions', async (req, res) =^> {
echo   const { name, location } = req.body || {};
echo   if (!name || !location || !location.type || !location.coordinates) {
echo     return res.status(400).json({ error: 'name and valid GeoJSON required' });
echo   }
echo   const { divisions } = await getCollections();
echo   const { insertedId } = await divisions.insertOne({ name, location });
echo   res.json({ _id: insertedId, name, location });
echo });
echo.
echo router.post('/attendance/check-in', async (req, res) =^> {
echo   const { userId, lng, lat, status } = req.body || {};
echo   const lon = parseFloat(lng);
echo   const la = parseFloat(lat);
echo   const uid = toObjectId(userId);
echo.
echo   if (!uid || !Number.isFinite(lon) || !Number.isFinite(la)) {
echo     return res.status(400).json({ error: 'userId, lng, lat required' });
echo   }
echo.
echo   const { users, divisions, attendance } = await getCollections();
echo   const user = await users.findOne({ _id: uid });
echo   if (!user) return res.status(404).json({ error: 'User not found' });
echo.
echo   const point = { type: 'Point', coordinates: [lon, la] };
echo   const division = await divisions.findOne({
echo     location: { $geoIntersects: { $geometry: point } }
echo   }, { projection: { name: 1 } });
echo.
echo   if (!division) return res.status(403).json({ error: 'Outside any division polygon' });
echo.
echo   const doc = {
echo     userId: uid,
echo     divisionId: division._id,
echo     coord: point,
echo     status: status || 'present',
echo     checkedAt: new Date()
echo   };
echo.
echo   const { insertedId } = await attendance.insertOne(doc);
echo   res.json({
echo     ok: true,
echo     attendanceId: insertedId,
echo     userId: uid,
echo     divisionId: division._id,
echo     divisionName: division.name,
echo     checkedAt: doc.checkedAt
echo   });
echo });
echo.
echo router.get('/users/:id/attendance', async (req, res) =^> {
echo   const uid = toObjectId(req.params.id);
echo   if (!uid) return res.status(400).json({ error: 'invalid user id' });
echo   const { attendance } = await getCollections();
echo   const rows = await attendance.find({ userId: uid })
echo     .project({ _id: 1, divisionId: 1, coord: 1, status: 1, checkedAt: 1 })
echo     .sort({ checkedAt: -1 })
echo     .limit(50)
echo     .toArray();
echo   res.json(rows);
echo });
echo.
echo module.exports = router;
) > routes.js

REM ---------- index.js ----------
(
echo require('dotenv').config();
echo const express = require('express');
echo const morgan = require('morgan');
echo const { connect } = require('./db');
echo const routes = require('./routes');
echo.
echo const app = express();
echo app.use(express.json());
echo app.use(morgan('dev'));
echo app.use('/api', routes);
echo.
echo const PORT = process.env.PORT ^|^| 3000;
echo.
echo (async () =^> {
echo   try {
echo     await connect();
echo     app.listen(PORT, () =^> console.log(`Server running on http://localhost:${PORT}`));
echo   } catch (err) {
echo     console.error('Failed to start:', err);
echo     process.exit(1);
echo   }
echo })();
) > index.js

echo.
echo ✅ All src files created successfully inside /src
echo.
cd ..
