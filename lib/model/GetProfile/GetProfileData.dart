import 'package:mpm/model/GetProfile/Address.dart';
import 'package:mpm/model/GetProfile/BusinessInfo.dart';
import 'package:mpm/model/GetProfile/FamilyHeadMemberData.dart';
import 'package:mpm/model/GetProfile/FamilyMembersData.dart';
import 'package:mpm/model/GetProfile/Occupation.dart';
import 'package:mpm/model/GetProfile/Qualification.dart';

class GetProfileData {
  final String? memberId;
  final String? memberCode;
  final String? memberSalutaitonId;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? mobile;
  final String? whatsappNumber;
  final String? email;
  final String? password;
  final String? dob;
  final String? proposerId;
  final String? maritalStatusId;
  final String? marriageAnniversaryDate;
  final String? genderId;
  final String? bloodGroupId;
  final String? bloodGroup;
  final String? fatherName;
  final String? motherName;
  final String? addressProofTypeId;
  final String? addressProof;
  final String? profileImage;
  final String? otp;
  final String? verifyOtpStatus;
  final String? mobileVerifyStatus;
  final String? emailVerifyStatus;
  final String? emailVerificationToken;
  final String? sangathanApprovalStatus;
  final String? vyavasthapikaApprovalStatus;
  final String? memberStatusId;
  final String? deceasedReason;
  final String? deceasedDate;
  final String? membershipApprovalStatusId;
  final String? membershipTypeId;
  final String? isPaymentReceived;
  final String? maritalStatus;
  final String? genderName;
  final String? tempId;
  final String? isJangana;
  final String? isSaraswaniBlocked;
  final String? saraswaniOptionId;
  final String? saraswaniOption;
  final String? memberApplicationDocument;
  final String? membershipAllotmentDate;
  final String? deviceToken;
  final String? familyHeadMemberId;
  final String? isSurnameExists;
  final String? surnameId;
  final String? createdBy;
  final String? createdAt;
  final String? updatedBy;
  final String? updatedAt;
  final String? memberApprovalStatusName;
  final String? memberStatusName;
  final String? profileImagePath;
  final String? addressProofPath;
  final String? documentType;

  final Address? address;
  final List<FamilyMembersData>? familyMembersData;
  final FamilyHeadMemberData? familyHeadMemberData;
  final List<Qualification>? qualification;
  final List<Occupation>? occupation;
  final List<BusinessInfo>? businessInfo;

  GetProfileData({
    this.memberId,
    this.memberCode,
    this.memberSalutaitonId,
    this.firstName,
    this.middleName,
    this.lastName,
    this.mobile,
    this.whatsappNumber,
    this.email,
    this.password,
    this.dob,
    this.proposerId,
    this.maritalStatusId,
    this.marriageAnniversaryDate,
    this.genderId,
    this.bloodGroupId,
    this.bloodGroup,
    this.fatherName,
    this.motherName,
    this.addressProofTypeId,
    this.addressProof,
    this.profileImage,
    this.otp,
    this.verifyOtpStatus,
    this.mobileVerifyStatus,
    this.emailVerifyStatus,
    this.emailVerificationToken,
    this.sangathanApprovalStatus,
    this.vyavasthapikaApprovalStatus,
    this.memberStatusId,
    this.deceasedReason,
    this.deceasedDate,
    this.membershipApprovalStatusId,
    this.membershipTypeId,
    this.isPaymentReceived,
    this.maritalStatus,
    this.genderName,
    this.tempId,
    this.isJangana,
    this.saraswaniOptionId,
    this.saraswaniOption,
    this.isSaraswaniBlocked,
    this.memberApplicationDocument,
    this.membershipAllotmentDate,
    this.deviceToken,
    this.familyHeadMemberId,
    this.isSurnameExists,
    this.surnameId,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
    this.memberApprovalStatusName,
    this.memberStatusName,
    this.profileImagePath,
    this.addressProofPath,
    this.documentType,
    this.address,
    this.familyMembersData,
    this.familyHeadMemberData,
    this.qualification,
    this.occupation,
    this.businessInfo,
  });

  factory GetProfileData.fromJson(Map<String, dynamic> json) {
    return GetProfileData(
      memberId: json['member_id']?.toString(),
      memberCode: json['member_code']?.toString(),
      memberSalutaitonId: json['member_salutaiton_id']?.toString(),
      firstName: json['first_name']?.toString(),
      middleName: json['middle_name']?.toString(),
      lastName: json['last_name']?.toString(),
      mobile: json['mobile']?.toString(),
      whatsappNumber: json['whatsapp_number']?.toString(),
      email: json['email']?.toString(),
      password: json['password']?.toString(),
      dob: json['dob']?.toString(),
      proposerId: json['proposer_id']?.toString(),
      maritalStatusId: json['marital_status_id']?.toString(),
      marriageAnniversaryDate: json['marriage_anniversary_date']?.toString(),
      genderId: json['gender_id']?.toString(),
      bloodGroupId: json['blood_group_id']?.toString(),
      bloodGroup: json['blood_group']?.toString(),
      fatherName: json['father_name']?.toString(),
      motherName: json['mother_name']?.toString(),
      addressProofTypeId: json['address_proof_type_id']?.toString(),
      addressProof: json['address_proof']?.toString(),
      profileImage: json['profile_image']?.toString(),
      otp: json['otp']?.toString(),
      verifyOtpStatus: json['verify_otp_status']?.toString(),
      mobileVerifyStatus: json['mobile_verify_status']?.toString(),
      emailVerifyStatus: json['email_verify_status']?.toString(),
      emailVerificationToken: json['email_verification_token']?.toString(),
      sangathanApprovalStatus: json['sangathan_approval_status']?.toString(),
      vyavasthapikaApprovalStatus: json['vyavasthapika_approval_status']?.toString(),
      memberStatusId: json['member_status_id']?.toString(),
      deceasedReason: json['deceased_reason']?.toString(),
      deceasedDate: json['deceased_date']?.toString(),
      membershipApprovalStatusId: json['membership_approval_status_id']?.toString(),
      membershipTypeId: json['membership_type_id']?.toString(),
      isPaymentReceived: json['is_payment_received']?.toString(),
      maritalStatus: json['marital_status']?.toString(),
      genderName: json['gender_name']?.toString(),
      tempId: json['temp_id']?.toString(),
      isJangana: json['is_jangana']?.toString(),
      saraswaniOptionId: json['saraswani_option_id']?.toString(),
      saraswaniOption: json['saraswani_option']?.toString(),
      isSaraswaniBlocked: json['is_saraswani_blocked']?.toString(),
      memberApplicationDocument: json['member_application_document']?.toString(),
      membershipAllotmentDate: json['membership_allotment_date']?.toString(),
      deviceToken: json['device_token']?.toString(),
      familyHeadMemberId: json['family_head_member_id']?.toString(),
      isSurnameExists: json['is_surname_exists']?.toString(),
      surnameId: json['surname_id']?.toString(),
      createdBy: json['created_by']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedBy: json['updated_by']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      memberApprovalStatusName: json['member_approval_status_name']?.toString(),
      memberStatusName: json['member_status_name']?.toString(),
      profileImagePath: json['profile_image_path']?.toString(),
      addressProofPath: json['address_proof_path']?.toString(),
      documentType: json['document_type']?.toString(),
      address: json['address'] != null
          ? (json['address'] is List
              ? (json['address'] as List).isNotEmpty
                  ? Address.fromJson(json['address'][0] as Map<String, dynamic>)
                  : null
              : Address.fromJson(json['address'] as Map<String, dynamic>))
          : null,
      familyMembersData: json['family_members_data'] != null
          ? List<FamilyMembersData>.from(
          (json['family_members_data'] as List)
              .map((x) => FamilyMembersData.fromJson(x)))
          : null,
      familyHeadMemberData: json['family_head_member_data'] != null
          ? FamilyHeadMemberData.fromJson(json['family_head_member_data'])
          : null,
      qualification: json['qualification'] != null
          ? List<Qualification>.from(
          (json['qualification'] as List)
              .map((x) => Qualification.fromJson(x)))
          : null,
      occupation: json['occupation'] != null
          ? List<Occupation>.from(
          (json['occupation'] as List)
              .map((x) => Occupation.fromJson(x)))
          : null,
      businessInfo: json['business_info'] != null
          ? List<BusinessInfo>.from(
          (json['business_info'] as List)
              .map((x) => BusinessInfo.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'member_code': memberCode,
      'member_salutaiton_id': memberSalutaitonId,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'mobile': mobile,
      'whatsapp_number': whatsappNumber,
      'email': email,
      'password': password,
      'dob': dob,
      'proposer_id': proposerId,
      'marital_status_id': maritalStatusId,
      'marriage_anniversary_date': marriageAnniversaryDate,
      'gender_id': genderId,
      'blood_group_id': bloodGroupId,
      'blood_group': bloodGroup,
      'father_name': fatherName,
      'mother_name': motherName,
      'address_proof_type_id': addressProofTypeId,
      'address_proof': addressProof,
      'profile_image': profileImage,
      'otp': otp,
      'verify_otp_status': verifyOtpStatus,
      'mobile_verify_status': mobileVerifyStatus,
      'email_verify_status': emailVerifyStatus,
      'email_verification_token': emailVerificationToken,
      'sangathan_approval_status': sangathanApprovalStatus,
      'vyavasthapika_approval_status': vyavasthapikaApprovalStatus,
      'member_status_id': memberStatusId,
      'deceased_reason': deceasedReason,
      'deceased_date': deceasedDate,
      'membership_approval_status_id': membershipApprovalStatusId,
      'membership_type_id': membershipTypeId,
      'is_payment_received': isPaymentReceived,
      'marital_status': maritalStatus,
      'gender_name': genderName,
      'temp_id': tempId,
      'is_jangana': isJangana,
      'saraswani_option_id': saraswaniOptionId,
      'saraswani_option': saraswaniOption,
      'is_saraswani_blocked': isSaraswaniBlocked,
      'member_application_document': memberApplicationDocument,
      'membership_allotment_date': membershipAllotmentDate,
      'device_token': deviceToken,
      'family_head_member_id': familyHeadMemberId,
      'is_surname_exists': isSurnameExists,
      'surname_id': surnameId,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_by': updatedBy,
      'updated_at': updatedAt,
      'member_approval_status_name': memberApprovalStatusName,
      'member_status_name': memberStatusName,
      'profile_image_path': profileImagePath,
      'address_proof_path': addressProofPath,
      'document_type': documentType,
      'address': address?.toJson(),
      'family_members_data': familyMembersData?.map((x) => x.toJson()).toList(),
      'family_head_member_data': familyHeadMemberData?.toJson(),
      'qualification': qualification?.map((x) => x.toJson()).toList(),
      'occupation': occupation?.map((x) => x.toJson()).toList(),
      'business_info': businessInfo?.map((x) => x.toJson()).toList(),
    };
  }
}
