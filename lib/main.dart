import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:wakelock/wakelock.dart';

String TITLE = 'Web Wrapper';
Color SEED_COLOR = Colors.greenAccent;
String TARGET_URL = 'https://google.com/';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoaded = false;
  Color _themeSeedColor = SEED_COLOR;

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      DefaultAssetBundle.of(context).loadString('assets/config.json').then(
        (value) {
          // parse string to json
          Map<String, dynamic> config = jsonDecode(value);
          TITLE = config['title'];
          SEED_COLOR = Color(int.parse(config['seed_color']));
          TARGET_URL = config['target_url'];
          setState(() {
            _isLoaded = true;
            if (_themeSeedColor != SEED_COLOR) {
              _themeSeedColor = SEED_COLOR;
            }
          });
        },
      );
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // after loaded
    return MaterialApp(
      title: 'Webview',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _themeSeedColor),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // final _controller = WebViewController();

  // using inappwebview
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        userAgent:
            'Mozilla/5.0 (Linux; CustomAPK) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.4606.85 Mobile Safari/537.36',
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  @override
  void initState() {
    super.initState();
    Wakelock.enable();

    /*
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    _controller.loadRequest(Uri.parse(TARGET_URL));
    */
  }

  @override
  Widget build(BuildContext context) {
    // load asset

    return WillPopScope(
      onWillPop: () async {
        bool canGoBack = false;
        if (webViewController != null) {
          canGoBack = await webViewController!.canGoBack();
        }
        if (canGoBack) {
          webViewController?.goBack();
          return false;
        } else {
          // ask user
          bool? choice = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Exit'),
              content: const Text('Do you want to exit?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Yes'),
                ),
              ],
            ),
          );
          if (choice == true) {
            return true; // only if user choose yes
          }
          return false;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          // make appbar smaller
          toolbarHeight: 36,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(
            TITLE,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                webViewController?.loadUrl(
                    urlRequest: URLRequest(url: Uri.parse(TARGET_URL)));
              },
            ),
            IconButton(
              onPressed: () {
                webViewController?.reload();
              },
              icon: const Icon(Icons.refresh),
            ),
            // three dots
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text('Clear Cache'),
                  value: 'clearcache',
                ),
              ],
              onSelected: (value) {
                if (value == 'clearcache') {
                  webViewController?.clearCache();
                  // show snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cache cleared'),
                    ),
                  );
                }
              },
            ),
          ],
        ),
        body: Center(
          /*
          child: WebViewWidget(
            controller: _controller,
          ),
          */

          child: InAppWebView(
            key: webViewKey,
            initialUrlRequest: URLRequest(url: Uri.parse(TARGET_URL)),
            initialOptions: options,
            // pullToRefreshController: pullToRefreshController,
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onLoadStart: (controller, url) {
              /*
              setState(() {
                this.url = url.toString();
                urlController.text = this.url;
              });
              */
            },
            androidOnPermissionRequest: (controller, origin, resources) async {
              return PermissionRequestResponse(
                  resources: resources,
                  action: PermissionRequestResponseAction.GRANT);
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              return NavigationActionPolicy.ALLOW;
            },
            onLoadStop: (controller, url) async {},
            onLoadError: (controller, url, code, message) {},
            onProgressChanged: (controller, progress) {},
            onUpdateVisitedHistory: (controller, url, androidIsReload) {},
            onConsoleMessage: (controller, consoleMessage) {},
          ),
        ),
      ),
    );
  }
}
