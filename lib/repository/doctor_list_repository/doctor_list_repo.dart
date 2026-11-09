import 'package:flutter/material.dart';
import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/DoctorList/DoctorListModel.dart';
import 'package:mpm/utils/urls.dart';

class DoctorListRepository {
  final api = NetWorkApiService();

  Future<DoctorListModel> getDoctorList({
    String source = 'all',
    int limit = 100,
    int offset = 0,
    String? keyword,
  }) async {
    final query = <String, String>{
      'source': source,
      'limit': '$limit',
      'offset': '$offset',
    };
    final term = keyword?.trim() ?? '';
    if (term.isNotEmpty) query['keyword'] = term;

    final url = Uri.parse(Urls.doctor_list_url).replace(queryParameters: query).toString();
    debugPrint('🔵 Doctor List API URL: $url');

    final response = await api.getApi(url, '');
    if (response is! Map) {
      throw Exception('Unable to load doctors');
    }
    return DoctorListModel.fromJson(Map<String, dynamic>.from(response));
  }

  Future<List<DoctorListData>> getAllDoctors({String source = 'all'}) async {
    const pageSize = 100;
    var offset = 0;
    final doctors = <DoctorListData>[];

    while (offset < 500) {
      final page = await getDoctorList(source: source, limit: pageSize, offset: offset);
      final items = page.data ?? [];
      doctors.addAll(items);
      final total = page.totalResults ?? doctors.length;
      offset += items.isEmpty ? pageSize : items.length;
      if (items.isEmpty || offset >= total) break;
    }

    return doctors;
  }
}
