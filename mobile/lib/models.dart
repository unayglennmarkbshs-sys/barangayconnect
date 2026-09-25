class User {
  final int userId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? address;
  final String role;
  final String status;
  User({required this.userId, required this.fullName, required this.email,
        this.phoneNumber, this.address, required this.role, required this.status});

  factory User.fromJson(Map<String, dynamic> j) => User(
        userId: j['user_id'], fullName: j['full_name'] ?? '', email: j['email'] ?? '',
        phoneNumber: j['phone_number'], address: j['address'],
        role: j['role'] ?? 'resident', status: j['status'] ?? 'active',
      );
}

class Announcement {
  final int announcementId;
  final String title, content;
  final String? category;
  final String datePosted;
  final String? postedByName;
  Announcement({required this.announcementId, required this.title, required this.content,
        this.category, required this.datePosted, this.postedByName});

  factory Announcement.fromJson(Map<String, dynamic> j) => Announcement(
        announcementId: j['announcement_id'], title: j['title'] ?? '',
        content: j['content'] ?? '', category: j['category'],
        datePosted: j['date_posted'] ?? '', postedByName: j['posted_by_name'],
      );
}

class ServiceRequest {
  final int requestId;
  final String requestType, status;
  final String? purpose, description, residentName;
  final String dateSubmitted;
  ServiceRequest({required this.requestId, required this.requestType, required this.status,
        this.purpose, this.description, this.residentName, required this.dateSubmitted});

  factory ServiceRequest.fromJson(Map<String, dynamic> j) => ServiceRequest(
        requestId: j['request_id'],
        requestType: j['request_type'] ?? '',
        status: j['status'] ?? 'pending',
        purpose: j['purpose'], description: j['description'],
        residentName: j['resident_name'],
        dateSubmitted: j['date_submitted'] ?? '',
      );
}

class Concern {
  final int concernId;
  final String title, description, status;
  final String? category, residentName;
  final String dateSubmitted;
  Concern({required this.concernId, required this.title, required this.description,
        required this.status, this.category, this.residentName, required this.dateSubmitted});

  factory Concern.fromJson(Map<String, dynamic> j) => Concern(
        concernId: j['concern_id'], title: j['title'] ?? '',
        description: j['description'] ?? '', status: j['status'] ?? 'pending',
        category: j['category'], residentName: j['resident_name'],
        dateSubmitted: j['date_submitted'] ?? '',
      );
}

class EmergencyContact {
  final int contactId;
  final String name, category, phoneNumber;
  final String? address;
  EmergencyContact({required this.contactId, required this.name,
        required this.category, required this.phoneNumber, this.address});

  factory EmergencyContact.fromJson(Map<String, dynamic> j) => EmergencyContact(
        contactId: j['contact_id'], name: j['name'] ?? '',
        category: j['category'] ?? '', phoneNumber: j['phone_number'] ?? '',
        address: j['address'],
      );
}

class AppNotification {
  final int notificationId;
  final String title, message, type;
  final bool isRead;
  final String dateSent;
  AppNotification({required this.notificationId, required this.title,
        required this.message, required this.type, required this.isRead,
        required this.dateSent});

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        notificationId: j['notification_id'], title: j['title'] ?? '',
        message: j['message'] ?? '', type: j['type'] ?? '',
        isRead: j['is_read'] == true || j['is_read'] == 1,
        dateSent: j['date_sent'] ?? '',
      );
}
