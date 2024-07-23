import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';


class Utilities {
  static int maximalElementLength = 30;

  String findField({required List<TextBlock> blocks, String? contains, required List<Map<Rules, int>> rules}) {
    String field = "";
    for (var block in blocks) {
      for(var line in block.lines) {
        // print("=====Lines==(text)===${line.text}");
        List<String> fieldElements = [];
        if(rules.length == line.elements.length) {
          for(var element in line.elements) {
            String elementText = element.text;
            // print("+++++++Element++(text)+++${elementText}");
            for(Map<Rules, int> rule in rules) {
              if(rule[Rules.isNumber] != null) {
                if(rule[Rules.isNumber] != 0 && elementText.length == rule[Rules.isNumber]) {
                  if(isNumeric(elementText)) {
                    if(fieldElements.isNotEmpty && fieldElements.last != elementText) {
                      fieldElements.add(elementText);
                    } else if(fieldElements.isEmpty) {
                      fieldElements.add(elementText);
                    }
                  }
                } else if(rule[Rules.isNumber] == 0 && elementText.length < maximalElementLength) {
                  if(isNumeric(elementText)) {
                    if(fieldElements.isNotEmpty && fieldElements.last != elementText) {
                      fieldElements.add(elementText);
                    } else if(fieldElements.isEmpty) {
                      fieldElements.add(elementText);
                    }
                  }
                }
              }

              if(rule[Rules.isText] != null) {
                if(rule[Rules.isText] != 0 && elementText.length == rule[Rules.isText]) {
                  if(fieldElements.isNotEmpty && fieldElements.last != elementText) {
                    fieldElements.add(elementText);
                  } else if(fieldElements.isEmpty) {
                    fieldElements.add(elementText);
                  }
                } else if(rule[Rules.isText] == 0 && elementText.length < maximalElementLength) {
                  if(fieldElements.isNotEmpty && fieldElements.last != elementText) {
                    fieldElements.add(elementText);
                  } else if(fieldElements.isEmpty) {
                    fieldElements.add(elementText);
                  }
                }
              }

              if(rule[Rules.isUpperCaseText] != null) {
                if(rule[Rules.isUpperCaseText] != 0 && elementText.length == rule[Rules.isUpperCaseText]) {
                  if(isUpperCase(elementText)) {
                    if(fieldElements.isNotEmpty && fieldElements.last != elementText) {
                      fieldElements.add(elementText);
                    } else if(fieldElements.isEmpty) {
                      fieldElements.add(elementText);
                    }
                  }
                } else if(rule[Rules.isUpperCaseText] == 0 && elementText.length < maximalElementLength) {
                  if(isUpperCase(elementText)) {
                    if(fieldElements.isNotEmpty && fieldElements.last != elementText) {
                      fieldElements.add(elementText);
                    } else if(fieldElements.isEmpty) {
                      fieldElements.add(elementText);
                    }
                  }
                }
              }
            }
          }
          if(fieldElements.length == rules.length) {
            field = fieldElements.join(" ");
          }
        }
      }
    }
    return field;
  }

  bool isNumeric(String s) {
    return double.tryParse(s) != null;
  }

  bool isUpperCase(String str) {
    final upperCaseRegExp = RegExp(r'^[A-Z]+$');
    return upperCaseRegExp.hasMatch(str);
  }
}

enum Rules {
  isNumber,
  isText,
  isUpperCaseText,
  isLowerCaseText,
}