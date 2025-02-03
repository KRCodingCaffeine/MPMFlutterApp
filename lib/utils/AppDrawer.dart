import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/route/route_name.dart';
import 'package:mpm/utils/images.dart';


class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.grey),
            child: Row(
              children: [
                Image.asset(Images.logoImage,
                  width: 80,
                  height: 80,
                ),
                Text(
                  'Maheshwari Pragati Mandal',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {

            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('My Profile'),
            onTap: () {

            },
          ),
          ListTile(
            leading: Icon(Icons.search),
            title: Text('Search Members'),
            onTap: () {
              Navigator.pushNamed(context, RouteNames.searchmember);
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Samiti Members'),
            onTap: () async {
              Navigator.pushNamed(context, RouteNames.samitimemberview);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Make New Member'),
            onTap: () {

            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('About Us'),
            onTap: () {
              Navigator.pushNamed(context, RouteNames.aboutUs);
            },
          ),
          ListTile(
            leading: Icon(Icons.support_agent_rounded),
            title: Text('Contact Us'),
            onTap: () {
              Navigator.pushNamed(context, RouteNames.contactUs);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Pravacy Policy'),
            onTap: () {
              Navigator.pushNamed(context, RouteNames.pravacypolicy);
            },
          )
          ,ListTile(
            leading: Icon(Icons.document_scanner),
            title: Text('Terms & Condition'),
            onTap: () {
              Navigator.pushNamed(context, RouteNames.termandcondition);
            },
          ),
          ListTile(
            leading: Icon(Icons.help_center),
            title: Text('Help & Support '),
            onTap: () {

            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              Get.back(); // Close Drawer
            },
          ),
        ],
      ),
    );
  }
}
