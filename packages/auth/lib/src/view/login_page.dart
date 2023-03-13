import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _uri = "https://platform.openai.com/login/";

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return _DesktopLoginPage(uri: _uri);
    } else if (Platform.isAndroid || Platform.isIOS) {
      return _MobileLoginPage(uri: _uri);
    }

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}

class _DesktopLoginPage extends StatefulWidget {
  const _DesktopLoginPage({required this.uri});

  final String uri;

  @override
  State<_DesktopLoginPage> createState() => __DesktopLoginPageState();
}

class __DesktopLoginPageState extends State<_DesktopLoginPage> {
  bool _isWebviewAvailable = false;

  void _openWebview() async {
    await WebviewWindow.create(
      configuration: const CreateConfiguration(
        title: 'Login',
        titleBarHeight: 0,
      ),
    )
      ..launch(widget.uri)
      ..addOnUrlRequestCallback((url) {
        if (kDebugMode) {
          debugPrint('url: $url');

          final uri = Uri.parse(url);

          print(uri.queryParametersAll);
        }
      });
  }

  @override
  void initState() {
    super.initState();

    WebviewWindow.isWebviewAvailable().then((value) {
      setState(() {
        _isWebviewAvailable = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isWebviewAvailable) {
      _openWebview();
    } else {
      return const Scaffold(
        body: Center(
          child: Text(
            'Webview Runtime is currently not available on this device',
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _MobileLoginPage extends StatefulWidget {
  const _MobileLoginPage({required this.uri});

  final String uri;

  @override
  State<_MobileLoginPage> createState() => __MobileLoginPageState();
}

class __MobileLoginPageState extends State<_MobileLoginPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (kDebugMode) {
              debugPrint('url: $url');

              final uri = Uri.parse(url);

              print(uri.queryParametersAll);
            }
          },
          onPageFinished: (String url) {
            if (kDebugMode) {
              debugPrint('url: $url');

              final uri = Uri.parse(url);

              print(uri.queryParametersAll);
            }
          },
          onWebResourceError: (WebResourceError error) {},
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: WebViewWidget(
          controller: _controller
            ..loadRequest(
              Uri.parse(widget.uri),
            ),
        ),
      ),
    );
  }
}
