import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:polyp_detector/utils/size_configs.dart';
import 'package:tflite/tflite.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late File _image;
  late List result;
  bool imageSelect = false;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future loadModel() async {
    Tflite.close();
    String? res;

    res = await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
      numThreads: 1,
    );
    print("model loaded : $res");
  }

  Future imageClassification(File image) async {
    var classification = await Tflite.runModelOnImage(
      path: image.path,
      imageMean: 127.5,
      imageStd: 127.5,
      numResults: 1,
      threshold: 0.1,
      asynch: true,
    );
    setState(() {
      result = classification!;
      _image = image;

      imageSelect = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('ACPI testing'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: getProportionateScreenHeight(200),
          ),
          Center(
            child: imageSelect == false
                ? Container(
                    height: getProportionateScreenHeight(170),
                    width: getProportionateScreenWidth(170),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 128, 157, 172),
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Color.fromARGB(255, 128, 157, 172),
                    ),
                  )
                : Container(
                    height: getProportionateScreenHeight(190),
                    width: getProportionateScreenWidth(190),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        style: BorderStyle.solid,
                        width: 2,
                      ),
                    ),
                    child: Image.file(_image),
                  ),
          ),
          SizedBox(
            height: getProportionateScreenHeight(10),
          ),
          Column(
            children: imageSelect
                ? result.map((e) {
                    return Text(
                        '${e['label']} - ${e['confidence'].toStringAsFixed(2)}');
                  }).toList()
                : [],
          ),
          SizedBox(
            height: getProportionateScreenHeight(20),
          ),
          ElevatedButton(
            onPressed: pickImage,
            child: const Text('Choose an image'),
          ),
          SizedBox(
            height: getProportionateScreenHeight(20),
          ),
          ElevatedButton(
            onPressed: pickImage,
            child: const Text('Click an image'),
          ),
        ],
      ),
    );
  }

  Future pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    File image = File(pickedFile!.path);
    imageClassification(image);
  }
}
