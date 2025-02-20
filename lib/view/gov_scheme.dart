import 'package:flutter/material.dart';
import 'package:mpm/utils/AppDrawer.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GovSchemeView extends StatefulWidget {
  @override
  _GovSchemeViewState createState() => _GovSchemeViewState();
}

class _GovSchemeViewState extends State<GovSchemeView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadFlutterAsset('assets/webview_page.html'); // Load HTML from assets
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.logo_color),
          title: Text(
              "Government Schemes", style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: AppDrawer(),
      body: WebViewWidget(controller: _controller),
    );
  }
}
