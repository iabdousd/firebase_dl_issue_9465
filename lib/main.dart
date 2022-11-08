import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dl_issue/firebase_options.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  ShortDynamicLink? link;

  @override
  void initState() {
    _init();
    super.initState();
  }

  void _init() async {
    final initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink != null) _onLink(initialLink);
    FirebaseDynamicLinks.instance.onLink.listen(_onLink);
  }

  void _onLink(PendingDynamicLinkData linkData) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Opened a link!'),
          content: Text('Link: ${linkData.link}'),
        ),
      );

  void _createLink() async {
    link = await FirebaseDynamicLinks.instance.buildShortLink(
      DynamicLinkParameters(
        androidParameters: const AndroidParameters(
          packageName: 'com.roamtogether.firebase_dl_issue',
        ),
        navigationInfoParameters: const NavigationInfoParameters(
          forcedRedirectEnabled: true,
        ),
        socialMetaTagParameters: const SocialMetaTagParameters(
          title: 'The FDL sub-domain issue',
          description: 'Click on me to reproduce the sub-domain issue '
              'in Firebase dynamic links',
        ),
        link: Uri.parse('https://test.roamtogether.store/link'),
        uriPrefix: 'https://test.roamtogether.store',
      ),
    );
    setState(() {});
  }

  void _copyLink() =>
      Clipboard.setData(ClipboardData(text: link!.shortUrl.toString()));

  void _openLink() =>
      launchUrl(link!.shortUrl, mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                link == null
                    ? 'Click on the following button to create a dynamic link'
                    : 'Generated link:\n${link!.shortUrl}',
                style: Theme.of(context).textTheme.subtitle1,
                textAlign: TextAlign.center,
              ),
            ),
            if (link == null)
              ElevatedButton(
                onPressed: _createLink,
                child: const Text('Create a dynmic link'),
              )
            else ...[
              ElevatedButton(
                onPressed: _copyLink,
                child: const Text('Copy the link'),
              ),
              ElevatedButton(
                onPressed: _openLink,
                child: const Text('Open the link'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
