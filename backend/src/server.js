const express = require('express');
const cors = require('cors');
const path = require('path');
const { port } = require('./config');

const app = express();
app.use(cors());
app.use(express.json({ limit: '2mb' }));
app.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')));

app.use('/api/auth', require('./routes/auth'));
app.use('/api/users', require('./routes/users'));
app.use('/api/announcements', require('./routes/announcements'));
app.use('/api/events', require('./routes/events'));
app.use('/api/requests', require('./routes/requests'));
app.use('/api/concerns', require('./routes/concerns'));
app.use('/api/notifications', require('./routes/notifications'));
app.use('/api/emergency-contacts', require('./routes/directory'));
app.use('/api/reports', require('./routes/reports'));

app.get('/', (req, res) => res.json({ message: 'BarangayConnect API is running' }));

app.listen(port, () => console.log(`BarangayConnect API listening on port ${port}`));
