import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class NetworkView extends StatefulWidget {
  const NetworkView({super.key});

  @override
  State<NetworkView> createState() => _NetworkViewState();
}

class _NetworkViewState extends State<NetworkView> {
  // ============================================================================
  // EXISTING CODE PRESERVED BELOW - DO NOT DELETE
  // This code will be restored when the networking feature is ready
  // ============================================================================
  
  /*
  String selectedCategory = 'All';
  final List<String> categories = ['All', 'Professionals', 'Business', 'Entrepreneurs'];
  final List<Map<String, String>> members = [
    {
      'name': 'Karthika Rajesh',
      'profession': 'Android Developer',
      'zone': 'Ghatkopar',
      'image': 'https://avatar.iran.liara.run/public/girl?username=Ash'
    },
    {
      'name': 'Manoj kumar Murugan',
      'profession': 'Full Stack Developer',
      'zone': 'Wadala',
      'image': 'https://avatar.iran.liara.run/public/boy?username=Ash'
    },
    {
      'name': 'Satya Narayan Somani',
      'profession': 'Manager',
      'zone': 'Dadar',
      'image': 'https://avatar.iran.liara.run/public/45'
    },
    {
      'name': 'Rajesh',
      'profession': 'Chartered Accountant',
      'zone': 'Thane',
      'image': 'https://avatar.iran.liara.run/public/4'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.045;
            return Text(
              'Networking',
              style: TextStyle(
                  color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.w500),
            );
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name, profession or zone...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🏷️ Filter Chips
          SizedBox(
            height: 45,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == selectedCategory;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  selectedColor:
                  ColorHelperClass.getColorFromHex(ColorResources.logo_color),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500),
                  onSelected: (_) {
                    setState(() => selectedCategory = category);
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // 👥 Members List
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 12),
                      CircleAvatar(
                        radius: 38,
                        backgroundImage: NetworkImage(member['image']!),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        member['name']!,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        member['profession']!,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        member['zone']!,
                        style: TextStyle(
                            fontSize: 12,
                            color: ColorHelperClass.getColorFromHex(
                                ColorResources.logo_color),
                            fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      Container(
                        width: double.infinity,
                        margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Connecting with ${member['name']}...')),
                            );
                          },
                          icon: const Icon(Icons.chat_bubble_outline, size: 18),
                          label: const Text('Connect'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorHelperClass.getColorFromHex(
                                ColorResources.red_color),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            textStyle: const TextStyle(fontSize: 13),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  */
  
  // ============================================================================
  // COMING SOON SCREEN - TEMPORARY IMPLEMENTATION
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.045;
            return Text(
              'Networking',
              style: TextStyle(
                  color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.w500),
            );
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 120,
                color: ColorHelperClass.getColorFromHex(ColorResources.logo_color).withOpacity(0.6),
              ),
              const SizedBox(height: 32),
              Text(
                'Coming Soon',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Networking feature is under development',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Stay tuned for exciting updates!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: ColorHelperClass.getColorFromHex(ColorResources.logo_color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Connect with members • Find professionals • Build your network',
                  style: TextStyle(
                    fontSize: 13,
                    color: ColorHelperClass.getColorFromHex(ColorResources.logo_color),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
