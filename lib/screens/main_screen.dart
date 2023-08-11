import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:bg_crops/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:math' as math;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/const.dart';
import '../common/widgets.dart';
import '../providers/app_config_provider.dart';
import '../providers/images_provider.dart';
import '../widgets/image_container.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _scrollController = ScrollController();

  File? _originalFile;
  File? _resultedFile;

  String? appDirectoryPath;

  var isInit = false;

  Future<File?> _addPhoto({ImageSource source = ImageSource.gallery}) async {

    //if platform mac os
    if (Platform.isMacOS) {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
      );
      if (pickedFile != null) {
        File file = File(pickedFile.path);
        return file;
      }
    }else{
      final pickedFile = await ImagePicker().pickImage(
        source: source,
      );
      if (pickedFile != null) {
        File file = File(pickedFile.path);
        return file;
      }
    }

    return null;
  }

  Future<Uint8List> _removeBackground(File uploadedFile, String apiKey) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(removeBgUrl))
        ..headers["X-Api-Key"] = apiKey
        ..files.add(http.MultipartFile.fromBytes(
            'image_file', await uploadedFile.readAsBytes(),
            filename: 'image.png'));

      final response = await request.send();

      if (response.statusCode >= 400) {
        final responseString = await response.stream.bytesToString();
        final encodedResp = json.decode(responseString) as Map<String, dynamic>;
        throw Exception(encodedResp['errors'][0]['title']);
      }

      var responseData = await response.stream.toBytes();
      return responseData;
    } catch (err, stacktrace) {
      print(stacktrace);
      rethrow;
    }
  }

  Future<File> _saveImage(Uint8List byteStream, String savedImagePath) async {
    File returnedFile = await File(savedImagePath).create(recursive: true);
    await returnedFile.writeAsBytes(byteStream);

    GallerySaver.saveImage(savedImagePath);
    return returnedFile;
  }

  void _scrollToEnd() {
    Timer(const Duration(milliseconds: 500), () {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  @override
  Future<void> didChangeDependencies() async {
    if (!isInit) {
      appDirectoryPath =
          await getApplicationDocumentsDirectory().then((value) => value.path);

      if (mounted) {
        final provider = Provider.of<AppConfigProvider>(context, listen: false);
        provider
            .getFreeCall()
            .then((balance) => provider.updateBalance(balance));

        final prefs = await SharedPreferences.getInstance();
        final apiKey = prefs.getString('apiKey');
        if (apiKey != null) {
          provider.setApiKey(apiKey);
        }
      }

      isInit = true;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imagesProvider = Provider.of<ImagesProvider>(context);
    final imageState = imagesProvider.imageProcessingState;
    final appConfigProvider =
        Provider.of<AppConfigProvider>(context, listen: false);
    final horizontalSplit = appConfigProvider.horizontalSplit;

    final AppLocalizations? appLocalization = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Background Remover"),
        actions: [
          IconButton(
              onPressed: () async {
                appConfigProvider.toggleSplitMode();
              },
              icon: Transform.rotate(
                  angle: horizontalSplit ? math.pi / 2 : 0,
                  child: const Icon(Icons.splitscreen_sharp))),
          IconButton(
              onPressed: () async {
                if (mounted) {
                  Navigator.of(context).pushNamed(SettingsScreen.routeName);
                }
              },
              icon: const Icon(Icons.settings)),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(width: 3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () async {
                      _originalFile = await _addPhoto();
                      if (_originalFile != null) {
                        if (imageState == ImageProcessingState.empty) {
                          imagesProvider.toPhase(ImageProcessingState.added);
                        } else {
                          imagesProvider.toPhase(ImageProcessingState.added);
                        }
                        _scrollToEnd();
                      }
                    },
                    child: Column(
                      children: [
                        const Icon(
                          Icons.image,
                          size: 60,
                        ),
                        Text(appLocalization?.choosePhoto ?? "")
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      /*_originalFile =
                          await _addPhoto(source: ImageSource.camera);
                      if (_originalFile != null) {
                        if (imageState == ImageProcessingState.empty) {
                          imagesProvider.toPhase(ImageProcessingState.added);
                          _scrollToEnd();
                        } else {
                          imagesProvider.toPhase(ImageProcessingState.added);
                        }
                      }*/
                      if (Platform.isMacOS) {
                        _originalFile =
                            await _addPhoto(source: ImageSource.gallery);
                        if (_originalFile != null) {
                          if (imageState == ImageProcessingState.empty) {
                            imagesProvider
                                .toPhase(ImageProcessingState.added);
                            _scrollToEnd();
                          } else {
                            imagesProvider
                                .toPhase(ImageProcessingState.added);
                          }
                        }
                      } else {
                        _originalFile =
                            await _addPhoto(source: ImageSource.camera);
                        if (_originalFile != null) {
                          if (imageState == ImageProcessingState.empty) {
                            imagesProvider
                                .toPhase(ImageProcessingState.added);
                            _scrollToEnd();
                          } else {
                            imagesProvider
                                .toPhase(ImageProcessingState.added);
                          }
                        }
                      }
                    },
                    child: Column(
                      children: [
                        const Icon(
                          Icons.camera_alt,
                          size: 60,
                        ),
                        Text(appLocalization?.capturePhoto ?? ""),
                      ],
                    ),
                  )
                ],
              ),
            ),
            if (imageState == ImageProcessingState.empty)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(appLocalization?.addAnImage ?? "")),
              ),
            if (imageState != ImageProcessingState.empty && horizontalSplit)
              ImageContainer(_originalFile),
            if (imageState != ImageProcessingState.empty && !horizontalSplit)
              Row(
                children: [
                  Expanded(child: ImageContainer(_originalFile)),
                  Expanded(
                      child: imageState == ImageProcessingState.processed
                          ? ImageContainer(_resultedFile)
                          : const SizedBox())
                ],
              ),
            if (imageState != ImageProcessingState.empty)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: ElevatedButton(
                  onPressed: () async {
                    if (imagesProvider.originalImageCorrupted) {
                      showErrorDialog(context,
                          errorText:
                              appLocalization?.cannotRemoveBackground ?? "");
                    } else {
                      if (imageState == ImageProcessingState.added) {
                        imagesProvider.toPhase(ImageProcessingState.processing);
                        _scrollToEnd();

                        try {
                          final byteStream =
                              await _removeBackground(_originalFile!, appConfigProvider.apiKey);
                          _resultedFile = await _saveImage(byteStream,
                              "$appDirectoryPath/${DateFormat('yyyy-MM-dd HH:mm:ss:SSS').format(DateTime.now())}.png");

                          appConfigProvider.getFreeCall().then((balance) =>
                              appConfigProvider.updateBalance(balance));

                          imagesProvider.toPhase(ImageProcessingState.processed);
                          _scrollToEnd();
                        } catch (err) {
                          showErrorDialog(context, errorText: err.toString());
                          imagesProvider.toPhase(ImageProcessingState.added);
                        }

                      } else if (imageState ==
                          ImageProcessingState.processing) {
                        return;
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(AppLocalizations.of(context)
                                  ?.removalFinishedAlert ??
                              ""),
                          action: SnackBarAction(
                              label: "OK",
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                              }),
                        ));
                      }
                    }
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          imageState.index <= 1 ? Colors.blue : Colors.grey)),
                  statesController: MaterialStatesController(),
                  child: Text(imageState.index <= 2
                      ? AppLocalizations.of(context)?.removeBackground ?? ""
                      : AppLocalizations.of(context)?.backgroundRemoved ?? ""),
                ),
              ),
            if (imageState == ImageProcessingState.added)
              const SizedBox(
                height: 20,
              ),
            if (imageState == ImageProcessingState.processing)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    const Padding(
                        padding: EdgeInsets.only(bottom: 5),
                        child: LinearProgressIndicator()),
                    Text(appLocalization?.processing ?? "")
                  ],
                ),
              ),
            if (imageState == ImageProcessingState.processed && horizontalSplit)
              ImageContainer(_resultedFile, topBorder: true)
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
