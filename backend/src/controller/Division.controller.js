const mongoose = require('mongoose');
const Division = require('../model/Division');

const toId = (id) => (mongoose.isValidObjectId(id) ? new mongoose.Types.ObjectId(id) : null);

async function createDivision(req, res) {
  try {
    const { name, location } = req.body || {};
    if (!name || !location || !location.type || !location.coordinates) {
      return res.status(400).json({ error: 'name and valid GeoJSON location required' });
    }
    const doc = await Division.create({ name, location });
    return res.json({ _id: doc._id, name: doc.name, location: doc.location });
  } catch (e) {
    console.error('createDivision error:', e);
    return res.status(500).json({ error: 'internal', details: e.message });
  }
}

async function listDivisions(_req, res) {
  try {
    const rows = await Division.find({}, { name: 1, location: 1 }).sort({ name: 1 }).lean();
    return res.json(rows);
  } catch (e) {
    console.error('listDivisions error:', e);
    return res.status(500).json({ error: 'internal', details: e.message });
  }
}

async function getDivision(req, res) {
  try {
    const id = toId(req.params.id);
    if (!id) return res.status(400).json({ error: 'invalid id' });
    const doc = await Division.findById(id, { name: 1, location: 1 }).lean();
    if (!doc) return res.status(404).json({ error: 'not found' });
    return res.json(doc);
  } catch (e) {
    console.error('getDivision error:', e);
    return res.status(500).json({ error: 'internal', details: e.message });
  }
}

module.exports = { createDivision, listDivisions, getDivision };
