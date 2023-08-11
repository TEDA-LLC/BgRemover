import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../common/widgets.dart';
import '../providers/images_provider.dart';

class ImageContainer extends StatelessWidget {
  final File? file;
  final bool topBorder;
  const ImageContainer(this.file, {this.topBorder = false, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imagesProvider = Provider.of<ImagesProvider>(context, listen: false);
    final appLocalization = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      width: double.infinity,
      decoration: BoxDecoration(
          border: topBorder
              ? Border.all(width: 3)
              : const Border(
                  left: BorderSide(width: 3),
                  right: BorderSide(width: 3),
                  bottom: BorderSide(width: 3),
                )),
      child: file == null
          ? const SizedBox()
          : GestureDetector(
              child: Image.file(
                file!,
                errorBuilder: (ctx, object, stacktrace) {
                  WidgetsBinding.instance.addPostFrameCallback((callback) =>
                      imagesProvider.updateOriginalImageErrorState(true));
                  return SizedBox(
                      height: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warning,
                            color: Colors.red[500],
                          ),
                          Text(appLocalization?.failedToLoad??""),
                        ],
                      ));
                },
              ),
              onTap: () {
                showActionsDialog(context, file!);
              }),
    );
  }
}
