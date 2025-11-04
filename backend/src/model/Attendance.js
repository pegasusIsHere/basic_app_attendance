const mongoose = require('mongoose');
const { Schema } = mongoose;

const geoPointSchema = new Schema(
  {
    type: {
      type: String,
      enum: ['Point'],
      required: true,
    },
    // [lng, lat]
    coordinates: {
      type: [Number],
      required: true,
      validate: {
        validator: (arr) => Array.isArray(arr) && arr.length === 2,
        message: 'coordinates must be [lng, lat]',
      },
    },
  },
  { _id: false }
);

const attendanceSchema = new Schema(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    divisionId: { type: Schema.Types.ObjectId, ref: 'Division', required: true },
    coord: { type: geoPointSchema, required: true }, // phone location at check-in
    status: {
      type: String,
      enum: ['present', 'in', 'out'],
      default: 'present',
    },
    checkedAt: { type: Date, default: Date.now },
    // Optional: prevent duplicate retries
    idempotencyKey: { type: String, default: null },
  },
  { timestamps: true }
);

// Geo index for point queries (not required for polygon containment, but useful for analytics)
attendanceSchema.index({ coord: '2dsphere' });

// Fast lookups
attendanceSchema.index({ userId: 1, checkedAt: -1 });
attendanceSchema.index({ divisionId: 1, checkedAt: -1 });

// Optional de-duplication (one check-in per idempotencyKey per user)
// Create a sparse unique compound index if you plan to send idempotencyKey from client
attendanceSchema.index(
  { userId: 1, idempotencyKey: 1 },
  { unique: true, partialFilterExpression: { idempotencyKey: { $type: 'string' } } }
);

module.exports = mongoose.model('Attendance', attendanceSchema);
