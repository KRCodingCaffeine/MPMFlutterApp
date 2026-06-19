import 'package:mpm/model/ShikshaSahayata/ShikshaApplication/Education.dart';
import 'package:mpm/model/ShikshaSahayata/ShikshaApplication/FamilyMember.dart';
import 'package:mpm/model/ShikshaSahayata/ShikshaApplication/LoanRepayment.dart';
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
  final String? landline;
  final String? dateOfBirth;
  final String? age;
  final String? maritalStatusId;
  final String? maritalStatusName;
  final String? applicantAddress;
  final String? applicantCityId;
  final String? applicantStateId;
  final String? applicantCityName;
  final String? applicantStateName;
  final String? applicantFullAddress;
  final String? applicantFatherName;
  final String? applicantMotherName;
  final String? fatherEmail;
  final String? fatherMobile;
  final String? fatherAddress;
  final String? fatherCityId;
  final String? fatherCityName;
  final String? fatherStateId;
  final String? fatherStateName;
  final String? fatherFullAddress;
  final String? applicantAadharCardDocument;
  final String? applicantFatherPanCardDocument;
  final String? fatherAnnualIncomeDocument;
  final String? overseasFatherAnnualIncomeDocument;
  final String? applicantRationCardDocument;
  final String? applicantPassportDocument;
  final String? applicantVisaDocument;
  final String? applicantPanCardDocument;

  final List<FamilyMember>? familyMembers;
  final List<Education>? education;
  final List<RequestedLoanEducation>? requestedLoanEducation;
  final List<ReceivedLoan>? receivedLoans;
  final List<LoanRepayment>? loanRepayments;
  final List<ReferredMember>? referredMembers;

  ShikshaApplicationData({
    this.shikshaApplicantId,
    this.applicantFirstName,
    this.applicantMiddleName,
    this.applicantLastName,
    this.fullName,
    this.mobile,
    this.email,
    this.landline,
    this.dateOfBirth,
    this.age,
    this.maritalStatusId,
    this.maritalStatusName,
    this.applicantAddress,
    this.applicantCityId,
    this.applicantStateId,
    this.applicantCityName,
    this.applicantStateName,
    this.applicantFullAddress,
    this.applicantFatherName,
    this.applicantMotherName,
    this.fatherEmail,
    this.fatherMobile,
    this.fatherAddress,
    this.fatherCityId,
    this.fatherCityName,
    this.fatherStateId,
    this.fatherStateName,
    this.fatherFullAddress,
    this.applicantAadharCardDocument,
    this.applicantFatherPanCardDocument,
    this.fatherAnnualIncomeDocument,
    this.overseasFatherAnnualIncomeDocument,
    this.applicantRationCardDocument,
    this.applicantPassportDocument,
    this.applicantVisaDocument,
    this.applicantPanCardDocument,
    this.familyMembers,
    this.education,
    this.requestedLoanEducation,
    this.receivedLoans,
    this.loanRepayments,
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
      landline: json['landline']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      age: json['age']?.toString(),
      maritalStatusId: json['marital_status_id']?.toString(),
      maritalStatusName: json['marital_status_name']?.toString(),
      applicantAddress: json['applicant_address']?.toString(),
      applicantCityId: json['applicant_city_id']?.toString(),
      applicantStateId: json['applicant_state_id']?.toString(),
      applicantCityName: json['applicant_city_name']?.toString(),
      applicantStateName: json['applicant_state_name']?.toString(),
      applicantFullAddress: json['applicant_full_address']?.toString(),
      applicantFatherName: json['applicant_father_name']?.toString(),
      applicantMotherName: json['applicant_mother_name']?.toString(),
      fatherEmail: json['father_email']?.toString(),
      fatherMobile: json['father_mobile']?.toString(),
      fatherAddress: json['father_address']?.toString(),
      fatherCityId: json['father_city_id']?.toString(),
      fatherCityName: json['father_city_name']?.toString(),
      fatherStateId: json['father_state_id']?.toString(),
      fatherStateName: json['father_state_name']?.toString(),
      fatherFullAddress: json['father_full_address']?.toString(),
      applicantAadharCardDocument:
          json['applicant_aadhar_card_document']?.toString(),
      applicantFatherPanCardDocument:
          json['applicant_father_pan_card_document']?.toString(),
      fatherAnnualIncomeDocument:
          json['father_annual_income_document']?.toString(),
      overseasFatherAnnualIncomeDocument:
          json['overseas_father_annual_income_document']?.toString(),
      applicantRationCardDocument:
          json['applicant_ration_card_document']?.toString(),
      applicantPassportDocument:
          json['applicant_passport_document']?.toString(),
      applicantVisaDocument: json['applicant_visa_document']?.toString(),
      applicantPanCardDocument: json['applicant_pan_card_document']?.toString(),
      familyMembers: json['family_members'] != null
          ? List<FamilyMember>.from(
              json['family_members'].map((x) => FamilyMember.fromJson(x)))
          : [],
      education: json['education'] != null
          ? List<Education>.from(
              json['education'].map((x) => Education.fromJson(x)))
          : [],
      requestedLoanEducation: json['requested_loan_education'] != null
          ? List<RequestedLoanEducation>.from(json['requested_loan_education']
              .map((x) => RequestedLoanEducation.fromJson(x)))
          : [],
      receivedLoans: json['received_loans'] != null
          ? List<ReceivedLoan>.from(
              json['received_loans'].map((x) => ReceivedLoan.fromJson(x)))
          : [],
      loanRepayments: json['loan_repayments'] != null
          ? List<LoanRepayment>.from(
              json['loan_repayments'].map((x) => LoanRepayment.fromJson(x)))
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
      'landline': landline,
      'date_of_birth': dateOfBirth,
      'age': age,
      'marital_status_id': maritalStatusId,
      'marital_status_name': maritalStatusName,
      'applicant_address': applicantAddress,
      'applicant_city_id': applicantCityId,
      'applicant_state_id': applicantStateId,
      'applicant_city_name': applicantCityName,
      'applicant_state_name': applicantStateName,
      'applicant_full_address': applicantFullAddress,
      'applicant_father_name': applicantFatherName,
      'applicant_mother_name': applicantMotherName,
      'father_email': fatherEmail,
      'father_mobile': fatherMobile,
      'father_address': fatherAddress,
      'father_city_id': fatherCityId,
      'father_city_name': fatherCityName,
      'father_state_id': fatherStateId,
      'father_state_name': fatherStateName,
      'father_full_address': fatherFullAddress,
      'applicant_aadhar_card_document': applicantAadharCardDocument,
      'applicant_father_pan_card_document': applicantFatherPanCardDocument,
      'father_annual_income_document': fatherAnnualIncomeDocument,
      'overseas_father_annual_income_document':
          overseasFatherAnnualIncomeDocument,
      'applicant_ration_card_document': applicantRationCardDocument,
      'applicant_passport_document': applicantPassportDocument,
      'applicant_visa_document': applicantVisaDocument,
      'applicant_pan_card_document': applicantPanCardDocument,
      'family_members': familyMembers?.map((x) => x.toJson()).toList(),
      'education': education?.map((x) => x.toJson()).toList(),
      'requested_loan_education':
          requestedLoanEducation?.map((x) => x.toJson()).toList(),
      'received_loans': receivedLoans?.map((x) => x.toJson()).toList(),
      'loan_repayments': loanRepayments?.map((x) => x.toJson()).toList(),
      'referred_members': referredMembers?.map((x) => x.toJson()).toList(),
    };
  }
}
