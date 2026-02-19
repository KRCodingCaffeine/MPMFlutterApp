import 'package:mpm/model/ShikshaSahayata/ShikshaApplication/Education.dart';
import 'package:mpm/model/ShikshaSahayata/ShikshaApplication/FamilyMember.dart';
import 'package:mpm/model/ShikshaSahayata/ShikshaApplication/ReceivedLoan.dart';
import 'package:mpm/model/ShikshaSahayata/ShikshaApplication/ReferredMember.dart';
import 'package:mpm/model/ShikshaSahayata/ShikshaApplicationsByAppliedBy/RequestedLoanEducationAppliedBy.dart';

class ShikshaApplicationsByAppliedByData {
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
  final String? applicantCityId;
  final String? applicantStateId;
  final String? applicantCityName;
  final String? applicantStateName;
  final String? applicantFatherName;
  final String? applicantMotherName;
  final String? fatherEmail;
  final String? fatherMobile;
  final String? applicantAadharCardDocument;
  final String? applicantFatherPanCardDocument;
  final String? applicantRationCardDocument;
  final String? appliedBy;
  final String? appliedByMemberCode;
  final String? appliedByFirstName;
  final String? appliedByMiddleName;
  final String? appliedByLastName;
  final String? appliedByFullName;
  final String? appliedByEmail;
  final String? appliedByMobile;
  final String? createdBy;
  final String? updatedBy;
  final String? createdAt;
  final String? updatedAt;

  final List<FamilyMember>? familyMembers;
  final List<Education>? education;
  final List<RequestedLoanEducationAppliedBy>? requestedLoanEducationAppliedBy;
  final List<ReceivedLoan>? receivedLoans;
  final List<ReferredMember>? referredMembers;

  ShikshaApplicationsByAppliedByData({
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
    this.applicantCityId,
    this.applicantStateId,
    this.applicantCityName,
    this.applicantStateName,
    this.applicantFatherName,
    this.applicantMotherName,
    this.fatherEmail,
    this.fatherMobile,
    this.applicantAadharCardDocument,
    this.applicantFatherPanCardDocument,
    this.applicantRationCardDocument,
    this.appliedBy,
    this.appliedByMemberCode,
    this.appliedByFirstName,
    this.appliedByMiddleName,
    this.appliedByLastName,
    this.appliedByFullName,
    this.appliedByEmail,
    this.appliedByMobile,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.familyMembers,
    this.education,
    this.requestedLoanEducationAppliedBy,
    this.receivedLoans,
    this.referredMembers,
  });

  factory ShikshaApplicationsByAppliedByData.fromJson(Map<String, dynamic> json) {
    return ShikshaApplicationsByAppliedByData(
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
      applicantCityId: json['applicant_city_id']?.toString(),
      applicantStateId: json['applicant_state_id']?.toString(),
      applicantCityName: json['applicant_city_name']?.toString(),
      applicantStateName: json['applicant_state_name']?.toString(),
      applicantFatherName: json['applicant_father_name']?.toString(),
      applicantMotherName: json['applicant_mother_name']?.toString(),
      fatherEmail: json['father_email']?.toString(),
      fatherMobile: json['father_mobile']?.toString(),
      applicantAadharCardDocument:
      json['applicant_aadhar_card_document']?.toString(),
      applicantFatherPanCardDocument:
      json['applicant_father_pan_card_document']?.toString(),
      applicantRationCardDocument:
      json['applicant_ration_card_document']?.toString(),
      appliedBy: json['applied_by']?.toString(),
      appliedByMemberCode: json['applied_by_member_code']?.toString(),
      appliedByFirstName: json['applied_by_first_name']?.toString(),
      appliedByMiddleName: json['applied_by_middle_name']?.toString(),
      appliedByLastName: json['applied_by_last_name']?.toString(),
      appliedByFullName: json['applied_by_full_name']?.toString(),
      appliedByEmail: json['applied_by_email']?.toString(),
      appliedByMobile: json['applied_by_mobile']?.toString(),
      createdBy: json['created_by']?.toString(),
      updatedBy: json['updated_by']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      familyMembers: json['family_members'] != null
          ? List<FamilyMember>.from(
          json['family_members'].map((x) => FamilyMember.fromJson(x)))
          : [],
      education: json['education'] != null
          ? List<Education>.from(
          json['education'].map((x) => Education.fromJson(x)))
          : [],
      requestedLoanEducationAppliedBy: json['requested_loan_education'] != null
          ? List<RequestedLoanEducationAppliedBy>.from(json['requested_loan_education']
          .map((x) => RequestedLoanEducationAppliedBy.fromJson(x)))
          : [],
      receivedLoans: json['received_loans'] != null
          ? List<ReceivedLoan>.from(
          json['received_loans'].map((x) => ReceivedLoan.fromJson(x)))
          : [],
      referredMembers: json['referred_members'] != null
          ? List<ReferredMember>.from(
          json['referred_members'].map((x) => ReferredMember.fromJson(x)))
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
      'applicant_city_id': applicantCityId,
      'applicant_state_id': applicantStateId,
      'applicant_city_name': applicantCityName,
      'applicant_state_name': applicantStateName,
      'applicant_father_name': applicantFatherName,
      'applicant_mother_name': applicantMotherName,
      'father_email': fatherEmail,
      'father_mobile': fatherMobile,
      'applicant_aadhar_card_document': applicantAadharCardDocument,
      'applicant_father_pan_card_document': applicantFatherPanCardDocument,
      'applicant_ration_card_document': applicantRationCardDocument,
      'applied_by': appliedBy,
      'applied_by_member_code': appliedByMemberCode,
      'applied_by_first_name': appliedByFirstName,
      'applied_by_middle_name': appliedByMiddleName,
      'applied_by_last_name': appliedByLastName,
      'applied_by_full_name': appliedByFullName,
      'applied_by_email': appliedByEmail,
      'applied_by_mobile': appliedByMobile,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'family_members': familyMembers?.map((x) => x.toJson()).toList(),
      'education': education?.map((x) => x.toJson()).toList(),
      'requested_loan_education':
      requestedLoanEducationAppliedBy?.map((x) => x.toJson()).toList(),
      'received_loans': receivedLoans?.map((x) => x.toJson()).toList(),
      'referred_members': referredMembers?.map((x) => x.toJson()).toList(),
    };
  }
}
