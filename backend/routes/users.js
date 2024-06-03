const express = require('express');
const router = express.Router();
const User = require('../models/user');
const jwt = require('jsonwebtoken');
const {compare} = require("bcrypt");

/**
 * @swagger
 * components:
 *   schemas:
 *     User:
 *       type: object
 *       required:
 *         - username
 *         - password
 *       properties:
 *         id:
 *           type: string
 *           description: The auto-generated id of the user
 *         username:
 *           type: string
 *           description: The username of the user
 *         password:
 *           type: string
 *           description: The password of the user
 *         role:
 *           type: string
 *           description: The role of the user
 *         upvotedIssues:
 *           type: array
 *           items:
 *             type: string
 *           description: List of issue IDs upvoted by the user
 *         downvotedIssues:
 *           type: array
 *           items:
 *             type: string
 *           description: List of issue IDs downvoted by the user
 *       example:
 *         username: "john_doe"
 *         password: "password123"
 *         role: "citizen"
 *         upvotedIssues: ["60b8d295f3f1a2c70563cbbd", "60b8d295f3f1a2c70563cbbe"]
 *         downvotedIssues: ["60b8d295f3f1a2c70563cbbf"]
 */


/**
 * @swagger
 * tags:
 *   name: Users
 *   description: The users managing API
 */

/**
 * @swagger
 * /users/register:
 *   post:
 *     summary: Register a new user
 *     tags: [Users]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/User'
 *     responses:
 *       201:
 *         description: The user was successfully registered
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/User'
 *       400:
 *         description: Bad request
 */
router.post('/register', async (req, res) => {
    try {
        const user = new User(req.body);
        await user.save();
        res.status(201).send(user);
    } catch (error) {
        res.status(400).send(error);
    }
});

/**
 * @swagger
 * /users/login:
 *   post:
 *     summary: Login a user
 *     tags: [Users]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               username:
 *                 type: string
 *                 description: The username of the user
 *               password:
 *                 type: string
 *                 description: The password of the user
 *             example:
 *               username: "john_doe"
 *               password: "password123"
 *     responses:
 *       200:
 *         description: The user was successfully logged in
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/User'
 *       404:
 *         description: Invalid login credentials
 *       400:
 *         description: Bad request
 */
router.post('/login', async (req, res) => {
    try {
        const user = await User.findOne({ username: req.body.username });
        if (!user) {
            return res.status(404).send({ error: 'Invalid login credentials' });
        }

        const isPasswordMatch = await compare(req.body.password, user.password);
        if (!isPasswordMatch) {
            return res.status(404).send({ error: 'Invalid login credentials' });
        }

        const token = jwt.sign({ _id: user._id.toString() }, process.env.JWT_SECRET);
        res.send({ token });
    } catch (error) {
        res.status(400).send(error);
    }
});

module.exports = router;
