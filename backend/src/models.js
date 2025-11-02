const { getDb } = require('./db');

async function getCollections() {
  const db = getDb();
  const users = db.collection('users');
  const divisions = db.collection('divisions');
  const attendance = db.collection('attendance');

  // Ensure indexes ONCE at startup
  await Promise.all([
    divisions.createIndex({ location: '2dsphere' }),
    attendance.createIndex({ coord: '2dsphere' }),
    attendance.createIndex({ userId: 1, checkedAt: -1 }),
    attendance.createIndex({ divisionId: 1, checkedAt: -1 })
  ]);

  return { users, divisions, attendance };
}

module.exports = { getCollections };
