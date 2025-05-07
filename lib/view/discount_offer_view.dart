import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/DiscountOfferDetailPage.dart';

class DiscountofferView extends StatefulWidget {
  const DiscountofferView({super.key});

  @override
  State<DiscountofferView> createState() => _DiscountofferViewState();
}

class _DiscountofferViewState extends State<DiscountofferView> {
  List<String> selectedSubcategories = [];
  List<String> selectedCategories = [];
  List<String> pendingSelectedCategories = [];
  List<String> pendingSelectedSubcategories = [];
  bool isFilterDrawerOpen = false;
  bool isFilterApplied = false;

  final List<Map<String, dynamic>> allOffers = [
    {
      "companyName": "MPM Mumbai",
      "offerName": "Health Check up",
      "offerDescription":
      "Comprehensive health package including blood tests, BP, sugar, and cholesterol screening.",
      "categoryName": "Health",
      "subcategoryName": "Medicine",
      "validFrom": "May 2, 2025",
      "validTO": "Aug 31, 2025",
      "companyLogo": "assets/images/logo.png",
      "tagColor": Colors.redAccent,
    },
    {
      "companyName": "MPM Mumbai",
      "offerName": "Insurance Policy",
      "offerDescription":
      "Comprehensive health check-up package designed for early detection and prevention of lifestyle diseases. This includes a range of diagnostic tests vital for tracking key health parameters, particularly useful for those seeking health insurance or renewing policies.",
      "categoryName": "Health Insurance",
      "subcategoryName": "Medicine",
      "validFrom": "May 2, 2025",
      "validTO": "July 31, 2025",
      "companyLogo": "assets/images/logo.png",
      "tagColor": Colors.redAccent,
    },
    {
      "companyName": "MPM Mumbai",
      "offerName": "Eye Check up",
      "offerDescription": "Complete eye examination including vision testing.",
      "categoryName": "Health",
      "subcategoryName": "Check Up",
      "validFrom": "June 31, 2025",
      "validTO": "Oct 3, 2025",
      "companyLogo": "assets/images/logo.png",
      "tagColor": Colors.redAccent,
    },
    {
      "companyName": "MPM Mumbai",
      "offerName": "Baby Health Check up",
      "offerDescription":
      "Full pediatric health check including growth monitoring, immunization review, and nutrition advice.",
      "categoryName": "Health",
      "subcategoryName": "Baby Care",
      "validFrom": "July 1, 2025",
      "validTO": "Nov 11, 2025",
      "companyLogo": "assets/images/logo.png",
      "tagColor": Colors.redAccent,
    },
  ];

  final List<String> allCategories = ["Health", "Health Insurance"];
  final List<String> allSubcategories = ["Medicine", "Check Up", "Baby Care"];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredOffers = isFilterApplied
        ? allOffers.where((offer) {
      bool categoryMatch = selectedCategories.isEmpty ||
          selectedCategories.contains(offer["categoryName"]);
      bool subcategoryMatch = selectedSubcategories.isEmpty ||
          selectedSubcategories.contains(offer["subcategoryName"]);
      return categoryMatch && subcategoryMatch;
    }).toList()
        : allOffers;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
        ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: const Text(
          "Discounts & Offers",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Filter Button
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      pendingSelectedCategories = List.from(selectedCategories);
                      pendingSelectedSubcategories =
                          List.from(selectedSubcategories);
                      isFilterDrawerOpen = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Filter Offers",
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  ...selectedCategories.map(
                                        (cat) => Chip(
                                      label: Text(cat),
                                      labelStyle: const TextStyle(fontSize: 12, color: Colors.white),
                                      backgroundColor: Colors.redAccent,
                                      deleteIcon: const Icon(Icons.close, color: Colors.white, size: 18),
                                      onDeleted: () {
                                        setState(() {
                                          selectedCategories.remove(cat);
                                        });
                                      },
                                    ),
                                  ),
                                  ...selectedSubcategories.map(
                                        (subcat) => Chip(
                                      label: Text(subcat),
                                      labelStyle: const TextStyle(fontSize: 12, color: Colors.white),
                                      backgroundColor: Colors.redAccent,
                                      deleteIcon: const Icon(Icons.close, color: Colors.white, size: 18),
                                      onDeleted: () {
                                        setState(() {
                                          selectedSubcategories.remove(subcat);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.filter_list),
                      ],
                    ),
                  ),
                ),
              ),

              // Offer List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 12),
                  itemCount: filteredOffers.length,
                  itemBuilder: (context, index) {
                    final offer = filteredOffers[index];
                    return offerCard(
                      companyName: offer["companyName"],
                      OfferName: offer["offerName"],
                      offerDescription: offer["offerDescription"],
                      categoryName: offer["categoryName"],
                      subcategoryName: offer["subcategoryName"],
                      validFrom: offer["validFrom"],
                      validTO: offer["validTO"],
                      companyLogo: offer["companyLogo"],
                      tagColor: offer["tagColor"],
                    );
                  },
                ),
              ),
            ],
          ),

          // Right-side filter drawer
          if (isFilterDrawerOpen)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Material(
                elevation: 16,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text("Filter Offers",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                isFilterDrawerOpen = false;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      const Text("Select Category"),
                      const SizedBox(height: 8),
                      ...allCategories.map((category) {
                        return CheckboxListTile(
                          title: Text(category),
                          value: pendingSelectedCategories.contains(category),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                pendingSelectedCategories.add(category);
                              } else {
                                pendingSelectedCategories.remove(category);
                              }
                            });
                          },
                        );
                      }).toList(),

                      const SizedBox(height: 20),

                      const Text("Select Subcategories"),
                      const SizedBox(height: 8),
                      ...allSubcategories.map((subcategory) {
                        return CheckboxListTile(
                          title: Text(subcategory),
                          value:
                          pendingSelectedSubcategories.contains(subcategory),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                pendingSelectedSubcategories
                                    .add(subcategory);
                              } else {
                                pendingSelectedSubcategories
                                    .remove(subcategory);
                              }
                            });
                          },
                        );
                      }).toList(),

                      const Spacer(),

                      // Apply Filter Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              selectedCategories = List.from(pendingSelectedCategories);
                              selectedSubcategories = List.from(pendingSelectedSubcategories);
                              isFilterApplied = true;
                              isFilterDrawerOpen = false;
                            });
                          },
                          child: const Text("Apply Filter"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget offerCard({
    required String companyName,
    required String OfferName,
    required String offerDescription,
    required String categoryName,
    required String subcategoryName,
    required String validFrom,
    required String validTO,
    required String companyLogo,
    required Color tagColor,
  }) {
    return InkWell(
      // onTap: () {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => DiscountOfferDetailPage(
      //         companyName: companyName,
      //         offerName: OfferName,
      //         offerDescription: offerDescription,
      //         companyLogo: companyLogo,
      //       ),
      //     ),
      //   );
      // },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      companyLogo,
                      width: 75,
                      height: 75,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      companyName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Container(
                  width: 1,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        OfferName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        offerDescription,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: tagColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              categoryName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: tagColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              subcategoryName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "$validFrom - $validTO",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
