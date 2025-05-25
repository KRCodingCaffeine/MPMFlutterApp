import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpm/model/Offer/OfferData.dart';
import 'package:mpm/model/OfferCategory/OfferCatData.dart';
import 'package:mpm/model/OfferDiscountById/OfferDiscountByIdData.dart';
import 'package:mpm/model/OfferSubcategory/OfferSubcatData.dart';
import 'package:mpm/model/OfferSubcategory/OfferSubcatModelClass.dart';
import 'package:mpm/repository/offer_cat_repository/offer_cat_repo.dart';
import 'package:mpm/repository/offer_repository/offer_repo.dart';
import 'package:mpm/repository/offer_subcat_repository/offer_subcat_repo.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/model/Offer/OfferModelClass.dart';
import 'package:mpm/view/DiscountOfferDetailPage.dart';
import 'package:mpm/view/offer_claimed_view.dart';

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
  bool isLoading = true;
  String errorMessage = '';

  final offerRepo = OfferRepository();
  final categoryRepo = OrganisationCategoryRepository();
  final subcategoryRepo = OrganisationSubcategoryRepository();
  List<OfferData> allOffers = [];
  List<OrganisationCategoryData> allCategories = [];
  List<OrganisationSubcategoryData> allSubcategories = [];
  Map<String, List<OrganisationSubcategoryData>> categorySubcategories = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final results = await Future.wait([
        offerRepo.fetchOfferDiscounts(),
        categoryRepo.fetchOrganisationCategories(),
      ]);

      final offerModel = OfferModelClass.fromJson(results[0]);
      final categoryModel = OrganisationCategoryModel.fromJson(results[1]);

      if (offerModel.status == true && offerModel.data != null &&
          categoryModel.status == true && categoryModel.data != null) {
        setState(() {
          allOffers = offerModel.data!;
          allCategories = categoryModel.data!;
        });

        await _fetchSubcategoriesForAllCategories();

        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = offerModel.message ?? categoryModel.message ?? 'Failed to load data';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching data: ${e.toString()}';
      });
    }
  }

  Future<void> _fetchSubcategoriesForAllCategories() async {
    categorySubcategories.clear();

    for (var category in allCategories) {
      try {
        final response = await subcategoryRepo.fetchSubcategoriesByCategory(
            int.parse(category.organisationCategoryId!));

        final model = OrganisationSubcategoryModel.fromJson(response);

        if (model.data != null) {
          final subcategoryDataList = model.data!.map((subcategory) {
            return OrganisationSubcategoryData(
              organisationSubcategoryId: subcategory.organisationSubcategoryId,
              organisationSubcategoryName: subcategory.organisationSubcategoryName,
              organisationCategoryId: subcategory.organisationCategoryId,
              status: subcategory.status,
              dateAdded: subcategory.dateAdded,
            );
          }).toList();

          categorySubcategories[category.organisationCategoryId!] = subcategoryDataList;
        }
      } catch (e) {
        debugPrint("Error fetching subcategories for category ${category.organisationCategoryId}: $e");
      }
    }

    allSubcategories = categorySubcategories.values.expand((e) => e).toList();
  }

  List<OrganisationSubcategoryData> _getSubcategoriesForSelectedCategories() {
    if (pendingSelectedCategories.isEmpty) return [];
    return pendingSelectedCategories
        .expand((catId) => categorySubcategories[catId] ?? <OrganisationSubcategoryData>[])
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    List<OfferData> filteredOffers = isFilterApplied
        ? allOffers.where((offer) {
      // Category filter
      bool categoryMatch = selectedCategories.isEmpty ||
          (offer.orgCategoryId != null &&
              selectedCategories.contains(offer.orgCategoryId));

      // Subcategory filter
      bool subcategoryMatch = selectedSubcategories.isEmpty;
      if (!subcategoryMatch && offer.orgSubcategoryId != null) {
        // Find the subcategory to get its name
        final subcat = allSubcategories.firstWhere(
              (s) => s.organisationSubcategoryId == offer.orgSubcategoryId,
          orElse: () => OrganisationSubcategoryData(),
        );
        subcategoryMatch = subcat.organisationSubcategoryName != null &&
            selectedSubcategories.contains(subcat.organisationSubcategoryName);
      }

      return categoryMatch && subcategoryMatch;
    }).toList()
        : allOffers;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: const Text(
          "Discounts & Offers",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_offer, color: Colors.white),
            tooltip: 'Filter Offers',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClaimedOfferListPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildFilterButton(),
              if (isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (errorMessage.isNotEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(errorMessage),
                        ElevatedButton(
                          onPressed: _fetchData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (filteredOffers.isEmpty)
                  const Expanded(child: Center(child: Text('No offers available')))
                else
                  Expanded(
                    child: RefreshIndicator(
                      color: Colors.red,
                      onRefresh: _fetchData,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 12),
                        itemCount: filteredOffers.length,
                        itemBuilder: (context, index) {
                          return _buildOfferCard(filteredOffers[index]);
                        },
                      ),
                    ),
                  ),
            ],
          ),
          if (isFilterDrawerOpen) _buildFilterDrawer(),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: InkWell(
        onTap: () {
          setState(() {
            pendingSelectedCategories = List.from(selectedCategories);
            pendingSelectedSubcategories = List.from(selectedSubcategories);
            isFilterDrawerOpen = true;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                    const Text("Select Offers", style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        ...selectedCategories.map((catId) {
                          final category = allCategories.firstWhere(
                                (c) => c.organisationCategoryId == catId,
                            orElse: () => OrganisationCategoryData(),
                          );
                          return Chip(
                            label: Text(category.organisationCategoryName ?? 'Unknown'),
                            labelStyle: const TextStyle(fontSize: 12, color: Colors.white),
                            backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                            deleteIcon: const Icon(Icons.close, color: Colors.white, size: 18),
                            onDeleted: () => setState(() => selectedCategories.remove(catId)),
                          );
                        }),
                        ...selectedSubcategories.map(
                              (subcat) => Chip(
                            label: Text(subcat),
                            labelStyle: const TextStyle(fontSize: 12, color: Colors.white),
                            backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                            deleteIcon: const Icon(Icons.close, color: Colors.white, size: 18),
                            onDeleted: () => setState(() => selectedSubcategories.remove(subcat)),
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
    );
  }

  Widget _buildFilterDrawer() {
    final availableSubcategories = _getSubcategoriesForSelectedCategories();

    return Positioned(
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
                  const Text("Select Offers", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => isFilterDrawerOpen = false),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text("Select Category"),
              const SizedBox(height: 8),
              ...allCategories.map((category) => CheckboxListTile(
                title: Text(category.organisationCategoryName ?? 'Unknown'),
                value: pendingSelectedCategories.contains(category.organisationCategoryId),
                onChanged: (value) => setState(() {
                  final catId = category.organisationCategoryId;
                  if (catId != null) {
                    if (value == true) {
                      pendingSelectedCategories.add(catId);
                      pendingSelectedSubcategories.clear();
                    } else {
                      pendingSelectedCategories.remove(catId);
                      pendingSelectedSubcategories.clear();
                    }
                  }
                }),
              )),
              const SizedBox(height: 20),
              const Text("Select Subcategories"),
              const SizedBox(height: 8),
              if (pendingSelectedCategories.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("Please select a category first", style: TextStyle(color: Colors.grey)),
                )
              else
                ...availableSubcategories.map((subcategory) => CheckboxListTile(
                  title: Text(subcategory.organisationSubcategoryName ?? 'Unknown'),
                  value: pendingSelectedSubcategories.contains(subcategory.organisationSubcategoryName ?? ''),
                  onChanged: (value) => setState(() {
                    final subcatName = subcategory.organisationSubcategoryName;
                    if (subcatName != null) {
                      if (value == true) {
                        pendingSelectedSubcategories.add(subcatName);
                      } else {
                        pendingSelectedSubcategories.remove(subcatName);
                      }
                    }
                  }),
                )),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      selectedCategories = List.from(pendingSelectedCategories);
                      selectedSubcategories = List.from(pendingSelectedSubcategories);
                      isFilterApplied = selectedCategories.isNotEmpty || selectedSubcategories.isNotEmpty;
                      isFilterDrawerOpen = false;
                    });
                  },
                  child: const Text("Apply Filter", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfferCard(OfferData offer) {
    final subcategory = allSubcategories.firstWhere(
          (s) => s.organisationSubcategoryId == offer.orgSubcategoryId,
      orElse: () => OrganisationSubcategoryData(),
    );

    // Handle date display logic
    Widget? dateTag;
    if (offer.validFrom != null || offer.validTo != null) {
      String dateText = '';
      if (offer.validFrom != null && offer.validTo != null) {
        dateText = "Till : ${_formatDate(offer.validFrom!)} - ${_formatDate(offer.validTo!)}";
      } else if (offer.validTo != null) {
        dateText = "Till : ${_formatDate(offer.validTo!)}";
      } else if (offer.validFrom != null) {
        dateText = "From : ${_formatDate(offer.validFrom!)}";
      }

      if (dateText.isNotEmpty) {
        dateTag = _buildTag(
          dateText,
          Colors.grey[300]!,
          textColor: Colors.black45,
          fontSize: 10,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        );
      }
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiscountOfferDetailPage(offer: offer),
          ),
        );
      },
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
                // Left Logo & Name
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    (offer.orgLogo != null && offer.orgLogo!.isNotEmpty)
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        offer.orgLogo!,
                        width: 75,
                        height: 75,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildDefaultLogo(),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            width: 75,
                            height: 75,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                        : _buildDefaultLogo(),
                  const SizedBox(height: 4),
                    SizedBox(
                      width: 75,
                      child: Text(
                        offer.orgName ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 12),
                Container(width: 1, color: Colors.grey[400]),
                const SizedBox(width: 12),

                Expanded(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              offer.offerDiscountName ?? 'No title',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              offer.offerDescription ?? 'No description',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            if (dateTag != null) dateTag!,
                          ],
                        ),
                      ),

                      if (subcategory.organisationSubcategoryName != null &&
                          subcategory.organisationSubcategoryName!.isNotEmpty)
                        Positioned(
                          top: 4,
                          right: 0,
                          child: _buildTag(
                            subcategory.organisationSubcategoryName!,
                            ColorHelperClass.getColorFromHex(ColorResources.red_color),
                            textColor: Colors.white,
                            fontSize: 10,
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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

  Widget _buildTag(String text, Color bgColor,
      {Color textColor = Colors.white, double fontSize = 12, EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4)}) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDefaultLogo() {
    return Center(
      child: Image.asset(
        'assets/images/med-3.png',
        width: 75,
        height: 75,
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('d-M-y').format(date);
    } catch (e) {
      return dateString;
    }
  }
}