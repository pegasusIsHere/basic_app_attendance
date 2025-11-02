const { MongoClient } = require('mongodb');
const { MONGODB_URI } = process.env;

let client;
let db;

async function connect() {
  if (db) return db;

  client = new MongoClient(MONGODB_URI, {
    maxPoolSize: 10,
    serverSelectionTimeoutMS: 5000,
  });
  await client.connect();
  db = client.db(); // uses DB from URI
  console.log("DB connection accessed");
  return db;
}

function getDb() {
  if (!db) throw new Error('DB not initialized. Call connect() first.');
  return db;
}

async function close() {
  if (client) await client.close();
}

module.exports = { connect, getDb, close };
