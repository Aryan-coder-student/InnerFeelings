const express = require('express');
const router = express.Router();
const User = require('../models/user');

router.get('/test-db', async (req, res) => {
  try {
    const users = await User.find();
    res.json(users);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;