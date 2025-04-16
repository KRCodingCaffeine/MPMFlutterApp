import 'package:mpm/model/GetProfile/Address.dart';
import 'package:mpm/model/GetProfile/BusinessInfo.dart';
import 'package:mpm/model/GetProfile/FamilyHeadMemberData.dart';
import 'package:mpm/model/GetProfile/FamilyMembersData.dart';
import 'package:mpm/model/GetProfile/Occupation.dart';
import 'package:mpm/model/GetProfile/Qualification.dart';

class GetProfileData{
  var memberId;
  var memberCode;
  var memberSalutaitonId;
  var firstName;
  var middleName;
  var lastName;
  var mobile;
  var whatsappNumber;
  var email;
  var password;
  var dob;
  var proposerId;
  var maritalStatusId;
  var marriageAnniversaryDate;
  var genderId;
  var bloodGroupId;
  var blood_group;
  var fatherName;
  var motherName;
  var addressProofTypeId;
  var addressProof;
  var profileImage;
  var otp;
  var verifyOtpStatus;
  var mobileVerifyStatus;
  var sangathanApprovalStatus;
  var vyavasthapikaApprovalStatus;
  var memberStatusId;
  var membershipApprovalStatusId;
  var membershipTypeId;
  // var familyHeadMemberId;
  var is_payment_received;
  var marital_status;
  var gender_name;
  var tempId;
  var isJangana;
  var saraswaniOptionId;
  var createdBy;
  var createdAt;
  var updatedBy;
  var updatedAt;
  var memberApprovalStatusName;
  var memberStatusName;
  var profileImagePath;
  var addressProofPath;
  var document_type;

  List<FamilyMembersData>? familyMembersData;
  FamilyHeadMemberData? familyHeadMemberData;
  List<Qualification>? qualification;
  Occupation? occupation;
  List<BusinessInfo>? businessInfo;
  Address? address;
  GetProfileData(
      {this.memberId,
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
        this.blood_group,
        this.fatherName,
        this.motherName,
        this.addressProofTypeId,
        this.addressProof,
        this.profileImage,
        this.otp,
        this.verifyOtpStatus,
        this.mobileVerifyStatus,
        this.sangathanApprovalStatus,
        this.vyavasthapikaApprovalStatus,
        this.memberStatusId,
        this.membershipApprovalStatusId,
        this.membershipTypeId,
        // this.familyHeadMemberId,
        this.is_payment_received,
        this.tempId,
        this.isJangana,
        this.saraswaniOptionId,
        this.createdBy,
        this.createdAt,
        this.updatedBy,
        this.marital_status,
        this.gender_name,
        this.updatedAt,
        this.memberApprovalStatusName,
        this.memberStatusName,
        this.profileImagePath,
        this.addressProofPath,
        this.address,
        this.familyMembersData,
        this.familyHeadMemberData,
        this.qualification,
        this.occupation,
        this.businessInfo,
        this.document_type
      });

  GetProfileData.fromJson(Map<String, dynamic> json) {
    memberId = json['member_id'];
    memberCode = json['member_code'];
    memberSalutaitonId = json['member_salutaiton_id'];
    firstName = json['first_name'];
    middleName = json['middle_name'];
    lastName = json['last_name'];
    mobile = json['mobile'];
    whatsappNumber = json['whatsapp_number'];
    email = json['email'];
    password = json['password'];
    dob = json['dob'];
    proposerId = json['proposer_id'];
    maritalStatusId = json['marital_status_id'];
    marriageAnniversaryDate = json['marriage_anniversary_date'];
    genderId = json['gender_id'];
    bloodGroupId = json['blood_group_id'];
    blood_group = json['blood_group'];
    fatherName = json['father_name'];
    motherName = json['mother_name'];
    addressProofTypeId = json['address_proof_type_id'];
    addressProof = json['address_proof'];
    profileImage = json['profile_image'];
    otp = json['otp'];
    verifyOtpStatus = json['verify_otp_status'];
    mobileVerifyStatus = json['mobile_verify_status'];
    sangathanApprovalStatus = json['sangathan_approval_status'];
    vyavasthapikaApprovalStatus = json['vyavasthapika_approval_status'];
    memberStatusId = json['member_status_id'];
    membershipApprovalStatusId = json['membership_approval_status_id'];
    membershipTypeId = json['membership_type_id'];
    //familyHeadMemberId = json['family_head_member_id'];
    is_payment_received = json['is_payment_received'];
    tempId = json['temp_id'];
    isJangana = json['is_jangana'];
    saraswaniOptionId = json['saraswani_option_id'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedBy = json['updated_by'];
    updatedAt = json['updated_at'];
    marital_status = json['marital_status'];
    gender_name = json['gender_name'];
    memberApprovalStatusName = json['member_approval_status_name'];
    memberStatusName = json['member_status_name'];
    profileImagePath = json['profile_image_path'];
    addressProofPath = json['address_proof_path'];
    document_type = json['document_type'];
    address = json['address'] != null ? new Address.fromJson(json['address']) : null;
    if (json['family_members_data'] != null) {
      familyMembersData = <FamilyMembersData>[];
      json['family_members_data'].forEach((v) {
        familyMembersData!.add(new FamilyMembersData.fromJson(v));
      });
    }
    familyHeadMemberData = json['family_head_member_data'] != null
        ? new FamilyHeadMemberData.fromJson(json['family_head_member_data'])
        : null;
    if (json['qualification'] != null) {
      qualification = <Qualification>[];
      json['qualification'].forEach((v) {
        qualification!.add(new Qualification.fromJson(v));
      });
    }
    occupation = json['occupation'] != null
        ? new Occupation.fromJson(json['occupation'])
        : null;
    if (json['business_info'] != null) {
      businessInfo = <BusinessInfo>[];
      json['business_info'].forEach((v) {
        businessInfo!.add(new BusinessInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['member_id'] = this.memberId;
    data['member_code'] = this.memberCode;
    data['member_salutaiton_id'] = this.memberSalutaitonId;
    data['first_name'] = this.firstName;
    data['middle_name'] = this.middleName;
    data['last_name'] = this.lastName;
    data['mobile'] = this.mobile;
    data['whatsapp_number'] = this.whatsappNumber;
    data['email'] = this.email;
    data['password'] = this.password;
    data['dob'] = this.dob;
    data['proposer_id'] = this.proposerId;
    data['marital_status_id'] = this.maritalStatusId;
    data['marriage_anniversary_date'] = this.marriageAnniversaryDate;
    data['gender_id'] = this.genderId;
    data['blood_group_id'] = this.bloodGroupId;
    data['blood_group'] = this.blood_group;
    data['father_name'] = this.fatherName;
    data['mother_name'] = this.motherName;
    data['address_proof_type_id'] = this.addressProofTypeId;
    data['document_type'] = this.document_type;
    data['address_proof'] = this.addressProof;
    data['profile_image'] = this.profileImage;
    data['otp'] = this.otp;
    data['verify_otp_status'] = this.verifyOtpStatus;
    data['mobile_verify_status'] = this.mobileVerifyStatus;
    data['sangathan_approval_status'] = this.sangathanApprovalStatus;
    data['vyavasthapika_approval_status'] = this.vyavasthapikaApprovalStatus;
    data['member_status_id'] = this.memberStatusId;
    data['membership_approval_status_id'] = this.membershipApprovalStatusId;
    data['membership_type_id'] = this.membershipTypeId;
    //data['family_head_member_id'] = this.familyHeadMemberId;
    data['is_payment_received'] =this.is_payment_received;
    data['temp_id'] = this.tempId;
    data['is_jangana'] = this.isJangana;
    data['saraswani_option_id'] = this.saraswaniOptionId;
    data['created_by'] = this.createdBy;
    data['created_at'] = this.createdAt;
    data['updated_by'] = this.updatedBy;
    data['updated_at'] = this.updatedAt;
    data['marital_status'] = this.marital_status;
    data['gender_name'] = this.gender_name;
    data['member_approval_status_name'] = this.memberApprovalStatusName;
    data['member_status_name'] = this.memberStatusName;
    data['profile_image_path'] = this.profileImagePath;
    data['address_proof_path'] = this.addressProofPath;
    if (this.address != null) {
      data['address'] = this.address!.toJson();
    }
    if (this.familyMembersData != null) {
      data['family_members_data'] =
          this.familyMembersData!.map((v) => v.toJson()).toList();
    }
    if (this.familyHeadMemberData != null) {
      data['family_head_member_data'] = this.familyHeadMemberData!.toJson();
    }
    if (this.qualification != null) {
      data['qualification'] =
          this.qualification!.map((v) => v.toJson()).toList();
    }
    if (this.occupation != null) {
      data['occupation'] = this.occupation!.toJson();
    }
    if (this.businessInfo != null) {
      data['business_info'] =
          this.businessInfo!.map((v) => v.toJson()).toList();
    }
    return data;
  }

}