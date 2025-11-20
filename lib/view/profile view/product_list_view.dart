import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpm/model/BusinessProfile/AddOccupationProduct/AddOccupationProductData.dart';
import 'package:mpm/model/ProductCategory/ProductCategoryData.dart';
import 'package:mpm/model/ProductSubcategory/ProductSubcategoryData.dart';
import 'package:mpm/repository/BusinessProfileRepo/add_occupation_product_repository/add_occupation_product_repo.dart';
import 'package:mpm/repository/BusinessProfileRepo/delete_occupation_product_repository/delete_occupation_product_repo.dart';
import 'package:mpm/repository/BusinessProfileRepo/product_image_repository/product_image_repo.dart';
import 'package:mpm/repository/product_category_repository/product_category_repo.dart';
import 'package:mpm/repository/product_subcategory_repository/product_subcategory_repo.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/model/BusinessProfile/GetAllOccupationProduct/GetAllOccupationProductData.dart';
import 'package:mpm/model/BusinessProfile/GetAllOccupationProduct/GetAllOccupationProductModelClass.dart';
import 'package:mpm/utils/urls.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

class ProductListPage extends StatefulWidget {
  final String profileId;

  const ProductListPage({
    Key? key,
    required this.profileId,
  }) : super(key: key);

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final UdateProfileController controller = Get.find<UdateProfileController>();
  final DeleteOccupationProductRepository deleteRepository = DeleteOccupationProductRepository();
  final ProductCategoryRepository categoryRepository = ProductCategoryRepository();
  final ProductSubcategoryRepository subcategoryRepository = ProductSubcategoryRepository();
  final AddOccupationProductRepository addProductRepository = AddOccupationProductRepository();

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _keywordsController = TextEditingController();
  final TextEditingController _displayOrderController = TextEditingController();

  String? _selectedType = 'product';
  String? _selectedStatus = '1';
  String? _selectedIsFeatured = '1';
  String? _selectedCategoryId;
  String? _selectedSubcategoryId;

  File? _image;

  List<ProductCategoryData> _categories = [];
  List<ProductSubcategoryData> _subcategories = [];
  bool _isAddingProduct = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<GetAllOccupationProductData> _products = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    controller.loadCategories().then((_) {
      setState(() {
        _categories = controller.categories;
      });
    });
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      await controller.getAllOccupationProducts(widget.profileId);

      if (controller.occupationProducts.value?.data != null) {
        setState(() {
          _products = controller.occupationProducts.value!.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'No products found';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load products: $e';
      });
      debugPrint("❌ Error loading products: $e");
    }
  }

  Future<void> _refreshProducts() async {
    await _loadProducts();
  }

  void _showAddProductModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: FractionallySizedBox(
            heightFactor: 0.9,
            child: SafeArea(
              child: Column(
                children: [
                  // Header with buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                            side: BorderSide(color: ColorHelperClass.getColorFromHex(ColorResources.red_color)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _isAddingProduct ? null : () async {
                            if (_validateProductForm()) {
                              await _addProduct();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: _isAddingProduct
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text(
                            "Submit",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const SizedBox(height: 10),

                            // Category Dropdown
                            _buildCategoryDropdown(),
                            const SizedBox(height: 16),

                            // Subcategory Dropdown
                            _buildSubcategoryDropdown(),
                            const SizedBox(height: 16),

                            // Product Name
                            _buildTextField(
                              label: "Product Name *",
                              controller: _productNameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter product name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Description
                            _buildTextField(
                              label: "Description *",
                              controller: _descriptionController,
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter description';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Type Dropdown
                            _buildDropdownFormField(
                              label: "Product Type *",
                              value: _selectedType,
                              items: const ['product', 'service', 'both'],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select type';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  _selectedType = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            // Keywords
                            _buildTextField(
                              label: "Keywords",
                              controller: _keywordsController,
                              hintText: "Enter keywords (comma separated)",
                            ),
                            const SizedBox(height: 16),

                            // Unit
                            _buildTextField(
                              label: "Unit *",
                              controller: _unitController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter unit';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Price
                            _buildTextField(
                              label: "Price *",
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter price';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter valid price';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Display Order
                            _buildTextField(
                              label: "Display Order",
                              controller: _displayOrderController,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),

                            // Is Featured Dropdown
                            _buildDropdownFormField(
                              label: "Featured *",
                              value: _selectedIsFeatured == '1' ? 'Yes' : 'No',
                              items: const ['Yes', 'No'],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select featured status';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  _selectedIsFeatured = value == 'Yes' ? '1' : '0';
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            // Status Dropdown
                            _buildDropdownFormField(
                              label: "Status *",
                              value: _selectedStatus == '1' ? 'Active' : 'Inactive',
                              items: const ['Active', 'Inactive'],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select status';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  _selectedStatus = value == 'Active' ? '1' : '0';
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            // Upload Product Image
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Product Image",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _showImagePicker(context);
                                },
                                icon: const Icon(Icons.image),
                                label: const Text("Upload Image"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Show selected image preview
                            if (_image != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _image!,
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.redAccent),
              title: const Text("Take a Picture"),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.redAccent),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
    String? hintText,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black38, width: 1)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          labelStyle: const TextStyle(color: Colors.black),
          hintText: hintText,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 5, right: 5),
      child: Row(
        children: [
          Obx(() {
            if (controller.isCategoryLoading.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 22),
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.redAccent,
                  ),
                ),
              );
            } else if (controller.categories.isEmpty) {
              return const Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('No categories available'),
                ),
              );
            } else {
              final selectedCategory = controller.selectedCategory.value;

              return Expanded(
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: selectedCategory.isNotEmpty ? 'Category *' : null,
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black38, width: 1),
                    ),
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    labelStyle: const TextStyle(color: Colors.black),
                  ),
                  child: DropdownButton<String>(
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    isExpanded: true,
                    underline: Container(),
                    hint: const Text(
                      'Select Category *',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    value: selectedCategory.isNotEmpty ? selectedCategory : null,
                    items: controller.categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat.categoryId,
                        child: Text(cat.name ?? 'Unknown'),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.selectedCategory.value = newValue;
                        _selectedCategoryId = newValue;
                        controller.loadSubcategories(newValue);

                        controller.selectedSubcategory.value = '';
                        _selectedSubcategoryId = null;
                      }
                    },
                  ),
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildSubcategoryDropdown() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 5, right: 5),
      child: Row(
        children: [
          Obx(() {

            if (controller.isSubcategoryLoading.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 22),
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.redAccent,
                  ),
                ),
              );
            }

            final selectedSub = controller.selectedSubcategory.value;

            return Expanded(
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: selectedSub.isNotEmpty ? 'Subcategory' : null,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black38, width: 1),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  labelStyle: const TextStyle(color: Colors.black),
                ),
                child: DropdownButton<String>(
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  isExpanded: true,
                  underline: Container(),
                  hint: Text(
                    controller.subcategories.isEmpty
                        ? "Select Subcategory"
                        : "Select Subcategory",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  value: selectedSub.isNotEmpty ? selectedSub : null,
                  items: controller.subcategories.map((sub) {
                    return DropdownMenuItem<String>(
                      value: sub.subcategoryId,
                      child: Text(sub.name ?? 'Unknown'),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      controller.selectedSubcategory.value = newValue;
                      _selectedSubcategoryId = newValue;
                    }
                  },

                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDropdownFormField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 5, right: 5),
      child: Row(
        children: [
          Expanded(
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: (value != null && value.isNotEmpty) ? label : null,
                hintText: label,
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black38, width: 1),
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                labelStyle: const TextStyle(color: Colors.black),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  value: items.contains(value) ? value : null,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  hint: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  items: items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item.toString().capitalizeFirst ?? item,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: onChanged,
                  validator: validator,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _validateProductForm() {
    if (_selectedCategoryId == null) {
      Get.snackbar(
        "Error",
        "Please select category",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    if (_formKey.currentState!.validate()) {
      return true;
    }
    return false;
  }

  void _clearProductForm() {
    _productNameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _unitController.clear();
    _keywordsController.clear();
    _displayOrderController.clear();
    setState(() {
      _selectedType = 'product';
      _selectedStatus = '1';
      _selectedIsFeatured = '1';
      _selectedCategoryId = null;
      _selectedSubcategoryId = null;
      _subcategories = [];
    });
  }

  Future<void> _addProduct() async {
    final userData = await SessionManager.getSession();
    if (userData == null) throw Exception("User not logged in");

    setState(() {
      _isAddingProduct = true;
    });

    try {
      final productData = AddOccupationProductData(
        memberBusinessOccupationProfileId: widget.profileId,
        categoryId: _selectedCategoryId!,
        subcategoryId: _selectedSubcategoryId,
        type: _selectedType,
        productName: _productNameController.text.trim(),
        description: _descriptionController.text.trim(),
        keywords: _keywordsController.text.trim().isNotEmpty ? _keywordsController.text.trim() : null,
        price: _priceController.text.trim(),
        currency: 'INR',
        unit: _unitController.text.trim(),
        status: _selectedStatus,
        isFeatured: _selectedIsFeatured,
        displayOrder: _displayOrderController.text.trim().isNotEmpty ? _displayOrderController.text.trim() : null,
        createdBy: userData.memberId.toString(),
        createdAt: DateTime.now().toIso8601String(),
      );

      // STEP 1 — CALL ADD PRODUCT API
      final response = await addProductRepository.addOccupationProduct(productData.toJson());

      if (response.status == true) {

        // ⛔ CLOSE MODAL BEFORE IMAGE UPLOAD
        Navigator.pop(context);

        // 🚀 Product added successfully
        final productServiceId = response.data?.productServiceId;

        if (productServiceId != null) {

          // STEP 2 — If user selected an image, upload it now
          if (_image != null) {
            final imageRepo = ProductImageUploadRepository();
            await imageRepo.uploadProductImage(
              productServiceId: productServiceId.toString(),
              filePath: _image!.path,
            );
          }
        }

        Get.snackbar(
          "Success",
          response.message ?? "Product added successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        _refreshProducts();
        _clearProductForm();
        _image = null;

      } else {
        Get.snackbar(
          "Error",
          response.message ?? "Failed to add product",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to add product: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isAddingProduct = false;
      });
    }
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    _keywordsController.dispose();
    _displayOrderController.dispose();
    super.dispose();
  }

  void _showEditProduct(GetAllOccupationProductData product) {
    // Navigate to edit page or open modal
    print("Editing product: ${product.productServiceId}");
  }

  String _getCategoryName(String? categoryId) {
    if (categoryId == null) return 'Not specified';
    final category = _categories.firstWhere(
          (cat) => cat.categoryId == categoryId,
      orElse: () => ProductCategoryData(name: 'Unknown'),
    );
    return category.name ?? 'Unknown';
  }

  String _getSubCategoryName(String? subCategoryId) {
    if (subCategoryId == null) return 'Not specified';
    final subcategory = _subcategories.firstWhere(
          (sub) => sub.subcategoryId == subCategoryId,
      orElse: () => ProductSubcategoryData(name: 'Unknown'),
    );
    return subcategory.name ?? 'Unknown';
  }

  void _showProductDetails(GetAllOccupationProductData product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          product.productName ?? 'Product',
          style: TextStyle(
            color: ColorHelperClass.getColorFromHex(ColorResources.logo_color),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              if (product.productImage != null && product.productImage!.isNotEmpty)
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: FadeInImage(
                        placeholder: const AssetImage("assets/images/placeholder.png"),
                        image: NetworkImage(Urls.imagePathUrl + product.productImage!),
                        width: MediaQuery.of(context).size.width,
                        height: 250,
                        fit: BoxFit.cover,
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            "assets/images/no_image.png",
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Description
              _buildDetailRow("Description:", product.description ?? 'Not available'),
              const SizedBox(height: 8),

              // Display Order
              if (product.displayOrder != null)
                Column(
                  children: [
                    _buildDetailRow("Display Order:", product.displayOrder!),
                    const SizedBox(height: 8),
                  ],
                ),

              // Price
              _buildDetailRow("Price:", "${product.price ?? '0'} ${product.currency ?? ''}"),
              const SizedBox(height: 8),

              // Featured Status
              _buildDetailRow("Featured:", product.isFeatured == "1" ? "Yes" : "No"),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(GetAllOccupationProductData product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Delete Product",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Divider(
                thickness: 1,
                color: Colors.grey,
              ),
            ],
          ),
          content: Text(
            "Are you sure you want to delete '${product.productName ?? 'this product'}'?",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteProduct(product);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProduct(GetAllOccupationProductData product) async {
    if (product.productServiceId == null || product.productServiceId!.isEmpty) {
      Get.snackbar(
        "Error",
        "Invalid product ID",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      // Show loading dialog
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      // Call the delete repository
      final response = await deleteRepository.deleteProduct(product.productServiceId!);

      // Close loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (response.status == true) {
        // Remove product from local list
        setState(() {
          _products.removeWhere((p) => p.productServiceId == product.productServiceId);
        });

        Get.snackbar(
          "Success",
          response.message ?? "Product deleted successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        Get.snackbar(
          "Error",
          response.message ?? "Failed to delete product",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        "Error",
        "Failed to delete product: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      debugPrint("❌ DELETE PRODUCT ERROR: $e");
    } finally {
      setState(() {
        _isDeleting = false;
      });
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case '1':
        return 'Active';
      case '0':
        return 'Inactive';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case '1':
        return Colors.green;
      case '0':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Product List",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _showAddProductModal,
            icon: const Icon(Icons.add),
            tooltip: 'Add Product',
          ),
          IconButton(
            onPressed: _refreshProducts,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hasError
                ? _buildErrorState()
                : _products.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: _refreshProducts,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return _buildProductCard(product);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(GetAllOccupationProductData product) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    product.productName ?? 'Product Name',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(product.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _getStatusColor(product.status),
                    ),
                  ),
                  child: Text(
                    _getStatusText(product.status),
                    style: TextStyle(
                      color: _getStatusColor(product.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Category: ${product.categoryId} → ${product.subCategoryId}",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),

                      Text(
                        "Quantity: ${product.unit ?? 'N/A'}",
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),

                    ],
                  ),
                ),
                Text(
                  "${product.price ?? '0'} ${product.currency ?? ''}",
                  style: TextStyle(
                    color: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditProduct(product),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                      side: BorderSide(
                        color: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit Product"),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showDeleteConfirmation(product),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.delete),
                    label: const Text("Delete"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showProductDetails(product),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.visibility),
                label: const Text("View Details"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            "No Products Found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Add your first product to get started",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          const Text(
            "Failed to Load Products",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshProducts,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.refresh),
            label: const Text("Try Again"),
          ),
        ],
      ),
    );
  }
}
