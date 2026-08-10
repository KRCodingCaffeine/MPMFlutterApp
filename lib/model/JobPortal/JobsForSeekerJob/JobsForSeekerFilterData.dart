import 'JobsForSeekerJobData.dart';

class JobsForSeekerFilterData {
  bool? isFresher;

  List<JobsForSeekerJobData>? jobs;

  int? totalCount;

  Map<String, dynamic>? tierCounts;

  Map<String, dynamic>? filters;

  JobsForSeekerFilterData({
    this.isFresher,
    this.jobs,
    this.totalCount,
    this.tierCounts,
    this.filters,
  });

  JobsForSeekerFilterData.fromJson(Map<String, dynamic> json) {
    isFresher = json['is_fresher'];

    if (json['jobs'] != null) {
      jobs = <JobsForSeekerJobData>[];

      json['jobs'].forEach((v) {
        jobs!.add(JobsForSeekerJobData.fromJson(v));
      });
    }

    totalCount = json['total_count'];

    tierCounts = json['tier_counts'];

    filters = json['filters'];
  }

  Map<String, dynamic> toJson() {
    return {
      'is_fresher': isFresher,
      'jobs': jobs?.map((e) => e.toJson()).toList(),
      'total_count': totalCount,
      'tier_counts': tierCounts,
      'filters': filters,
    };
  }
}