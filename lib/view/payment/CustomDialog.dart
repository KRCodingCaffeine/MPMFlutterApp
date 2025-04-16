import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/utils/dimensions.dart';
import 'package:mpm/view_model/controller/updateprofile/UdateProfileController.dart';

class CustomDialog extends StatelessWidget {
  final String title, description, buttonText;
  final Image image;
  UdateProfileController controller =Get.put(UdateProfileController());
  CustomDialog({
    required this.title,
    required this.description,
    required this.buttonText,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(36),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }
  Widget dialogContent(BuildContext context){
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            top: Dimensions.avatarRadius + Dimensions.padding,
            bottom: Dimensions.padding,
            left: Dimensions.padding,
            right: Dimensions.padding,
          ),
          margin: EdgeInsets.only(top: Dimensions.avatarRadius),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(Dimensions.padding),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),

            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 24.0),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () {
                    controller.getUserProfile();
                    Navigator.of(context).pop(); // To close the dialog
                  },
                  child: Text(buttonText),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: Dimensions.padding,
          right: Dimensions.padding,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: Dimensions.avatarRadius,
            child: image,
          ),

        ),
      ],
    );
  }
}