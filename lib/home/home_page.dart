import 'dart:developer';
import 'dart:io';
import 'dart:typed_data'; 

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';  
import '../utils/global_variable.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _MainPageState();
}

class _MainPageState extends State<HomePage> with SingleTickerProviderStateMixin {
  String strAnswer = '';
  bool visibleSP = false;
  File? imageFile;
  final imagePicker = ImagePicker();
  late final GenerativeModel _model;
  bool _loading = false;
  Uint8List? webImage; // Mengubah menjadi Uint8List?

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: API_KEY,
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber.shade100,
          centerTitle: true,
          title: const Text('Leaf Diseases Gemini AI',
              style: TextStyle(
                  color: Color(0xFF5A5A5A)
              )
          ),
        ),
        body: ListView(
          children: [
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (BuildContext context) {
                      return Padding(
                          padding: const EdgeInsets.only(
                              bottom: 40, left: 20, right: 20
                          ),
                          child: Container(
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(30)
                                  )
                              ),
                              height: 150,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Flexible(
                                          child: GestureDetector(
                                            onTap: () {
                                              getFromGallery();
                                              Navigator.pop(context);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(20),
                                              decoration: const BoxDecoration(
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(200)
                                                  ),
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.center,
                                                    colors: [
                                                      Colors.red,
                                                      Colors.redAccent
                                                    ],
                                                  )
                                              ),
                                              child: const Icon(
                                                Icons.image_search_outlined,
                                                color: Colors.white,
                                                size: 35,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const Text(
                                          'Galeri',
                                        ),
                                      ]
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Flexible(
                                        child: GestureDetector(
                                          onTap: () {
                                            getFromCamera();
                                            Navigator.pop(context);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(20),
                                            decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(200)
                                                ),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.center,
                                                  colors: [
                                                    Colors.blue,
                                                    Colors.blueAccent
                                                  ],
                                                )
                                            ),
                                            child: const Icon(
                                              Icons.camera_alt_outlined,
                                              color: Colors.white,
                                              size: 35,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        'Kamera',
                                      ),
                                    ],
                                  )
                                ],
                              )
                          )
                      );
                    });
              },
              child: Container(
                margin: const EdgeInsets.all(20),
                width: size.width,
                height: 250,
                child: DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(12),
                    color: const Color(0xFF5A5A5A),
                    strokeWidth: 1,
                    dashPattern: const [5, 5],
                    child: SizedBox.expand(
                      child: FittedBox(
                        child: imageFile != null
                            ? Image.file(File(imageFile!.path), fit: BoxFit.cover)
                            : (webImage != null
                                ? Image.memory(Uint8List.fromList(webImage!), fit: BoxFit.cover)  // Konversi ke Uint8List
                                : const Icon(Icons.image_search, color: Color(0xFF5A5A5A))
                            ),
                      ),
                    ),
                ),
              ),
            ),
            if (!_loading)
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5A5A5A),
                      shape: const StadiumBorder()),
                  onPressed: () async {
                    if (imageFile != null || webImage != null) {
                      setState(() {
                        _loading = true;
                      });

                      try {
                        final content = [
                          Content.multi([
                            TextPart(KEYWORD),
                            if (imageFile != null)
                              DataPart('image/jpeg', File(imageFile!.path).readAsBytesSync()),
                            if (webImage != null)
                              DataPart('image/jpeg', webImage!), // Menyertakan gambar web
                          ])
                        ];

                        var strResponse = await _model.generateContent(content);
                        var strResponsText = strResponse.text;

                        if (strResponsText == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 10),
                                Text('Ups, error Gemini AI!',
                                    style: TextStyle(
                                        color: Colors.white
                                    )
                                )
                              ],
                            ),
                            backgroundColor: Colors.red,
                            shape: StadiumBorder(),
                            behavior: SnackBarBehavior.floating,
                          ));
                          return;
                        } else {
                          setState(() {
                            _loading = false;
                            strAnswer = strResponsText.toString();
                            visibleSP = true;
                          });
                        }
                      } catch (e) {
                        log(e.toString());
                        setState(() {
                          _loading = false;
                        });
                      } finally {
                        setState(() {
                          _loading = false;
                        });
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.white,
                            ),
                            SizedBox(width: 10),
                            Text('Ups, image not found!',
                                style: TextStyle(
                                    color: Colors.white
                                )
                            )
                          ],
                        ),
                        backgroundColor: Colors.red,
                        shape: StadiumBorder(),
                        behavior: SnackBarBehavior.floating,
                      ));
                    }
                  },
                  child: const Text('Identifikasi Tanaman'),
                ),
              )
            else
              SizedBox(
                height: size.height / 5,
                child: const Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5A5A5A))
                  ),
                ),
              ),
            Visibility(
              visible: visibleSP,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF5A5A5A)),
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                  ),
                  child: MarkdownBody(data: strAnswer),
                ),
              ),
            )
          ],
        ),
    );
  }

  Future<void> getFromGallery() async {
    try {
      final result = await imagePicker.pickImage(source: ImageSource.gallery);
      if (result != null) {
        if (kIsWeb) {
          
          final bytes = await result.readAsBytes();
          setState(() {
            webImage = bytes; 
          });
        } else {
          setState(() {
            imageFile = File(result.path);
          });
        }
      }
    } catch (e) {
      log('Gagal mengambil gambar: $e');
    }
  }

  Future<void> getFromCamera() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    } else {
      _showSnackBar('Gagal mengambil gambar dari kamera.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
