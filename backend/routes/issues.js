const express = require("express");
const router = express.Router();
const Issue = require("../models/issue");
const Image = require("../models/image");
const User = require("../models/user");
const auth = require("../common/jwt-auth");
const authorize = require("../common/role-auth");

/**
 * @swagger
 * components:
 *   schemas:
 *     Issue:
 *       type: object
 *       required:
 *         - title
 *         - description
 *         - reportedBy
 *       properties:
 *         id:
 *           type: string
 *           description: The auto-generated id of the issue
 *         title:
 *           type: string
 *           description: The title of the issue
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
 *         resolvedDate:
 *           type: string
 *           format: date-time
 *           description: The date when the issue was resolved
 *         upvotedBy:
 *           type: array
 *           items:
 *             type: string
 *           description: List of user IDs who upvoted the issue
 *         downvotedBy:
 *           type: array
 *           items:
 *             type: string
 *           description: List of user IDs who downvoted the issue
 *       example:
 *         title: "123 Main St"
 *         description: "There is a large pothole on the road."
 *         image: "http://example.com/image.jpg"
 *         upvotes: 10
 *         downvotes: 2
 *         status: "reported"
 *         reportedBy: "60b8d295f3f1a2c70563cbbc"
 *         location:
 *           type: "Point"
 *           coordinates: [-73.856077, 40.848447]
 *         resolvedDate: "2024-06-02T12:34:56Z"
 *         upvotedBy: ["60b8d295f3f1a2c70563cbba", "60b8d295f3f1a2c70563cbbb"]
 *         downvotedBy: ["60b8d295f3f1a2c70563cbbc"]
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
 *               - title
 *               - description
 *             properties:
 *               title:
 *                 type: string
 *                 description: The title of the issue
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
router.post("/", auth, authorize(["citizen"]), async (req, res) => {
  try {
    const image = new Image({
      base64String: req.body.image,
    });
    const savedImage = await image.save();

    const issue = new Issue({
      title: req.body.title,
      description: req.body.description,
      imageId: savedImage._id,
      location: req.body.location,
      reportedBy: req.user._id,
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
router.get("/", auth, async (req, res) => {
  try {
    const issues = await Issue.find().populate("reportedBy", "username");
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
router.get("/reported", auth, async (req, res) => {
  try {
    const reportedIssues = await Issue.find().populate(
      "reportedBy",
      "username"
    );
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
router.get("/:id", auth, async (req, res) => {
  try {
    const issue = await Issue.findById(req.params.id)
      .populate("reportedBy", "username")
      .populate("imageId", "base64String");
    if (!issue) {
      return res.status(404).send({ error: "Issue not found" });
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
router.patch("/:id", auth, authorize(["worker"]), async (req, res) => {
  try {
    const issue = await Issue.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });
    if (!issue) {
      return res.status(404).send();
    }
    res.send(issue);
  } catch (error) {
    res.status(400).send(error);
  }
});

/**
 * @swagger
 * /issues/{id}/upvote:
 *   patch:
 *     summary: Upvote an issue
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
 *         description: The issue was upvoted
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Issue'
 *       404:
 *         description: The issue was not found
 *       500:
 *         description: Internal server error
 */
router.patch("/:id/upvote", auth, authorize(["citizen"]), async (req, res) => {
  try {
    const issue = await Issue.findById(req.params.id);
    if (!issue) {
      return res.status(404).send({ error: "Issue not found" });
    }

    const user = await User.findById(req.user._id);
    if (user.upvotedIssues.includes(issue._id)) {
      return res
        .status(400)
        .send({ error: "You have already upvoted this issue" });
    }

    if (user.downvotedIssues.includes(issue._id)) {
      user.downvotedIssues.pull(issue._id);
      issue.downvotedBy.pull(user._id);
      issue.downvotes -= 1;
    }

    user.upvotedIssues.push(issue._id);
    issue.upvotes += 1;
    issue.upvotedBy.push(user._id);
    await user.save();
    await issue.save();

    res.send(issue);
  } catch (error) {
    res.status(500).send(error);
  }
});

/**
 * @swagger
 * /issues/{id}/downvote:
 *   patch:
 *     summary: Downvote an issue
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
 *         description: The issue was downvoted
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Issue'
 *       404:
 *         description: The issue was not found
 *       500:
 *         description: Internal server error
 */
router.patch(
  "/:id/downvote",
  auth,
  authorize(["citizen"]),
  async (req, res) => {
    try {
      const issue = await Issue.findById(req.params.id);
      if (!issue) {
        return res.status(404).send({ error: "Issue not found" });
      }

      const user = await User.findById(req.user._id);
      if (user.downvotedIssues.includes(issue._id)) {
        return res
          .status(400)
          .send({ error: "You have already downvoted this issue" });
      }

      if (user.upvotedIssues.includes(issue._id)) {
        user.upvotedIssues.pull(issue._id);
        issue.upvotedBy.pull(user._id);
        issue.upvotes -= 1;
      }

      user.downvotedIssues.push(issue._id);
      issue.downvotes += 1;
      issue.downvotedBy.push(user._id);
      await user.save();
      await issue.save();

      res.send(issue);
    } catch (error) {
      res.status(500).send(error);
    }
  }
);

/**
 * @swagger
 * /issues/{id}/resolve:
 *   patch:
 *     summary: Resolve an issue
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
 *         description: The issue status was updated to resolved
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Issue'
 *       403:
 *         description: Access denied
 *       404:
 *         description: The issue was not found
 *       500:
 *         description: Internal server error
 */
router.patch("/:id/resolve", auth, authorize(["worker"]), async (req, res) => {
  try {
    const issue = await Issue.findById(req.params.id);
    if (!issue) {
      return res.status(404).send({ error: "Issue not found" });
    }
    issue.status = "resolved";
    issue.resolvedDate = new Date();
    await issue.save();
    res.send(issue);
  } catch (error) {
    res.status(500).send(error);
  }
});

module.exports = router;
