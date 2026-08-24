import 'package:flutter_test/flutter_test.dart';
import 'package:campus_exchange/models/listing.dart';
import 'package:campus_exchange/models/student.dart';

void main() {
  group('Listing and Student Model Tests (T-032)', () {
    test('Listing correctly deserializes Java Programming Book JSON', () {
      final json = {
        'listingId': 'list_java_book_1',
        'collegeId': 'avih-gunthapalli',
        'sellerId': 'std_12345',
        'sellerName': 'Avanthi Student',
        'title': 'Java Programming Book',
        'description': 'Java programming book in good condition',
        'category': 'Academic / Books',
        'price': 500,
        'condition': 'Good',
        'photoRefs': ['java_book_cover.jpg'],
        'status': 'active',
        'viewCount': 10,
        'chatCount': 2,
        'createdAt': '2026-08-18T10:00:00.000Z',
      };

      final listing = Listing.fromJson(json);

      expect(listing.title, 'Java Programming Book');
      expect(listing.price, 500.0);
      expect(listing.condition, 'Good');
      expect(listing.category, 'Academic / Books');
      expect(listing.isActive, true);
      expect(listing.photoRefs.first, 'java_book_cover.jpg');
    });

    test('Student model verification status check', () {
      final verifiedStudent = Student(
        studentId: 'std_1',
        collegeId: 'avih-gunthapalli',
        collegeName: 'Avanthi Institute',
        officialEmail: 'student@avih.edu.in',
        fullName: 'Test Student',
        department: 'CSE',
        verificationStatus: 'verified',
        accountStatus: 'active',
        role: 'student',
      );

      expect(verifiedStudent.isVerified, true);
      expect(verifiedStudent.collegeId, 'avih-gunthapalli');
      expect(verifiedStudent.role, 'student');
      expect(verifiedStudent.isAdmin, false);
      expect(verifiedStudent.isModerator, false);
      expect(verifiedStudent.canAccessAdminPanel, false);
    });

    test('Admin student can access admin panel', () {
      final adminStudent = Student(
        studentId: 'admin_1',
        collegeId: 'avih-gunthapalli',
        collegeName: 'Avanthi Institute',
        officialEmail: 'admin@avih.edu.in',
        fullName: 'Campus Admin',
        department: 'Administration',
        verificationStatus: 'verified',
        accountStatus: 'active',
        role: 'admin',
      );

      expect(adminStudent.isVerified, true);
      expect(adminStudent.isAdmin, true);
      expect(adminStudent.isModerator, false);
      expect(adminStudent.canAccessAdminPanel, true);
    });
  });
}