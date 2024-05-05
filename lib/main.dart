import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter File Upload Server',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
  PickedFile? selectedFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Flutter File Upload Server"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (selectedFile != null && ["jpg", "png"].contains(selectedFile!.extension)) ...[
                Image.file(
                  selectedFile!.file,
                  height: 200,
                  width: double.infinity,
                ),
                const SizedBox(height: 20),
                Image.memory(
                  selectedFile!.unit8ListFile!,
                  height: 200,
                  width: double.infinity,
                ),
              ],
              if (selectedFile != null) ...[
                const SizedBox(height: 20),
                Text(
                  "File name: ${selectedFile!.name}\n\nFile extension: ${selectedFile!.extension}",
                  textAlign: TextAlign.start,
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final chooseFile = await pickFile();
          if (chooseFile != null) {
            _uploadFileToServer(chooseFile);
            setState(() {
              selectedFile = chooseFile;
            });
          }
        },
        tooltip: 'Choose File',
        child: const Icon(Icons.file_copy_outlined),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _uploadFileToServer(PickedFile pickedFile) async {
    print("_uploadFileToServer====================[Start]========================");
    print("PickedFile :: [${pickedFile.file.path}]");
    print("PickedFile :: [${pickedFile.name}]");
    print("PickedFile :: [${pickedFile.extension}]");
    print("PickedFile :: [${pickedFile.unit8ListFile}]");
    print("_uploadFileToServer====================[End]==========================");

    ///Make data
    Map<String, MultipartFile> multipartFile = <String, MultipartFile>{};
    final file = MultipartFile.fromBytes(pickedFile.unit8ListFile!, filename: pickedFile.name);
    multipartFile.addEntries([MapEntry("file", file)]);
    FormData formData = FormData.fromMap({
      "title": pickedFile.name,
      "extension": pickedFile.extension,
      ...multipartFile,
    });

    ///Network Call
    Dio dio = Dio();
    final response = await dio.post("https://smshahi.xyz/mobile/api/v1/upload-file", data: formData);
    print("_uploadFileToServer====================[Start]========================");
    print("Response :: [${response.statusCode}]");
    print("_uploadFileToServer====================[End]==========================");
  }
}

class PickedFile {
  final File file;
  final String name;
  final String? extension;
  final Uint8List? unit8ListFile;

  PickedFile(this.file, this.name, {this.extension, this.unit8ListFile});

  Future<double> sizeInMbs() async {
    int sizeInBytes = await file.length();
    double sizeInMb = sizeInBytes / (1024 * 1024);
    return sizeInMb;
  }
}

Future<PickedFile?> pickFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom, //FileType.any
    allowCompression: false,
    allowMultiple: false,
    allowedExtensions: ['pdf', 'doc', 'jpg', 'png'], //null
  );

  if (result != null) {
    PlatformFile file = result.files.first;
    final byteFile = await file.xFile.readAsBytes();
    return PickedFile(File(file.path!), file.name, extension: file.extension, unit8ListFile: byteFile);
  }

  return null;
}
