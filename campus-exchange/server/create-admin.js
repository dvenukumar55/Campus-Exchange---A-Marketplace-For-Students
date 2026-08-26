require('dotenv').config({
  path: require('path').join(__dirname, '.env'),
});

const mongoose = require('mongoose');
const Student = require('./src/models/Student');

async function createOrUpdateAdmin() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB.');

    const adminStudentId = 'admin_avih_001';
    const adminEmail = 'kittud0005@gmail.com';
    const adminRollNumber = 'ADMIN001';
    const collegeId = 'avih-gunthapalli';

    // Find the existing admin by student ID
    let admin = await Student.findOne({
      studentId: adminStudentId,
    });

    if (admin) {
      // Update existing admin account
      admin.collegeId = collegeId;
      admin.officialEmail = adminEmail;
      admin.rollNumber = adminRollNumber;
      admin.fullName = 'Campus Exchange Admin';
      admin.department = 'Administration';
      admin.graduatingYear = 2026;
      admin.verificationStatus = 'verified';
      admin.accountStatus = 'active';
      admin.role = 'admin';
      admin.verifiedAt = admin.verifiedAt || new Date();

      await admin.save();

      console.log('Admin account updated successfully:');
      console.log({
        studentId: admin.studentId,
        email: admin.officialEmail,
        rollNumber: admin.rollNumber,
        role: admin.role,
        collegeId: admin.collegeId,
        verificationStatus: admin.verificationStatus,
        accountStatus: admin.accountStatus,
      });

      await mongoose.disconnect();
      return;
    }

    // Make sure the new email is not already used by another account
    const emailExists = await Student.findOne({
      officialEmail: adminEmail,
    });

    if (emailExists) {
      console.log('The email is already registered to another account:');
      console.log({
        studentId: emailExists.studentId,
        email: emailExists.officialEmail,
        role: emailExists.role,
      });

      await mongoose.disconnect();
      return;
    }

    // Create new admin
    admin = await Student.create({
      studentId: adminStudentId,
      collegeId: collegeId,
      officialEmail: adminEmail,
      rollNumber: adminRollNumber,
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
      rollNumber: admin.rollNumber,
      role: admin.role,
      collegeId: admin.collegeId,
      verificationStatus: admin.verificationStatus,
      accountStatus: admin.accountStatus,
    });

    await mongoose.disconnect();
  } catch (error) {
    console.error('Failed to create/update admin:', error);
    await mongoose.disconnect().catch(() => {});
    process.exit(1);
  }
}

createOrUpdateAdmin();