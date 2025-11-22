import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mpm/model/SearchOccupation/SearchOccupationData.dart';
import 'package:mpm/model/SearchOccupation/SearchOccupationModelClass.dart';
import 'package:mpm/repository/search_occupation_repository/search_occupation_repo.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/urls.dart';

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

      print("RESULT COUNT: ${results.length}");
    } catch (e) {
      debugPrint("Search Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor =
    ColorHelperClass.getColorFromHex(ColorResources.red_color);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: const Text("Networking", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Column(
        children: [
          // 🔍 AMAZON STYLE SEARCH BAR
          Container(
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
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
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

          // LOADING INDICATOR
          if (isLoading)
            const Expanded(
                child:
                Center(child: CircularProgressIndicator(color: Colors.red))),

          // EMPTY STATE
          if (!isLoading && results.isEmpty)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_alt_outlined,
                      size: 100, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    "Start searching to discover members",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  )
                ],
              ),
            ),

          // RESULT GRID
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
                            offset: const Offset(0, 3))
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Profile Image - Amazon Style
                          ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: SizedBox(
                              height: 100,
                              width: 100,
                              child: (member.profileImage != null &&
                                  member.profileImage!.isNotEmpty)
                                  ? FadeInImage(
                                placeholder: const AssetImage(
                                    "assets/images/user3.png"),
                                image: NetworkImage(
                                    Urls.imagePathUrl +
                                        member.profileImage!),
                                fit: BoxFit.cover,
                                imageErrorBuilder: (_, __, ___) =>
                                    Image.asset(
                                        "assets/images/user3.png"),
                              )
                                  : Image.asset("assets/images/user3.png",
                                  fit: BoxFit.cover),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Name
                          Text(
                            member.fullName ?? "No Name",
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                height: 1.2),
                          ),

                          const SizedBox(height: 6),

                          // Profession
                          Text(
                            occ?.professionName ?? "",
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade700),
                          ),

                          const SizedBox(height: 4),

                          // Specialization (Amazon badge style)
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

                          // Connect Button (Amazon Style)
                          SizedBox(
                            width: double.infinity,
                            height: 38,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text("Connect",
                                  style: TextStyle(fontSize: 14)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
