import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:strivacity_flutter/strivacity_flutter.dart';

import '../styles.dart';

class StaticWidget extends StatelessWidget {
  final StaticWidgetModel config;

  const StaticWidget({
    super.key,
    required this.config,
  });

  Future<void> onLinkTap(String? url) async {
    if (url == null || !await launchUrl(Uri.parse(url))) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: Styles.paddingMedium),
      child: config.render.type == 'html'
          ? Html(
              style: {
                '*': Style(fontSize: FontSize(Styles.textSizeMedium), margin: Margins.all(0)),
                'a': Styles.linkStyle,
                'html': Style(textAlign: TextAlign.center),
              },
              data: config.value,
              onLinkTap: (url, attributes, element) => onLinkTap(url),
            )
          : Text(
              config.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: config.id == "section-title" ? Styles.textSizeLarge : Styles.textSizeMedium,
                fontWeight: config.id == "section-title" ? FontWeight.bold : FontWeight.normal,
              ),
            ),
    );
  }
}
