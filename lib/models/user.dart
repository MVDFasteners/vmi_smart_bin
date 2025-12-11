class UserModel {
  final String? userId;
  final String? fullName;
  final String? image;
  final String? department;
  final int? stockUser;
  final int? accountUser;
  final int? attendanceUser;
  final int? dashboardUser;
  final String? employeeId;
  final String? customerId;
  final String? customerName;
  final String? company;

  final List<EmailModel> emails; // 👈 NEW

  UserModel({
    this.userId,
    this.fullName,
    this.image,
    this.department,
    this.company,
    this.stockUser,
    this.accountUser,
    this.attendanceUser,
    this.dashboardUser,
    this.employeeId,
    this.customerId,
    this.customerName,

    this.emails = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print(json["user_id"]);

    final emailList = (json['emails'] as List? ?? [])
        .map((e) => EmailModel.fromJson(e))
        .toList();

    return UserModel(
      userId: json['user_id'] ?? '',
      fullName: json['full_name'] ?? '',
      image: json['image'] ?? '',
      department: json['department'] ?? '',
      company: json['custom_company'] ?? '',
      employeeId: json['employee_id'] ?? '',
      customerId: json['customer_id'] ?? '',
      customerName: json['customer_name'] ?? '',
      stockUser: int.tryParse(json['stock_user']?.toString() ?? '0'),
      accountUser: int.tryParse(json['accounts_user']?.toString() ?? '0'),
      attendanceUser: int.tryParse(json['hr_user']?.toString() ?? '0'),
      dashboardUser: int.tryParse(json['dashbord_user']?.toString() ?? '0'),

      emails: emailList, // 👈 add here
    );
  }
}

class EmailModel {
  final String email;
  final String name1;

  EmailModel({required this.email, required this.name1});

  factory EmailModel.fromJson(Map<String, dynamic> json) {
    return EmailModel(email: json['email'] ?? '', name1: json['name1'] ?? '');
  }
}
