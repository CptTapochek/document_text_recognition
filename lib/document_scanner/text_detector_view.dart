import 'package:camera/camera.dart';
import 'package:document_text_recognition/document_scanner/utilities.dart';
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

  String cardNumber = "";
  List<String> medicareUsers = [];
  String validTo = "";

  Map<String, dynamic> medicareFields = {};

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

      if(cardNumber.isEmpty) {
        cardNumber = Utilities().findField(
          blocks: recognizedText.blocks,
          rules: [{Rules.isNumber: 4}, {Rules.isNumber: 5}, {Rules.isNumber: 1}]
        );
      }
      
      if(validTo.isEmpty) {
        validTo = Utilities().findField(
          blocks: recognizedText.blocks,
          rules: [{Rules.isUpperCaseText: 5}, {Rules.isUpperCaseText: 2}, {Rules.isText: 7}], contains: "VALID TO"
        ).replaceAll("VALID TO ", "");
      }

      if(medicareUsers.length < 5) {
        String user = Utilities().findField(
          blocks: recognizedText.blocks,
          rules: [{Rules.isNumber: 1}, {Rules.isUpperCaseText: 0}, {Rules.isUpperCaseText: 0}]
        );
        if(user.isNotEmpty && Utilities().isNumeric(user[0])) {
          if(medicareUsers.isNotEmpty && !medicareUsers.toString().contains(user[0])) {
            medicareUsers.add(user);
          } else if(medicareUsers.isEmpty) {
            medicareUsers.add(user);
          }
        }
      }

      medicareFields = {
        "CardNumber": cardNumber,
        "Users": medicareUsers,
        "ValidTo": validTo
      };

      print("---------_$medicareFields");

    } else {
      _text = 'Recognized text:\n\n${recognizedText.text}';
      print("----$_text");
      // TODO: set _customPaint to draw boundingRect on top of image
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}