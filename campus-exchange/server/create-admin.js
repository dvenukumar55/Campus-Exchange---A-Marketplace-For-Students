require('dotenv').config();

const mongoose = require('mongoose');
const Student = require('./src/models/Student');

async function createAdmin() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);

    const email = 'admin@avih.edu.in';

    const existing = await Student.findOne({
      officialEmail: email,
    });

    if (existing) {
      console.log('Account already exists:');
      console.log({
        email: existing.officialEmail,
        role: existing.role,
        studentId: existing.studentId,
      });

      await mongoose.disconnect();
      return;
    }

    const admin = await Student.create({
      studentId: 'admin_avih_001',
      collegeId: 'avih-gunthapalli',
      officialEmail: email,
      fullName: 'Campus Exchange Admin',
      department: 'Administration',
      graduatingYear: 2026,
      verificationStatus: 'verified',
      accountStatus: 'active',
      role: 'admin',
      verifiedAt: new Date(),
    });

    console.log('Admin account created successfully:');
    console.log({
      studentId: admin.studentId,
      email: admin.officialEmail,
      role: admin.role,
      collegeId: admin.collegeId,
      verificationStatus: admin.verificationStatus,
      accountStatus: admin.accountStatus,
    });

    await mongoose.disconnect();
  } catch (error) {
    console.error('Failed to create admin:', error);
    process.exit(1);
  }
}

createAdmin();