import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class ShowWebView extends StatelessWidget {
  String url;
  String title;
  ShowWebView(this.url, this.title);

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: url,
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
    );
  }

}