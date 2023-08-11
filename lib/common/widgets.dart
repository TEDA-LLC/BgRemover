import 'package:flutter/material.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<dynamic> showErrorDialog(BuildContext context,
    {required String errorText}) {
  return showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(AppLocalizations.of(ctx)?.errorOccurred ?? ""),
          content: Text(errorText),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK")),
          ],
        );
      });
}

Future<dynamic> showActionsDialog(BuildContext context, File file) {
  final appLocalizations = AppLocalizations.of(context);
  return showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(appLocalizations?.chooseAction ?? ""),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(appLocalizations?.cancel ?? "")),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      showImageViewer(context, Image.file(file).image);
                    },
                    child: Text(appLocalizations?.view ?? "")),
                ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      final path = file.path;
                      final shareResult = await Share.shareXFiles([XFile(path)],
                          subject:
                              "${appLocalizations?.shareImage}$path" ?? "");
                      if (shareResult.status == ShareResultStatus.success) {
                        if (context.mounted) {
                          showSnackBarWithAction(
                              context, appLocalizations?.imageShared ?? "");
                        }
                      }
                    },
                    child: Text(appLocalizations?.share ?? "")),
              ],
            ),
          ],
        );
      });
}

void showSnackBarWithAction(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(content),
    action: SnackBarAction(
        label: "OK",
        onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar()),
  ));
}
