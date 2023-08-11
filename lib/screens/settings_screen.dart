import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/widgets.dart';
import '../providers/app_config_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  static const routeName = 'settings_screen';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  Future<void> _launchBrowser({required String errorText}) async {
    final url = Uri.parse("https://www.remove.bg/dashboard#api-key");
    if (await canLaunchUrl(url)) {
      launchUrl(url);
    } else {
      if (mounted) {
        showErrorDialog(context, errorText: errorText);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appConfigProvider = Provider.of<AppConfigProvider>(context);
    final darkTheme = appConfigProvider.darkTheme;
    final apiKey = appConfigProvider.apiKey;
    textEditingController.text = apiKey;
    final balance = appConfigProvider.balance;

    final AppLocalizations? appLocalization = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalization?.settings??""),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.brightness_4),
            title: Text(appLocalization?.darkTheme??""),
            subtitle: Text(appLocalization?.setTheme??""),
            trailing: Switch(
              value: darkTheme,
              onChanged: (_) {
                appConfigProvider.toggleTheme();
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.key),
            title: const Text("API key"),
            subtitle: Text(apiKey),
            onTap: () async {
              final newApiKey = await showDialog(
                  context: context,
                  builder: (ctx) {
                    return AlertDialog(
                      title: const Text("API key"),
                      content: TextField(
                        decoration: InputDecoration(
                          labelText: appLocalization?.pasteApiKey ?? "",
                        ),
                        controller: textEditingController,
                        maxLines: 1,
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(appLocalization?.cancel ?? "")),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(textEditingController.text);
                              // Navigator.of(context).pop();
                              // if (apiKey != textEditingController.text) {
                              //   final oldApiKey = apiKey;
                              //   appConfigProvider
                              //       .setApiKey(textEditingController.text);
                              //
                              //   ScaffoldMessenger.of(context)
                              //       .showSnackBar(SnackBar(
                              //     action: SnackBarAction(
                              //       label: appLocalization?.undo??"",
                              //       onPressed: () {
                              //         appConfigProvider.setApiKey(oldApiKey);
                              //         ScaffoldMessenger.of(context)
                              //             .hideCurrentSnackBar();
                              //       },
                              //     ),
                              //     content: Text(appLocalization?.apiKeyUpdated??""),
                              //   ));
                              // }
                            },
                            child: const Text("OK")),
                      ],
                    );
                  });
              if (newApiKey != null && apiKey != newApiKey) {
                final oldApiKey = apiKey;
                await Future.delayed(const Duration(milliseconds: 250),() {
                  appConfigProvider
                      .setApiKey(newApiKey);

                  if (mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(
                      action: SnackBarAction(
                        label: appLocalization?.undo??"",
                        onPressed: () {
                          appConfigProvider.setApiKey(oldApiKey);
                          ScaffoldMessenger.of(context)
                              .hideCurrentSnackBar();
                        },
                      ),
                      content: Text(appLocalization?.apiKeyUpdated??""),
                    ));
                  }
                });

              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.call_made),
            title: Text(appLocalization?.remainingFreeCalls??""),
            subtitle: Text("$balance"),
          ),
          Container(
            height: 2,
            color: Theme.of(context).canvasColor,
            margin: const EdgeInsets.only(top: 5, bottom: 15),
          ),
          ElevatedButton(
            onPressed: () async {
              await _launchBrowser(errorText: appLocalization?.cannotOpenBrowser??"");
            },
            child: Text(appLocalization?.getApiKey??""),
          ),
        ],
      ),
    );
  }
}
