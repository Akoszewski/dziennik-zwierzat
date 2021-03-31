import 'package:flutter/widgets.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart'
  hide JavascriptChannel, JavascriptMessage;

class Index extends StatelessWidget {
  Index(this.url);
  final String url;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: WebviewScaffold(
          url: url,
      )
    );
  }
}
