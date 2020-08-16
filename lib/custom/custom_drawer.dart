import 'package:ScanKar/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'custom_list_tile.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key key}) : super(key: key);

  Future<void> _launchInWebViewOrVC() async {
    if (await canLaunch(Constants.PRIVACY_URL)) {
      await launch(
        Constants.PRIVACY_URL,
        forceSafariVC: true,
        forceWebView: true,
        // headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $Constants.PRIVACY_URL';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Drawer(
        child: Stack(
          children: <Widget>[
            ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Constants.MAIN_COLOR, Colors.orangeAccent])),
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.0),
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: AssetImage('assets/images/icon.png'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                          child: Text(
                            "ScanKar",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                CustomListTile(Icons.home, "Home", () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(Constants.ROUTE_HOME);
                }),
                CustomListTile(Icons.scanner, "Scan document", () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(Constants.ROUTE_SCAN_NEW);
                }),
                CustomListTile(Icons.security, "Privacy Policy", () {
                  _launchInWebViewOrVC();
                }),
                CustomListTile(Icons.exit_to_app, "Exit", () {
                  Navigator.of(context).pop();
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                }),
              ],
            ),
            Positioned(
              bottom: 5,
              left: 50,
              child: Row(
                children: <Widget>[
                  Text('Make in India'),
                  Image.asset(
                    'assets/images/make-in-india.png',
                    height: 50,
                    width: 80,
                  ),
                  Text('initiative'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
