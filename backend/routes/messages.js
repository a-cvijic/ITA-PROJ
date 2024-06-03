const express = require('express');
const router = express.Router();
const auth = require('../common/jwt-auth');
const authorize = require('../common/role-auth');
const Message = require('../models/message');
const User = require('../models/user');

/**
 * @swagger
 * components:
 *   schemas:
 *     Message:
 *       type: object
 *       required:
 *         - from
 *         - to
 *         - message
 *       properties:
 *         id:
 *           type: string
 *           description: The auto-generated id of the message
 *         from:
 *           type: string
 *           description: The id of the sender
 *         to:
 *           type: string
 *           description: The id of the receiver
 *         message:
 *           type: string
 *           description: The content of the message
 *         read:
 *           type: boolean
 *           description: Whether the message has been read
 *       example:
 *         id: "609e60779b9ca2272c5a16a3"
 *         from: "60b8d295f3f1a2c70563cbbc"
 *         to: "60b8d295f3f1a2c70563cbbd"
 *         message: "Hello, I would like to report an issue."
 *         read: false
 */

/**
 * @swagger
 * components:
 *   securitySchemes:
 *     bearerAuth:
 *       type: http
 *       scheme: bearer
 *       bearerFormat: JWT
 */

/**
 * @swagger
 * tags:
 *   name: Messages
 *   description: The messages managing API
 */

/**
 * @swagger
 * /messages/send:
 *   post:
 *     summary: Send a message to the contact person
 *     tags: [Messages]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - message
 *             properties:
 *               message:
 *                 type: string
 *                 description: The message content
 *     responses:
 *       201:
 *         description: Message sent successfully
 *       400:
 *         description: Bad request
 *       500:
 *         description: Internal server error
 */
router.post('/send', auth, authorize(['citizen']), async (req, res) => {
    try {
        const contactPerson = await User.findOne({ role: 'contact_person' });
        if (!contactPerson) {
            return res.status(404).send({ error: 'Contact person not found' });
        }

        const message = new Message({
            from: req.user._id,
            to: contactPerson._id,
            message: req.body.message
        });

        await message.save();
        res.status(201).send(message);
    } catch (error) {
        res.status(500).send(error);
    }
});

/**
 * @swagger
 * /messages:
 *   get:
 *     summary: Get messages for the authenticated citizen
 *     tags: [Messages]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of messages
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Message'
 *       500:
 *         description: Internal server error
 */
router.get('/', auth, authorize(['citizen']), async (req, res) => {
    try {
        const messages = await Message.find({
            $or: [{ from: req.user._id }, { to: req.user._id }]
        }).populate('from to', 'username');
        res.send(messages);
    } catch (error) {
        res.status(500).send(error);
    }
});

/**
 * @swagger
 * /messages/reply:
 *   post:
 *     summary: Reply to a citizen's message
 *     tags: [Messages]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - to
 *               - message
 *             properties:
 *               to:
 *                 type: string
 *                 description: The ID of the citizen
 *               message:
 *                 type: string
 *                 description: The message content
 *     responses:
 *       201:
 *         description: Reply sent successfully
 *       400:
 *         description: Bad request
 *       500:
 *         description: Internal server error
 */
router.post('/reply', auth, authorize(['contact_person']), async (req, res) => {
    try {
        const citizen = await User.findById(req.body.to);
        if (!citizen || citizen.role !== 'citizen') {
            return res.status(404).send({ error: 'Citizen not found' });
        }

        const message = new Message({
            from: req.user._id,
            to: req.body.to,
            message: req.body.message
        });

        await message.save();
        res.status(201).send(message);
    } catch (error) {
        res.status(500).send(error);
    }
});

/**
 * @swagger
 * /messages/contacts:
 *   get:
 *     summary: Get list of citizens who messaged the contact person
 *     tags: [Messages]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of citizens
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/User'
 *       500:
 *         description: Internal server error
 */
router.get('/contacts', auth, authorize(['contact_person']), async (req, res) => {
    try {
        const messages = await Message.find({ to: req.user._id }).populate('from', 'username');
        const uniqueCitizens = [...new Set(messages.map(message => message.from._id))];
        const citizens = await User.find({ _id: { $in: uniqueCitizens } }).select('username');
        res.send(citizens);
    } catch (error) {
        res.status(500).send(error);
    }
});

/**
 * @swagger
 * /messages/conversation/{citizenId}:
 *   get:
 *     summary: Get messages between the contact person and a citizen
 *     tags: [Messages]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: citizenId
 *         schema:
 *           type: string
 *         required: true
 *         description: The ID of the citizen
 *     responses:
 *       200:
 *         description: List of messages
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Message'
 *       500:
 *         description: Internal server error
 */
router.get('/conversation/:citizenId', auth, authorize(['contact_person']), async (req, res) => {
    try {
        const citizen = await User.findById(req.params.citizenId);
        if (!citizen || citizen.role !== 'citizen') {
            return res.status(404).send({ error: 'Citizen not found' });
        }

        const messages = await Message.find({
            $or: [
                { from: req.user._id, to: req.params.citizenId },
                { from: req.params.citizenId, to: req.user._id }
            ]
        }).populate('from to', 'username');

        res.send(messages);
    } catch (error) {
        res.status(500).send(error);
    }
});

module.exports = router;


