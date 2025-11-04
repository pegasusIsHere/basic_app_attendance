require('dotenv').config();
const express = require('express');
const morgan = require('morgan');
const cors = require('cors');
const { connectMongoose } = require('./src/db/mongoose');

const authRouter = require('./src/routes/Auth.routes');
const divisionRouter = require('./src/routes/Division.routes');
const attendanceRouter = require('./src/routes/Attendance.routes');


const app = express();
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

app.use('/api/auth', authRouter);
app.use('/api/divisions', divisionRouter);
app.use('/api/attendance', attendanceRouter);
app.get('/api/health', (_req, res) => res.json({ ok: true }));


const PORT = process.env.PORT || 3000;

(async () => {
  try {
     await connectMongoose();
    app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
  } catch (err) {
    console.error('Failed to start:', err);
    process.exit(1);
  }
})();
