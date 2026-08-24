require('dotenv').config();

const mongoose = require('mongoose');
const Student = require('./src/models/Student');

async function checkAdmins() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);

    const students = await Student.find({
      role: { $in: ['admin', 'moderator'] }
    })
      .select(
        'studentId officialEmail fullName role accountStatus verificationStatus collegeId'
      )
      .lean();

    console.log(JSON.stringify(students, null, 2));

    await mongoose.disconnect();
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
}

checkAdmins();