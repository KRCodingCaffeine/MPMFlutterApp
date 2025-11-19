import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  List<GetAllOccupationProductData> _products = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
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
            heightFactor: 0.8,
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Add Product",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ColorHelperClass.getColorFromHex(ColorResources.logo_color),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildProductFormField(
                            label: "Product Name *",
                            hintText: "Enter product name",
                          ),
                          const SizedBox(height: 16),

                          _buildProductFormField(
                            label: "Description *",
                            hintText: "Enter product description",
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),

                          _buildProductFormField(
                            label: "Price *",
                            hintText: "Enter price",
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),

                          _buildProductFormField(
                            label: "Category *",
                            hintText: "Enter category",
                          ),
                          const SizedBox(height: 16),

                          _buildProductFormField(
                            label: "SKU",
                            hintText: "Enter SKU (optional)",
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                _addProduct();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Add Product",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildProductFormField({
    required String label,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _addProduct() {
    Get.back();
    Get.snackbar(
      "Success",
      "Product added successfully",
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // Method to get category name from category ID
  String _getCategoryName(String? categoryId) {
    if (categoryId == null) return 'Not specified';

    // You'll need to implement this method to fetch category names
    // This could come from your controller or a separate API call
    // For now, returning the ID as a placeholder
    return 'Category $categoryId';
  }

  // Method to get subcategory name from subcategory ID
  String _getSubCategoryName(String? subCategoryId) {
    if (subCategoryId == null) return 'Not specified';

    // You'll need to implement this method to fetch subcategory names
    // This could come from your controller or a separate API call
    // For now, returning the ID as a placeholder
    return 'Subcategory $subCategoryId';
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
          TextButton(
            onPressed: () => Get.back(),
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
      builder: (context) => AlertDialog(
        title: const Text("Delete Product"),
        content: Text("Are you sure you want to delete '${product.productName ?? 'this product'}'?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _deleteProduct(product);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(GetAllOccupationProductData product) {
    setState(() {
      _products.removeWhere((p) => p.productServiceId == product.productServiceId);
    });
    Get.snackbar(
      "Success",
      "Product deleted successfully",
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
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
                    product.productName ?? 'Unnamed Product',
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

            // Category and Subcategory
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Category: ${_getCategoryName(product.categoryId)}",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Subcategory: ${_getSubCategoryName(product.subCategoryId)}",
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
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showProductDetails(product),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ColorHelperClass.getColorFromHex(ColorResources.logo_color),
                      side: BorderSide(
                        color: ColorHelperClass.getColorFromHex(ColorResources.logo_color)!,
                      ),
                    ),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text("View Details"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showDeleteConfirmation(product),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text("Delete"),
                  ),
                ),
              ],
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