import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class AvailOfferPage extends StatefulWidget {
  const AvailOfferPage({super.key});

  @override
  State<AvailOfferPage> createState() => _AvailOfferPageState();
}

class _AvailOfferPageState extends State<AvailOfferPage> {
  final List<String> offerList = [];
  XFile? selectedImage;

  // Image picker function
  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        selectedImage = image;
      });
    }
  }

  // Show bottom sheet to choose between Camera or Gallery
  void showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.grey),
              title: const Text('Take a Picture'),
              onTap: () {
                Navigator.of(context).pop();
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo, color: Colors.grey),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                pickImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  void _showInputDialog() {
    String tempInput = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Enter Offer Detail'),
          content: TextField(
            onChanged: (value) {
              tempInput = value;
            },
            decoration: const InputDecoration(
              hintText: 'Enter something...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
              ),
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('OK'),
              onPressed: () {
                if (tempInput.trim().isNotEmpty) {
                  setState(() {
                    offerList.add(tempInput.trim());
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: const Text("Avail Offer", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showInputDialog,
          ),
        ],
      ),
      body: offerList.isEmpty
          ? const Center(
        child: Text(
          'No offers added yet!',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: offerList.length + 1,
        itemBuilder: (context, index) {
          if (index < offerList.length) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Row(
                    children: [
                      Text('${index + 1}. ',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(child: Text(offerList[index])),
                    ],
                  ),
                ),
                const Divider(thickness: 0.5, color: Colors.grey),
              ],
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => showImagePickerOptions(context),
                  child: const Text("Upload Image", style: TextStyle(fontSize: 16)),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
