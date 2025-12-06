// occupation_detail_view_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/BusinessProfile/BusinessAddress/BusinessAddressData.dart';
import 'package:mpm/model/BusinessProfile/GetAllBusinessOccupationProfile/GetAllBusinessOccupationProfileModelClass.dart';
import 'package:mpm/model/GetProfile/Address.dart';
import 'package:mpm/model/GetProfile/Occupation.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/view/profile%20view/business_info_page.dart';
import 'package:mpm/view/profile%20view/product_list_view.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';
import 'package:mpm/view_model/controller/dashboard/NewMemberController.dart';
import 'package:mpm/model/CountryModel/CountryData.dart';
import 'package:mpm/model/State/StateData.dart';
import 'package:mpm/model/city/CityData.dart';

class OccupationDetailViewPage extends StatefulWidget {
  final String memberId;
  final String memberOccupationId;

  const OccupationDetailViewPage({
    Key? key,
    required this.memberId,
    required this.memberOccupationId,
  }) : super(key: key);

  @override
  State<OccupationDetailViewPage> createState() =>
      _OccupationDetailViewPageState();
}

class _OccupationDetailViewPageState extends State<OccupationDetailViewPage> {
  final UdateProfileController controller = Get.find<UdateProfileController>();
  final NewMemberController regiController = Get.put(NewMemberController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _clearBusinessForm();

    _loadCountries();
    _loadBusinessProfiles();
  }

  void _loadCountries() {
    regiController.getCountry();
  }

  void _clearBusinessForm() {
    controller.businessNameController.value.clear();
    controller.businessMobileController.value.clear();
    controller.businessLandlineController.value.clear();
    controller.businessEmailController.value.clear();
    controller.businessWebsiteController.value.clear();
    controller.businessFlatNoController.value.clear();
    controller.businessAddressController.value.clear();
    controller.businessAreaNameController.value.clear();
    controller.businessPincodeController.value.clear();

    // Clear dropdown selections
    regiController.country_id.value = '';
    regiController.state_id.value = '';
    regiController.city_id.value = '';
  }

  Future<void> _showAddBusinessModalSheet(
      BuildContext context,
      Occupation occupation,
      ) async {
    _clearBusinessForm();

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
                  // Header with buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ColorHelperClass.getColorFromHex(
                                ColorResources.red_color),
                            side: BorderSide(
                                color: ColorHelperClass.getColorFromHex(
                                    ColorResources.red_color)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Obx(() => ElevatedButton(
                              onPressed: controller.isOccupationLoading.value
                                  ? null
                                  : () async {
                                      if (_validateForm()) {
                                        await _addBusinessDetails(occupation);
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    ColorHelperClass.getColorFromHex(
                                        ColorResources.red_color),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                              ),
                              child: controller.isOccupationLoading.value
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                            )),
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

                            // Business Name
                            _buildTextField(
                              label: "Business Name *",
                              controller: controller.businessNameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter business name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Business Mobile
                            _buildTextField(
                              label: "Business Mobile *",
                              controller: controller.businessMobileController,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter business mobile';
                                }
                                if (value.length != 10) {
                                  return 'Please enter valid 10-digit mobile number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Business Landline
                            _buildTextField(
                              label: "Business Landline",
                              controller: controller.businessLandlineController,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),

                            // Business Email
                            _buildTextField(
                              label: "Business Email",
                              controller: controller.businessEmailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return 'Please enter valid email';
                                  }
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Business Website
                            _buildTextField(
                              label: "Business Website",
                              controller: controller.businessWebsiteController,
                              keyboardType: TextInputType.url,
                            ),
                            const SizedBox(height: 16),

                            // Flat No
                            _buildTextField(
                              label: "Flat No *",
                              controller: controller.businessFlatNoController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter flat number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Address
                            _buildTextField(
                              label: "Address *",
                              controller: controller.businessAddressController,
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Area Name
                            _buildTextField(
                              label: "Area *",
                              controller: controller.businessAreaNameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter area';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // City Dropdown
                            _buildCityDropdown(),
                            const SizedBox(height: 16),

                            // State Dropdown
                            _buildStateDropdown(),
                            const SizedBox(height: 16),

                            // Country Dropdown
                            _buildCountryDropdown(),
                            const SizedBox(height: 16),

                            // Pincode
                            _buildTextField(
                              label: "Pincode *",
                              controller: controller.businessPincodeController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter pincode';
                                }
                                if (value.length != 6) {
                                  return 'Please enter valid 6-digit pincode';
                                }
                                return null;
                              },
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

  void _populateEditForm(BusinessOccupationProfile business) {
    final address = business.addresses?.isNotEmpty == true
        ? business.addresses!.first
        : null;

    // Populate business details
    controller.businessNameController.value.text = business.businessName ?? '';
    controller.businessMobileController.value.text =
        business.businessMobile ?? '';
    controller.businessLandlineController.value.text =
        business.businessLandline ?? '';
    controller.businessEmailController.value.text =
        business.businessEmail ?? '';
    controller.businessWebsiteController.value.text =
        business.businessWebsite ?? '';

    // Populate address details
    if (address != null) {
      controller.businessFlatNoController.value.text = address.flatNo ?? '';
      controller.businessAddressController.value.text = address.address ?? '';
      controller.businessAreaNameController.value.text = address.areaName ?? '';
      controller.businessPincodeController.value.text = address.pincode ?? '';

      // Set dropdown values
      if (address.countryId != null) {
        regiController.country_id.value = address.countryId.toString();
      }
      if (address.stateId != null) {
        regiController.state_id.value = address.stateId.toString();
      }
      if (address.cityId != null) {
        regiController.city_id.value = address.cityId.toString();
      }
    }
  }

  Future<void> _showEditBusinessModalSheet(
      BuildContext context, BusinessOccupationProfile business) async {
    _populateEditForm(business);

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
                  // Header with buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ColorHelperClass.getColorFromHex(
                                ColorResources.red_color),
                            side: BorderSide(
                                color: ColorHelperClass.getColorFromHex(
                                    ColorResources.red_color)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Obx(() => ElevatedButton(
                              onPressed: controller.isOccupationLoading.value
                                  ? null
                                  : () async {
                                      if (_validateForm()) {
                                        await _updateBusinessDetails(business);
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    ColorHelperClass.getColorFromHex(
                                        ColorResources.red_color),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                              ),
                              child: controller.isOccupationLoading.value
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                            )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Form Content - This should be scrollable
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const SizedBox(height: 10),

                            // Business Name
                            _buildTextField(
                              label: "Business Name *",
                              controller: controller.businessNameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter business name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Business Mobile
                            _buildTextField(
                              label: "Business Mobile *",
                              controller: controller.businessMobileController,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter business mobile';
                                }
                                if (value.length != 10) {
                                  return 'Please enter valid 10-digit mobile number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Business Landline
                            _buildTextField(
                              label: "Business Landline",
                              controller: controller.businessLandlineController,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),

                            // Business Email
                            _buildTextField(
                              label: "Business Email",
                              controller: controller.businessEmailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return 'Please enter valid email';
                                  }
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Business Website
                            _buildTextField(
                              label: "Business Website",
                              controller: controller.businessWebsiteController,
                              keyboardType: TextInputType.url,
                            ),
                            const SizedBox(height: 16),

                            // Flat No
                            _buildTextField(
                              label: "Flat No *",
                              controller: controller.businessFlatNoController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter flat number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Address
                            _buildTextField(
                              label: "Address *",
                              controller: controller.businessAddressController,
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Area Name
                            _buildTextField(
                              label: "Area *",
                              controller: controller.businessAreaNameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter area';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // City Dropdown
                            _buildCityDropdown(),
                            const SizedBox(height: 16),

                            // State Dropdown
                            _buildStateDropdown(),
                            const SizedBox(height: 16),

                            // Country Dropdown
                            _buildCountryDropdown(),
                            const SizedBox(height: 16),

                            // Pincode
                            _buildTextField(
                              label: "Pincode *",
                              controller: controller.businessPincodeController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter pincode';
                                }
                                if (value.length != 6) {
                                  return 'Please enter valid 6-digit pincode';
                                }
                                return null;
                              },
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

  Widget _buildTextField({
    required String label,
    required Rx<TextEditingController> controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5),
      child: TextFormField(
        controller: controller.value,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black)),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black)),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black38, width: 1)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          labelStyle: const TextStyle(color: Colors.black),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildCountryDropdown() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 5, right: 5),
      child: Row(
        children: [
          Obx(() {
            if (regiController.rxStatusCountryLoading.value == Status.LOADING) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 22),
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.redAccent),
                ),
              );
            } else if (regiController.rxStatusCountryLoading.value ==
                Status.ERROR) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Failed to load country'),
                ),
              );
            } else if (regiController.countryList.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('No Country available'),
                ),
              );
            } else {
              final selectedCountry = regiController.country_id.value;
              return Expanded(
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: selectedCountry.isNotEmpty ? 'Country *' : null,
                    border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    focusedBorder: const OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.black38, width: 1)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    labelStyle: const TextStyle(color: Colors.black),
                  ),
                  child: DropdownButton<String>(
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    isExpanded: true,
                    underline: Container(),
                    hint: const Text(
                      'Select Country *',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    value: selectedCountry.isNotEmpty ? selectedCountry : null,
                    items:
                        regiController.countryList.map((CountryData country) {
                      return DropdownMenuItem<String>(
                        value: country.id.toString(),
                        child: Text(country.countryName ?? 'Unknown'),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        regiController.setSelectedCountry(newValue);
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

  Widget _buildStateDropdown() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 5, right: 5),
      child: Row(
        children: [
          Obx(() {
            if (regiController.rxStatusStateLoading.value == Status.LOADING) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 22),
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.redAccent),
                ),
              );
            } else if (regiController.rxStatusStateLoading.value ==
                Status.ERROR) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Failed to load state'),
                ),
              );
            } else if (regiController.stateList.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('No State available'),
                ),
              );
            } else {
              final selectedState = regiController.state_id.value;
              return Expanded(
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: selectedState.isNotEmpty ? 'State *' : null,
                    border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    focusedBorder: const OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.black38, width: 1)),
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
                      'Select State *',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    value: selectedState.isNotEmpty ? selectedState : null,
                    items: regiController.stateList.map((StateData state) {
                      return DropdownMenuItem<String>(
                        value: state.id.toString(),
                        child: Text(state.stateName ?? 'Unknown'),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        regiController.setSelectedState(newValue);
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

  Widget _buildCityDropdown() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 5, right: 5),
      child: Row(
        children: [
          Obx(() {
            if (regiController.rxStatusCityLoading.value == Status.LOADING) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 22),
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.redAccent),
                ),
              );
            } else if (regiController.rxStatusCityLoading.value ==
                Status.ERROR) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Failed to load city'),
                ),
              );
            } else if (regiController.cityList.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('No City available'),
                ),
              );
            } else {
              final selectedCity = regiController.city_id.value;
              return Expanded(
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: selectedCity.isNotEmpty ? 'City *' : null,
                    border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    focusedBorder: const OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.black38, width: 1)),
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
                      'Select City *',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    value: selectedCity.isNotEmpty ? selectedCity : null,
                    items: regiController.cityList.map((CityData city) {
                      return DropdownMenuItem<String>(
                        value: city.id.toString(),
                        child: Text(city.cityName ?? 'Unknown'),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        regiController.setSelectedCity(newValue);
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

  bool _validateForm() {
    final businessName = controller.businessNameController.value.text.trim();
    final businessMobile =
        controller.businessMobileController.value.text.trim();
    final flatNo = controller.businessFlatNoController.value.text.trim();
    final address = controller.businessAddressController.value.text.trim();
    final areaName = controller.businessAreaNameController.value.text.trim();
    final pincode = controller.businessPincodeController.value.text.trim();
    final countryId = regiController.country_id.value;
    final stateId = regiController.state_id.value;
    final cityId = regiController.city_id.value;

    if (businessName.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter business name",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (businessMobile.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter business mobile",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (businessMobile.length != 10) {
      Get.snackbar(
        "Error",
        "Please enter valid 10-digit mobile number",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (flatNo.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter flat/building number",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (address.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter address",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (areaName.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter area/locality",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (pincode.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter pincode",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (pincode.length != 6) {
      Get.snackbar(
        "Error",
        "Please enter valid 6-digit pincode",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (countryId.isEmpty) {
      Get.snackbar(
        "Error",
        "Please select country",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (stateId.isEmpty) {
      Get.snackbar(
        "Error",
        "Please select state",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (cityId.isEmpty) {
      Get.snackbar(
        "Error",
        "Please select city",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  Future<void> _addBusinessDetails(Occupation occupation) async {
    try {
      final businessBody = {
        'member_id': widget.memberId,
        "member_occupation_id": occupation.memberOccupationId,
        "business_name": controller.businessNameController.value.text.trim(),
        "business_mobile":
            controller.businessMobileController.value.text.trim(),
        "business_landline":
            controller.businessLandlineController.value.text.trim(),
        "business_email": controller.businessEmailController.value.text.trim(),
        "business_website":
            controller.businessWebsiteController.value.text.trim(),
        "created_by": widget.memberId,
        "address_type": "office",
        "flat_no": controller.businessFlatNoController.value.text.trim(),
        "address": controller.businessAddressController.value.text.trim(),
        "area_name": controller.businessAreaNameController.value.text.trim(),
        "city_id": regiController.city_id.value,
        "state_id": regiController.state_id.value,
        "country_id": regiController.country_id.value,
        "pincode": controller.businessPincodeController.value.text.trim(),
      };

      debugPrint("📤 Business Details Body: $businessBody");

      final businessResponse = await controller.addOccupationBusinessRepo
          .addOccupationBusiness(businessBody);

      if (businessResponse.status == true) {
        Get.back();
        Get.snackbar(
          "Success",
          businessResponse.message ?? "Business details added successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        _clearBusinessForm();
        _loadBusinessProfiles();
      } else {
        Get.snackbar(
          "Error",
          businessResponse.message ?? "Failed to add business details",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      debugPrint("ADD BUSINESS DETAILS ERROR: $e");
    }
  }

  Future<void> _updateBusinessDetails(
      BusinessOccupationProfile business) async {
    try {
      controller.isOccupationLoading.value = true;

      final body = {
        "member_business_occupation_profile_id": business.profileId,
        "member_occupation_id": widget.memberOccupationId,
        "business_name": controller.businessNameController.value.text.trim(),
        "business_mobile":
            controller.businessMobileController.value.text.trim(),
        "business_landline":
            controller.businessLandlineController.value.text.trim(),
        "business_email": controller.businessEmailController.value.text.trim(),
        "business_website":
            controller.businessWebsiteController.value.text.trim(),
        "updated_by": widget.memberId,
        "address_type": "office",
        "flat_no": controller.businessFlatNoController.value.text.trim(),
        "address": controller.businessAddressController.value.text.trim(),
        "area_name": controller.businessAreaNameController.value.text.trim(),
        "city_id": regiController.city_id.value,
        "state_id": regiController.state_id.value,
        "country_id": regiController.country_id.value,
        "pincode": controller.businessPincodeController.value.text.trim(),
      };

      debugPrint("📤 UPDATE BODY: $body");

      final response = await controller.updateOccupationBusiness
          .updateOccupationBusiness(body);

      controller.isOccupationLoading.value = false;

      if (response.status == true) {
        Get.back();

        Get.snackbar(
          "Success",
          response.message ?? "Business updated successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Refresh list
        _loadBusinessProfiles();
      } else {
        Get.snackbar(
          "Error",
          response.message ?? "Failed to update business",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      controller.isOccupationLoading.value = false;
      debugPrint("❌ UPDATE ERROR: $e");

      Get.snackbar(
        "Error",
        "Something went wrong: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.045;
            return Text(
              "Detailed Business Profile",
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        final occupations = controller.allOccupations;
        final businessProfiles = controller.businessProfiles?.data ?? [];

        if (controller.isOccupationLoading.value && occupations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (occupations.isEmpty) {
          return const Center(child: Text("No occupation found"));
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
            child: Column(
              children: occupations.map((occupation) {
                // Filter businesses for this occupation
                final relatedBusinesses = businessProfiles
                    .where((b) =>
                        b.memberOccupationId == occupation.memberOccupationId)
                    .toList();

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(10),
                  child: _buildOccupationGroupCard(
                    occupation,
                    relatedBusinesses,
                  ),
                );
              }).toList(),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildOccupationGroupCard(
      Occupation occupation,
      List<BusinessOccupationProfile> businesses,
      ) {

    final bool hasBusiness = businesses.isNotEmpty;
    final BusinessOccupationProfile? firstBusiness =
    hasBusiness ? businesses.first : null;

    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔥 HEADER ROW (Title + Button)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    occupation.occupation ?? "Occupation",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade600,
                    ),
                  ),
                ),

                /// ➕ IF NO BUSINESS → Show Add button
                if (!hasBusiness)
                  ElevatedButton.icon(
                    label: const Text("Add Business"),
                    onPressed: () {
                      _showAddBusinessModalSheet(context, occupation);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),

                if (hasBusiness)
                  PopupMenuButton<String>(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditBusinessModalSheet(context, firstBusiness!);
                      } else if (value == 'delete') {
                        _showDeleteConfirmationDialog(context, firstBusiness!);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text(
                          'Edit Business',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                    child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFDC3545),
                        elevation: 2,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                      ),
                      child: const Text(
                        "Edit",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const Divider(height: 20, thickness: .7),

            /// 🔥 LEVELS 1–5
            _buildOccupationInfoRow("Level 1", occupation.occupation),
            _buildOccupationInfoRow(
                "Level 2", occupation.occupationProfessionName),
            _buildOccupationInfoRow("Level 3", occupation.specializationName),
            _buildOccupationInfoRow(
                "Level 4", occupation.specializationSubCategoryName),
            _buildOccupationInfoRow(
                "Level 5", occupation.specializationSubSubCategoryName),

            if (occupation.occupationOtherName != null &&
                occupation.occupationOtherName!.isNotEmpty)
              _buildOccupationInfoRow("Details", occupation.occupationOtherName),

            const SizedBox(height: 10),

            /// 🔥 BUSINESS CONTENT
            if (hasBusiness)
              Column(
                children: businesses
                    .map((b) => _buildBusinessCardInsideGroup(b, occupation))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOccupationInfoRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(" : ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value?.isNotEmpty == true ? value! : "N/A",
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessCardInsideGroup(
      BusinessOccupationProfile business,
      Occupation occupation,
      ) {
    final address =
        (business.addresses != null && business.addresses!.isNotEmpty)
            ? business.addresses!.first as BusinessAddressData
            : null;

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 20),
          Text(
            business.businessName ?? "N/A",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          address != null
              ? _buildBusinessAddressSection(address)
              : const Text(
                  "No address available",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
          const SizedBox(height: 12),
          const Divider(height: 20),
          _buildContactDetailsSection(business),
          const SizedBox(height: 12),
          _buildActionButtons(business, occupation),
        ],
      ),
    );
  }

  Widget _buildBusinessAddressSection(BusinessAddressData address) {
    final addressParts = [
      address.flatNo,
      address.address,
      address.areaName,
      address.cityName,
      address.stateName,
      address.countryName,
      address.pincode
    ].where((part) => part != null && part.isNotEmpty).toList();

    final fullAddress = addressParts.join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Business Address Label
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Business Address:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Address Text
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Text(
            fullAddress.isNotEmpty ? fullAddress : "No address available",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildContactDetailsSection(BusinessOccupationProfile business) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Contact Details:",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        if (business.businessMobile != null &&
            business.businessMobile!.isNotEmpty)
          _buildContactDetailItem(
            icon: Icons.phone,
            label: "Mobile",
            value: business.businessMobile!,
          ),
        if (business.businessLandline != null &&
            business.businessLandline!.isNotEmpty)
          _buildContactDetailItem(
            icon: Icons.phone_in_talk,
            label: "Landline",
            value: business.businessLandline!,
          ),
        if (business.businessEmail != null &&
            business.businessEmail!.isNotEmpty)
          _buildContactDetailItem(
            icon: Icons.email,
            label: "Email",
            value: business.businessEmail!,
          ),
        if (business.businessWebsite != null &&
            business.businessWebsite!.isNotEmpty)
          _buildContactDetailItem(
            icon: Icons.language,
            label: "Website",
            value: business.businessWebsite!,
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildContactDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: ColorHelperClass.getColorFromHex(ColorResources.red_color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BusinessOccupationProfile business,
      Occupation occupation,
      ) {
    final bool showProductListButton = occupation.occupationId == "2";

    return Column(
      children: [
        if (showProductListButton)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _navigateToProductList(context, business);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                ColorHelperClass.getColorFromHex(ColorResources.red_color),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.inventory_2_outlined),
              label: const Text("Product List"),
            ),
          ),
        if (showProductListButton) const SizedBox(height: 10),
      ],
    );
  }

  void _navigateToProductList(
      BuildContext context, BusinessOccupationProfile business) {
    if (business.profileId != null && business.profileId!.isNotEmpty) {
      Get.to(() => ProductListPage(
            profileId: business.profileId!,
          ));
    } else {
      Get.snackbar(
        "Error",
        "Unable to load product list",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _loadBusinessProfiles() {
    controller.getBusinessOccupationProfiles(widget.memberId);
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, BusinessOccupationProfile business) {
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
                "Delete Business",
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
            "Are you sure you want to delete '${business.businessName ?? 'this business'}'?",
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
                foregroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
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
                _deleteBusinessDetails(business);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
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

  Future<void> _deleteBusinessDetails(
      BusinessOccupationProfile business) async {
    try {
      if (business.profileId == null || business.profileId!.isEmpty) {
        Get.snackbar(
          "Error",
          "Invalid business profile ID",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      debugPrint("🗑️ Deleting business: ${business.businessName}");
      debugPrint("🗑️ Business Profile ID: ${business.profileId}");

      if (!(Get.isDialogOpen ?? false)) {
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );
      }

      await controller.deleteBusinessOccupationProfile(
          business.profileId!, widget.memberId);

      // Close loading dialog if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        "Success",
        "${business.businessName ?? 'Business'} deleted successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      await Future.delayed(const Duration(milliseconds: 800));
      // Refresh profiles after delete
      _loadBusinessProfiles();
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        "Error",
        "Failed to delete business: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      debugPrint("DELETE BUSINESS ERROR: $e");
    }
  }
}