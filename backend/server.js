require('dotenv').config();
const express = require('express');
const morgan = require('morgan');
const { connect } = require('./src/db');
const routes = require('./src/routes');

const app = express();
app.use(express.json());
app.use(morgan('dev'));
app.use('/api', routes);

const PORT = process.env.PORT || 3000;

(async () => {
  try {
    await connect();
    app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
  } catch (err) {
    console.error('Failed to start:', err);
    process.exit(1);
  }
})();
