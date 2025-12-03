import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mpm/model/SearchOccupation/SearchOccupationData.dart';
import 'package:mpm/model/SearchOccupation/SearchOccupationModelClass.dart';
import 'package:mpm/repository/search_occupation_repository/search_occupation_repo.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/urls.dart';
import 'package:mpm/view/Networking/filter_bottom_sheet.dart';
import 'package:mpm/view/Networking/network_filters.dart';

class NetworkView extends StatefulWidget {
  const NetworkView({super.key});

  @override
  State<NetworkView> createState() => _NetworkViewState();
}

class _NetworkViewState extends State<NetworkView> {
  final TextEditingController searchController = TextEditingController();
  final SearchOccupationRepository repo = SearchOccupationRepository();

  bool isLoading = false;
  List<SearchOccupationData> results = [];

  Timer? _debounce;

  // Current filters
  NetworkFilters _filters = NetworkFilters.empty;

  Future<void> performSearch(String term) async {
    if (term.trim().length < 3) {
      setState(() => results = []);
      return;
    }

    setState(() => isLoading = true);

    try {
      SearchOccupationModelClass response =
      await repo.searchOccupation(searchTerm: term);

      setState(() {
        results = response.data ?? [];
      });
    } catch (e) {
      debugPrint("Search Error: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _openFilterSheet() async {
    final newFilters = await showModalBottomSheet<NetworkFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FilterBottomSheet(initialFilters: _filters);
      },
    );

    if (newFilters != null) {
      setState(() => _filters = newFilters);

      if (searchController.text.trim().isNotEmpty) {
        performSearch(searchController.text.trim());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = ColorHelperClass.getColorFromHex(ColorResources.red_color);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: const Text("Networking", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 350), () {
                    performSearch(value);
                  });
                },
                decoration: const InputDecoration(
                  hintText: "Search members, profession, products...",
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
          ),

          // Result Count + Filter Button
          if (results.isNotEmpty && !isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${results.length} results",
                      style:
                      const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),

                  GestureDetector(
                    onTap: _openFilterSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: themeColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.redAccent),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.12),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.filter_alt, size: 18, color: Colors.white),
                          SizedBox(width: 6),
                          Text("Filter",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 10),

          // LOADING
          if (isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: Colors.red),
              ),
            ),

          // EMPTY STATE
          if (!isLoading && results.isEmpty)
            const Expanded(
              child: Center(
                child: Text("Start searching to discover members",
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
              ),
            ),

          // GRID VIEW
          if (!isLoading && results.isNotEmpty)
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.62,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final member = results[index];
                  final occ = member.occupation;

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.black12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.07),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: SizedBox(
                              height: 100,
                              width: 100,
                              child: member.profileImage != null &&
                                  member.profileImage!.isNotEmpty
                                  ? FadeInImage(
                                placeholder: const AssetImage("assets/images/user3.png"),
                                image: NetworkImage(
                                    Urls.imagePathUrl + member.profileImage!),
                                fit: BoxFit.cover,
                              )
                                  : Image.asset("assets/images/user3.png"),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(member.fullName ?? "No Name",
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600)),

                          const SizedBox(height: 6),

                          Text(occ?.professionName ?? "",
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey.shade700)),

                          if ((occ?.specializationName ?? "").isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                occ!.specializationName!,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),

                          const SizedBox(height: 8),

                          SizedBox(
                            width: double.infinity,
                            height: 38,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Connect",
                                  style: TextStyle(fontSize: 14)),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
