import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../painters/text_detector_painter.dart';
import 'detector_view.dart';


class DocumentRecognizerView extends StatefulWidget {
  const DocumentRecognizerView({super.key});

  @override
  State<DocumentRecognizerView> createState() => _DocumentRecognizerViewState();
}

class _DocumentRecognizerViewState extends State<DocumentRecognizerView> {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.back;

  List fieldsRules = [
    {
      "name": "CardNumber",
      "blocks": [
        {
          "isNumber": true,
          "length": 4,
        },
        {
          "isNumber": true,
          "length": 5,
        },
        {
          "isNumber": true,
          "length": 1,
        }
      ]
    }
  ];

  @override
  void dispose() async {
    _canProcess = false;
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        DetectorView(
          title: 'Text Detector',
          customPaint: _customPaint,
          text: _text,
          onImage: _processImage,
          initialCameraLensDirection: _cameraLensDirection,
          onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
        ),
      ]),
    );
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }


  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() => _text = '');
    final recognizedText = await _textRecognizer.processImage(inputImage);
    if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
      final painter = TextRecognizerPainter(
        recognizedText,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);
      final blocks = recognizedText.blocks;
      for (var block in blocks) {
        // print("----TEXT----${block.text}");
        // print("----Bounding box----${block.boundingBox}");

        for(var line in block.lines) {
          // print("=====Lines==(Bounding box)===${line.boundingBox}");
          // print("=====Lines==(text)===${line.text}");

          for(var element in line.elements) {
            // print("+++++++Element++(Bounding box)+++${element.boundingBox}");
            // print("+++++++Element++(text)+++${element.text}");

            for(Map rule in fieldsRules) {
              if(rule["blocks"].length == line.elements.length) {
                int successChecks = 0;
                for(Map ruleBlock in rule["blocks"]) {
                  if(
                    element.text.length == ruleBlock["length"] &&
                    ruleBlock["isNumber"] == isNumeric(element.text)
                  ) {

                  }
                }
              }
            }
          }
        }
      }
    } else {
      _text = 'Recognized text:\n\n${recognizedText.text}';
      // TODO: set _customPaint to draw boundingRect on top of image
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}