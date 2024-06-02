const express = require('express');
const router = express.Router();
const Issue = require('../models/issue');
const auth = require('../common/jwt-auth');
const authorize = require('../common/role-auth');

/**
 * @swagger
 * components:
 *   schemas:
 *     Issue:
 *       type: object
 *       required:
 *         - address
 *         - description
 *         - reportedBy
 *       properties:
 *         id:
 *           type: string
 *           description: The auto-generated id of the issue
 *         address:
 *           type: string
 *           description: The address of the issue
 *         description:
 *           type: string
 *           description: The description of the issue
 *         image:
 *           type: string
 *           description: The image URL of the issue
 *         upvotes:
 *           type: number
 *           description: The number of upvotes
 *         downvotes:
 *           type: number
 *           description: The number of downvotes
 *         status:
 *           type: string
 *           enum: ['reported', 'in progress', 'resolved']
 *           description: The status of the issue
 *         reportedBy:
 *           type: string
 *           description: The id of the user who reported the issue
 *         location:
 *           type: object
 *           properties:
 *             type:
 *               type: string
 *               enum: ['Point']
 *             coordinates:
 *               type: array
 *               items:
 *                 type: number
 *               description: The coordinates of the issue location
 *       example:
 *         address: "123 Main St"
 *         description: "There is a large pothole on the road."
 *         image: "http://example.com/image.jpg"
 *         upvotes: 10
 *         downvotes: 2
 *         status: "reported"
 *         reportedBy: "60b8d295f3f1a2c70563cbbc"
 *         location:
 *           type: "Point"
 *           coordinates: [-73.856077, 40.848447]
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
 *   name: Issues
 *   description: The issues managing API
 */

/**
 * @swagger
 * /issues:
 *   post:
 *     summary: Create a new issue
 *     tags: [Issues]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - address
 *               - description
 *             properties:
 *               address:
 *                 type: string
 *                 description: The address of the issue
 *               description:
 *                 type: string
 *                 description: The description of the issue
 *               image:
 *                 type: string
 *                 description: The image URL of the issue
 *               location:
 *                 type: object
 *                 properties:
 *                   type:
 *                     type: string
 *                     enum: ['Point']
 *                   coordinates:
 *                     type: array
 *                     items:
 *                       type: number
 *                     description: The coordinates of the issue location
 *     responses:
 *       201:
 *         description: The issue was successfully created
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Issue'
 *       400:
 *         description: Bad request
 */
router.post('/', auth, authorize(['citizen']), async (req, res) => {
    try {
        const issue = new Issue({
            ...req.body,
            reportedBy: req.user._id
        });
        await issue.save();
        res.status(201).send(issue);
    } catch (error) {
        res.status(400).send(error);
    }
});

/**
 * @swagger
 * /issues:
 *   get:
 *     summary: Returns the list of all the issues
 *     tags: [Issues]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: The list of the issues
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Issue'
 *       500:
 *         description: Internal server error
 */
router.get('/', auth, async (req, res) => {
    try {
        const issues = await Issue.find();
        res.status(200).send(issues);
    } catch (error) {
        res.status(500).send(error);
    }
});

/**
 * @swagger
 * /issues/reported:
 *   get:
 *     summary: Returns the list of reported issues
 *     tags: [Issues]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: The list of reported issues
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Issue'
 *       500:
 *         description: Internal server error
 */
router.get('/reported', auth, async (req, res) => {
    try {
        const reportedIssues = await Issue.find({ status: 'reported' });
        res.status(200).send(reportedIssues);
    } catch (error) {
        res.status(500).send(error);
    }
});

/**
 * @swagger
 * /issues/{id}:
 *   get:
 *     summary: Get the issue by id
 *     tags: [Issues]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         schema:
 *           type: string
 *         required: true
 *         description: The issue id
 *     responses:
 *       200:
 *         description: The issue description by id
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Issue'
 *       404:
 *         description: The issue was not found
 *       500:
 *         description: Internal server error
 */
router.get('/:id', auth, async (req, res) => {
    try {
        const issue = await Issue.findById(req.params.id);
        if (!issue) {
            return res.status(404).send({ error: 'Issue not found' });
        }
        res.status(200).send(issue);
    } catch (error) {
        res.status(500).send(error);
    }
});

/**
 * @swagger
 * /issues/{id}:
 *   patch:
 *     summary: Update the issue by the id
 *     tags: [Issues]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         schema:
 *           type: string
 *         required: true
 *         description: The issue id
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Issue'
 *     responses:
 *       200:
 *         description: The issue was updated
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Issue'
 *       400:
 *         description: Bad request
 *       404:
 *         description: The issue was not found
 *       500:
 *         description: Internal server error
 */
router.patch('/:id', auth, authorize(['worker']), async (req, res) => {
    try {
        const issue = await Issue.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true });
        if (!issue) {
            return res.status(404).send();
        }
        res.send(issue);
    } catch (error) {
        res.status(400).send(error);
    }
});

module.exports = router;
