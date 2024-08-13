import 'dart:convert';

class UserModel {
  String? userID;
  String? userPassword;
  String? userName;
  String? cellPhone;
  String? companyName;
  String? dateOfJoining;
  String? departmentName;
  String? designationName;
  String? email;
  String? jobTypeName;
  String? isSuspanded;

  UserModel({
    this.userID,
    this.userPassword,
    this.userName,
    this.cellPhone,
    this.companyName,
    this.dateOfJoining,
    this.departmentName,
    this.designationName,
    this.email,
    this.jobTypeName,
    this.isSuspanded,
  });

  UserModel copyWith({
    String? userID,
    String? userPassword,
    String? userName,
    String? cellPhone,
    String? companyName,
    String? dateOfJoining,
    String? departmentName,
    String? designationName,
    String? email,
    String? jobTypeName,
  }) =>
      UserModel(
        cellPhone: cellPhone ?? this.cellPhone,
        companyName: companyName ?? this.companyName,
        dateOfJoining: dateOfJoining ?? this.dateOfJoining,
        departmentName: departmentName ?? this.departmentName,
        designationName: designationName ?? this.designationName,
        email: email ?? this.email,
        jobTypeName: jobTypeName ?? this.jobTypeName,
        userName: userName ?? this.userName,
        userID: userID ?? this.userID,
        userPassword: userPassword ?? this.userPassword,
        isSuspanded: isSuspanded ?? this.isSuspanded,
      );

  factory UserModel.fromJson(String str) => UserModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory UserModel.fromMap(Map<String, dynamic> json) => UserModel(
        userID: json["user_id"],
        userPassword: json['password'],
        cellPhone: json["cell_phone"],
        companyName: json["company_name"],
        dateOfJoining: json["date_of_joining"],
        departmentName: json["department_name"],
        designationName: json["designation_name"],
        email: json["email"],
        jobTypeName: json["job_type_name"],
        userName: json["user_name"],
        isSuspanded: json['isSuspanded'],
      );

  Map<String, dynamic> toMap() => {
        "user_id": userID,
        "password": userPassword,
        "cell_phone": cellPhone,
        "company_name": companyName,
        "date_of_joining": dateOfJoining,
        "department_name": departmentName,
        "designation_name": designationName,
        "email": email,
        "job_type_name": jobTypeName,
        "user_name": userName,
        "isSuspanded": isSuspanded,
      };
}
