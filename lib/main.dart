// import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:wakelock/wakelock.dart';

const TITLE = 'Web Wrapper';
const SEED_COLOR = Colors.greenAccent;
const TARGET_URL = 'https://google.com/';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Webview',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: SEED_COLOR),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: TITLE),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

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
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));
  /*
  late PullToRefreshController pullToRefreshController;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();
  */

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    /*
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    _controller.loadRequest(Uri.parse(TARGET_URL));
    */

    /*
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
    */
  }

  @override
  Widget build(BuildContext context) {
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
            widget.title,
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
              // var uri = navigationAction.request.url!;

              // if (![
              //   "http",
              //   "https",
              //   "file",
              //   "chrome",
              //   "data",
              //   "javascript",
              //   "about"
              // ].contains(uri.scheme)) {
              //   if (await canLaunch(url)) {
              //     // Launch the App
              //     await launch(
              //       url,
              //     );
              //     // and cancel the request
              //     return NavigationActionPolicy.CANCEL;
              //   }
              // }

              return NavigationActionPolicy.ALLOW;
            },
            onLoadStop: (controller, url) async {
              /*
              pullToRefreshController.endRefreshing();
              setState(() {
                this.url = url.toString();
                urlController.text = this.url;
              });
              */
            },
            onLoadError: (controller, url, code, message) {
              /*
              pullToRefreshController.endRefreshing();
              */
            },
            onProgressChanged: (controller, progress) {
              /*
              if (progress == 100) {
                pullToRefreshController.endRefreshing();
              }
              setState(() {
                this.progress = progress / 100;
                urlController.text = this.url;
              });
              */
            },
            onUpdateVisitedHistory: (controller, url, androidIsReload) {
              /*
              setState(() {
                this.url = url.toString();
                urlController.text = this.url;
              });
              */
            },
            onConsoleMessage: (controller, consoleMessage) {
              print(consoleMessage);
            },
          ),
        ),
      ),
    );
  }
}
