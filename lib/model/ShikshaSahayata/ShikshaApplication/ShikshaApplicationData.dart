import 'package:mpm/model/ShikshaSahayata/ShikshaApplication/Education.dart';
import 'package:mpm/model/ShikshaSahayata/ShikshaApplication/FamilyMember.dart';
import 'package:mpm/model/ShikshaSahayata/ShikshaApplication/ReceivedLoan.dart';
import 'package:mpm/model/ShikshaSahayata/ShikshaApplication/ReferredMember.dart';
import 'package:mpm/model/ShikshaSahayata/ShikshaApplication/RequestedLoanEducation.dart';

class ShikshaApplicationData {
  final String? shikshaApplicantId;
  final String? applicantFirstName;
  final String? applicantMiddleName;
  final String? applicantLastName;
  final String? fullName;
  final String? mobile;
  final String? email;
  final String? dateOfBirth;
  final String? age;
  final String? maritalStatusId;
  final String? maritalStatusName;
  final String? applicantAddress;
  final String? applicantCityName;
  final String? applicantStateName;
  final String? applicantFatherName;
  final String? applicantMotherName;
  final String? fatherEmail;
  final String? fatherMobile;

  final List<FamilyMember>? familyMembers;
  final List<Education>? education;
  final List<RequestedLoanEducation>? requestedLoanEducation;
  final List<ReceivedLoan>? receivedLoans;
  final List<ReferredMember>? referredMembers;

  ShikshaApplicationData({
    this.shikshaApplicantId,
    this.applicantFirstName,
    this.applicantMiddleName,
    this.applicantLastName,
    this.fullName,
    this.mobile,
    this.email,
    this.dateOfBirth,
    this.age,
    this.maritalStatusId,
    this.maritalStatusName,
    this.applicantAddress,
    this.applicantCityName,
    this.applicantStateName,
    this.applicantFatherName,
    this.applicantMotherName,
    this.fatherEmail,
    this.fatherMobile,
    this.familyMembers,
    this.education,
    this.requestedLoanEducation,
    this.receivedLoans,
    this.referredMembers,
  });

  factory ShikshaApplicationData.fromJson(Map<String, dynamic> json) {
    return ShikshaApplicationData(
      shikshaApplicantId: json['shiksha_applicant_id']?.toString(),
      applicantFirstName: json['applicant_first_name']?.toString(),
      applicantMiddleName: json['applicant_middle_name']?.toString(),
      applicantLastName: json['applicant_last_name']?.toString(),
      fullName: json['full_name']?.toString(),
      mobile: json['mobile']?.toString(),
      email: json['email']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      age: json['age']?.toString(),
      maritalStatusId: json['marital_status_id']?.toString(),
      maritalStatusName: json['marital_status_name']?.toString(),
      applicantAddress: json['applicant_address']?.toString(),
      applicantCityName: json['applicant_city_name']?.toString(),
      applicantStateName: json['applicant_state_name']?.toString(),
      applicantFatherName: json['applicant_father_name']?.toString(),
      applicantMotherName: json['applicant_mother_name']?.toString(),
      fatherEmail: json['father_email']?.toString(),
      fatherMobile: json['father_mobile']?.toString(),

      familyMembers: json['family_members'] != null
          ? List<FamilyMember>.from(
          json['family_members'].map((x) => FamilyMember.fromJson(x)))
          : [],

      education: json['education'] != null
          ? List<Education>.from(
          json['education'].map((x) => Education.fromJson(x)))
          : [],

      requestedLoanEducation: json['requested_loan_education'] != null
          ? List<RequestedLoanEducation>.from(
          json['requested_loan_education']
              .map((x) => RequestedLoanEducation.fromJson(x)))
          : [],

      receivedLoans: json['received_loans'] != null
          ? List<ReceivedLoan>.from(
          json['received_loans']
              .map((x) => ReceivedLoan.fromJson(x)))
          : [],

      referredMembers: json['referred_members'] != null
          ? List<ReferredMember>.from(
          json['referred_members']
              .map((x) => ReferredMember.fromJson(x)))
          : [],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shiksha_applicant_id': shikshaApplicantId,
      'applicant_first_name': applicantFirstName,
      'applicant_middle_name': applicantMiddleName,
      'applicant_last_name': applicantLastName,
      'full_name': fullName,
      'mobile': mobile,
      'email': email,
      'date_of_birth': dateOfBirth,
      'age': age,
      'marital_status_id': maritalStatusId,
      'marital_status_name': maritalStatusName,
      'applicant_address': applicantAddress,
      'applicant_city_name': applicantCityName,
      'applicant_state_name': applicantStateName,
      'applicant_father_name': applicantFatherName,
      'applicant_mother_name': applicantMotherName,
      'father_email': fatherEmail,
      'father_mobile': fatherMobile,
      'family_members': familyMembers?.map((x) => x.toJson()).toList(),
      'education': education?.map((x) => x.toJson()).toList(),
      'requested_loan_education':
      requestedLoanEducation?.map((x) => x.toJson()).toList(),
      'received_loans': receivedLoans?.map((x) => x.toJson()).toList(),
      'referred_members':
      referredMembers?.map((x) => x.toJson()).toList(),

    };
  }
}
