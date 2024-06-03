const mongoose = require('mongoose');
const Schema = mongoose.Schema;
const bcrypt = require('bcrypt');

const UserSchema = new Schema({
    username: {
        type: String,
        required: true,
        unique: true
    },
    password: {
        type: String,
        required: true
    },
    email: {
        type: String,
        required: true,
        unique: true
    },
    role: {
        type: String,
        enum: ['citizen', 'worker', 'contact_person'],
        default: 'citizen'
    },
    upvotedIssues: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Issue'
    }],
    downvotedIssues: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Issue'
    }]
}, { timestamps: true });

UserSchema.pre('save', async function (next) {
    const user = this;
    if (user.isModified('password')) {
        user.password = await bcrypt.hash(user.password, 8);
    }
    next();
});

module.exports = mongoose.models.User || mongoose.model('User', UserSchema);
