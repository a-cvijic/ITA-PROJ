const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const issueRoutes = require('./routes/issues');
const userRoutes = require('./routes/users');
const messageRoutes = require('./routes/messages');
const setupSwagger = require('./swagger');
require('dotenv').config();
const cors = require('cors');

const app = express();
const port = 3000;

// Poveži se z MongoDB
const dbUser = process.env.MONGO_DB_USER;
const dbPassword = process.env.MONGO_DB_PASSWORD;
const dbHost = process.env.MONGO_DB_HOST;
const dbName = process.env.MONGO_DB_NAME;


const connectionString = `mongodb+srv://${dbUser}:${dbPassword}@${dbHost}/${dbName}`;
console.log(connectionString);
mongoose.connect(connectionString, {
    useNewUrlParser: true,
    useUnifiedTopology: true
});

const db = mongoose.connection;

db.on('error', console.error.bind(console, 'Napaka pri povezovanju z MongoDB:'));
db.once('open', function () {
    console.log('Uspešno povezan na MongoDB.');
});

// Middleware
app.use(bodyParser.json({ limit: '50mb' }));
app.use(bodyParser.urlencoded({ limit: '50mb', extended: true }));
app.use(cors());

// Rute
app.use('/issues', issueRoutes);
app.use('/users', userRoutes);
app.use('/messages', messageRoutes);

// Swagger dokumentacija
setupSwagger(app);

// Zaženi strežnik
app.listen(port, () => {
    console.log(`App listening at http://localhost:${port}`);
});
