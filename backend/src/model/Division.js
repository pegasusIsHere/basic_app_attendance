const mongoose = require('mongoose');

const geoPolygonSchema = new mongoose.Schema(
  {
    type: {
      type: String,
      enum: ['Polygon', 'MultiPolygon'],
      required: true,
    },
    // For Polygon: [ [ [lng, lat], ... ] ]
    // For MultiPolygon: [ [ [ [lng, lat], ... ] ] ]
    coordinates: {
      type: Array,
      required: true,
      validate: {
        validator: function (val) {
          return Array.isArray(val) && val.length > 0;
        },
        message: 'coordinates must be a non-empty array',
      },
    },
  },
  { _id: false }
);

const divisionSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    location: { type: geoPolygonSchema, required: true },
  },
  { timestamps: true }
);

// 2dsphere index needed for $geoIntersects / $geoWithin
divisionSchema.index({ location: '2dsphere' });

module.exports = mongoose.model('Division', divisionSchema);
