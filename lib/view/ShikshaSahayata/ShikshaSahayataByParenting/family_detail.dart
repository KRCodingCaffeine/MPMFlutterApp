import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/CheckUser/CheckUserData2.dart';
import 'package:mpm/model/GetProfile/FamilyHeadMemberData.dart';
import 'package:mpm/model/GetProfile/FamilyMembersData.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/urls.dart';
import 'package:mpm/view_model/controller/dashboard/NewMemberController.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

class FamilyDetail extends StatefulWidget {
  final String shikshaApplicantId;

  const FamilyDetail({
    Key? key,
    required this.shikshaApplicantId,
  }) : super(key: key);

  @override
  State<FamilyDetail> createState() => _FamilyDetailState();
}

class _FamilyDetailState extends State<FamilyDetail> {
  String? currentMemberId;

  final UdateProfileController controller = Get.find<UdateProfileController>();
  final NewMemberController regiController = Get.find<NewMemberController>();

  @override
  void initState() {
    super.initState();
    _loadSessionData();
  }

  void _loadSessionData() async {
    CheckUserData2? userData = await SessionManager.getSession();
    setState(() {
      currentMemberId = userData?.memberId?.toString();
    });
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
              "Family Detail",
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final List<dynamic> unifiedList = [];

          if (controller.familyHeadData.value != null) {
            unifiedList.add(controller.familyHeadData.value);
          }

          unifiedList.addAll(
            controller.familyDataList.value.where(
              (m) => m.memberId != controller.familyHeadData.value?.memberId,
            ),
          );

          if (unifiedList.isEmpty) {
            return const Center(
              child: Text(
                "No family members found",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: unifiedList.length,
            itemBuilder: (context, index) {
              final item = unifiedList[index];

              if (item is FamilyHeadMemberData) {
                return _buildUnifiedFamilyCard(
                  context: context,
                  name: "${item.firstName ?? ''} ${item.lastName ?? ''}".trim(),
                  memberCode: item.memberCode ?? item.memberId ?? '',
                  profileImage: item.profileImage,
                  isHead: true,
                );
              }

              if (item is FamilyMembersData) {
                return _buildUnifiedFamilyCard(
                  context: context,
                  name: "${item.firstName ?? ''} ${item.lastName ?? ''}".trim(),
                  memberCode: item.memberCode ?? item.memberId ?? '',
                  profileImage: item.profileImage,
                  isHead: false,
                );
              }

              return const SizedBox.shrink();
            },
          );
        }),
      ),
    );
  }

  Widget _buildUnifiedFamilyCard({
    required BuildContext context,
    required String name,
    required String memberCode,
    String? profileImage,
    required bool isHead,

    String? relationName,
    String? status,
    String? jobTitle,
    String? yearlyIncome,
    String? standard,
    String? schoolAddress,
    String? nonEarningReason,
    String? otherDetail,
  }) {
    final bool hasDetails = [
      relationName,
      status,
      jobTitle,
      yearlyIncome,
      standard,
      schoolAddress,
      nonEarningReason,
      otherDetail,
    ].any((e) => e != null && e.toString().trim().isNotEmpty);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.grey[50],
      child: ListTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: profileImage != null && profileImage.isNotEmpty
              ? NetworkImage(Urls.imagePathUrl + profileImage)
              : const AssetImage("assets/images/user3.png") as ImageProvider,
          backgroundColor: Colors.grey[300],
        ),

        title: Text(
          name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),

            Text(
              "Member Code: $memberCode",
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),

            if (hasDetails) ...[
              const SizedBox(height: 8),
              const Divider(height: 1),

              if (relationName != null)
                _detailRow("Relation", relationName),

              if (status != null)
                _detailRow("Status", status),

              if (status == "Earning" && jobTitle != null)
                _detailRow("Job", jobTitle),

              if (status == "Earning" && yearlyIncome != null)
                _detailRow("Income", yearlyIncome),

              if (status == "Non Earning" && nonEarningReason != null)
                _detailRow("Reason", nonEarningReason),

              if (nonEarningReason == "Student" && standard != null)
                _detailRow("Standard", standard),

              if (nonEarningReason == "Student" &&
                  schoolAddress != null)
                _detailRow("School", schoolAddress),

              if (nonEarningReason == "Other" && otherDetail != null)
                _detailRow("Detail", otherDetail),
            ],
          ],
        ),

        trailing: ElevatedButton(
          onPressed: () {
            _showAddRelationSheet(context, name);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.red_color),
            foregroundColor: Colors.white,
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            "Add",
            style: TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String? value) {
    if (value == null || value.trim().isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, color: Colors.black87),
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }


  void _showAddRelationSheet(BuildContext context, String memberName) {
    String selectedStatus = '';
    String selectedNonEarningReason = '';

    final TextEditingController jobTitleCtrl = TextEditingController();
    final TextEditingController yearlyIncomeCtrl = TextEditingController();
    final TextEditingController standardCtrl = TextEditingController();
    final TextEditingController schoolAddressCtrl = TextEditingController();
    final TextEditingController otherDetailCtrl = TextEditingController();

    final List<String> statusOptions = ["Earning", "Non Earning"];
    final List<String> nonEarningOptions = [
      "Homemaker",
      "Retired",
      "Student",
      "Other",
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: FractionallySizedBox(
                heightFactor: 0.5,
                child: Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    ColorHelperClass.getColorFromHex(
                                        ColorResources.red_color),
                                side: BorderSide(
                                  color: ColorHelperClass.getColorFromHex(
                                      ColorResources.red_color),
                                ),
                                padding:
                                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: controller.selectRelationShipType.value
                                          .isEmpty ||
                                      selectedStatus.isEmpty
                                  ? null
                                  : () {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              "$memberName added successfully"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                ColorHelperClass.getColorFromHex(ColorResources.red_color),
                                foregroundColor: Colors.white,
                                padding:
                                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text("Add Family Details"),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Center(
                                child: Text(
                                  "Add Member Detail",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),

                              Obx(() {
                                if (controller.rxStatusRelationType.value ==
                                    Status.LOADING) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                return InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Select Relation *',
                                    border:
                                    const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black),
                                    ),
                                    enabledBorder:
                                    const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black),
                                    ),
                                    focusedBorder:
                                    const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black38,
                                          width: 1),
                                    ),
                                    contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    labelStyle: const TextStyle(
                                        color: Colors.black),
                                  ),
                                  child: DropdownButton<String>(
                                    dropdownColor: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    isExpanded: true,
                                    underline: Container(),
                                    hint: const Text(
                                      'Select Relation',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    value: controller.selectRelationShipType
                                            .value.isEmpty
                                        ? null
                                        : controller
                                            .selectRelationShipType.value,
                                    items: controller.relationShipTypeList
                                        .map((relation) =>
                                            DropdownMenuItem<String>(
                                              value: relation.id.toString(),
                                              child: Text(
                                                  relation.name ?? 'Unknown'),
                                            ))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        controller.setSelectRelationShip(val);
                                      }
                                    },
                                  ),
                                );
                              }),
                              const SizedBox(height: 20),

                              InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Select Status *',
                                  border:
                                  const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black),
                                  ),
                                  enabledBorder:
                                  const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black),
                                  ),
                                  focusedBorder:
                                  const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black38,
                                        width: 1),
                                  ),
                                  contentPadding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  labelStyle: const TextStyle(
                                      color: Colors.black),
                                ),
                                child: DropdownButton<String>(
                                  dropdownColor: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  isExpanded: true,
                                  underline: Container(),
                                  hint: const Text(
                                    'Select Status',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  value: selectedStatus.isEmpty
                                      ? null
                                      : selectedStatus,
                                  items: statusOptions
                                      .map((status) => DropdownMenuItem<String>(
                                            value: status,
                                            child: Text(status),
                                          ))
                                      .toList(),
                                  onChanged: (val) {
                                    setModalState(() {
                                      selectedStatus = val!;
                                      selectedNonEarningReason = '';
                                      jobTitleCtrl.clear();
                                      yearlyIncomeCtrl.clear();
                                      standardCtrl.clear();
                                      schoolAddressCtrl.clear();
                                      otherDetailCtrl.clear();
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),

                              if (selectedStatus == "Earning") ...[
                                TextFormField(
                                  controller: jobTitleCtrl,
                                  decoration: const InputDecoration(
                                    labelText: "Job Title *",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: yearlyIncomeCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: "Yearly Income *",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],

                              if (selectedStatus == "Non Earning") ...[
                                InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Select Reason *',
                                    border:
                                    const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black),
                                    ),
                                    enabledBorder:
                                    const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black),
                                    ),
                                    focusedBorder:
                                    const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black38,
                                          width: 1),
                                    ),
                                    contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    labelStyle: const TextStyle(
                                        color: Colors.black),
                                  ),
                                  child: DropdownButton<String>(
                                    dropdownColor: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    isExpanded: true,
                                    underline: Container(),
                                    hint: const Text(
                                      'Select Reason',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    value: selectedNonEarningReason.isEmpty
                                        ? null
                                        : selectedNonEarningReason,
                                    items: nonEarningOptions
                                        .map((reason) =>
                                            DropdownMenuItem<String>(
                                              value: reason,
                                              child: Text(reason),
                                            ))
                                        .toList(),
                                    onChanged: (val) {
                                      setModalState(() {
                                        selectedNonEarningReason = val!;
                                        standardCtrl.clear();
                                        schoolAddressCtrl.clear();
                                        otherDetailCtrl.clear();
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(height: 20),

                                if (selectedNonEarningReason == "Student") ...[
                                  TextFormField(
                                    controller: standardCtrl,
                                    decoration: const InputDecoration(
                                      labelText: "Standard *",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: schoolAddressCtrl,
                                    maxLines: 2,
                                    decoration: const InputDecoration(
                                      labelText: "School Address *",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ],

                                if (selectedNonEarningReason == "Other") ...[
                                  TextFormField(
                                    controller: otherDetailCtrl,
                                    maxLines: 2,
                                    decoration: const InputDecoration(
                                      labelText: "Other Detail *",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ],
                              ],
                              const SizedBox(height: 30),
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
      },
    );
  }
}
