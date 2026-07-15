class GetSeekerResumeData {
  String? seekerProfileId;
  String? memberId;
  String? resumePath;
  String? resumeUrl;

  GetSeekerResumeData({
    this.seekerProfileId,
    this.memberId,
    this.resumePath,
    this.resumeUrl,
  });

  GetSeekerResumeData.fromJson(Map<String, dynamic> json) {
    seekerProfileId = json['seeker_profile_id']?.toString();
    memberId = json['member_id']?.toString();
    resumePath = json['resume_path']?.toString();
    resumeUrl = json['resume_url']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'seeker_profile_id': seekerProfileId,
      'member_id': memberId,
      'resume_path': resumePath,
      'resume_url': resumeUrl,
    };
  }
}
