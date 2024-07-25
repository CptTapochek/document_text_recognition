import 'dart:math';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';


class Utilities {
  static int maximalElementLength = 30;


  void searchMedicareUser({required List<TextBlock> blocks, required List<Map<Rules, int>> targetRules}) {
    String field = "";
    for (var block in blocks) {
      for(var line in block.lines) {
        // print("=====Lines==(text)===${line.text}");
        // print("=====Lines==(text)===${line.boundingBox}");
        List<String> fieldElements = [];
        if(line.elements.length > targetRules.length) {
          for(Map<Rules, int> rule in targetRules) {
            final Rules ruleKey = rule.keys.first;
            for(int idx = 0; idx < targetRules.length; idx++) {
              String elementText = line.elements[idx].text;
              if(rule[ruleKey] != 0 && elementText.length == rule[ruleKey]) {
                inputField(type: ruleKey, fieldElements: fieldElements, elementText: elementText, callBack: (value) => fieldElements = value);
              } else if(rule[ruleKey] == 0 && elementText.length < maximalElementLength && elementText.isNotEmpty) {
                inputField(type: ruleKey, fieldElements: fieldElements, elementText: elementText, callBack: (value) => fieldElements = value);
              }
            }
          }
        }
        if(fieldElements.length == targetRules.length) {
          int successIteration = 0;
          for(int i = 0; i < targetRules.length; i++) {
            final Rules ruleKey = targetRules[i].keys.first;
            if(isValidRule(value: fieldElements[i], rule: ruleKey)) {
              successIteration++;
            }
          }
          if(successIteration == targetRules.length) {
            field = fieldElements.join(" ");
          }
        }

        if(line.text.contains(field)) {
          int successIteration = targetRules.length;
          for (int i = targetRules.length; i < line.elements.length; i++) {
            String element = line.elements[i].text;
            if(isUpperCase(element)) {
              successIteration++;
            }
          }
          if(successIteration == line.elements.length) {
            print('-------Text--------_${line.text}');
            print('-------Box--------_${line.boundingBox}');
          }
        }
      }
    }
    // return field;
  }


  String findField({required List<TextBlock> blocks, String? contains, required List<Map<Rules, int>> rules}) {
    String field = "";
    for (var block in blocks) {
      for(var line in block.lines) {
        // print("=====Lines==(text)===${line.text}");
        // print("=====Lines==(text)===${line.boundingBox}");
        List<String> fieldElements = [];
        if(rules.length == line.elements.length) {
          for(var element in line.elements) {
            String elementText = element.text;
            // print("+++++++Element++(text)+++${elementText}");
            
            for(Map<Rules, int> rule in rules) {
              final Rules ruleKey = rule.keys.first;
              if(rule[ruleKey] != 0 && elementText.length == rule[ruleKey]) {
                inputField(type: ruleKey, fieldElements: fieldElements, elementText: elementText, callBack: (value) => fieldElements = value);
              } else if(rule[ruleKey] == 0 && elementText.length < maximalElementLength && elementText.isNotEmpty) {
                inputField(type: ruleKey, fieldElements: fieldElements, elementText: elementText, callBack: (value) => fieldElements = value);
              } else if((ruleKey == Rules.isNumberO || ruleKey == Rules.isTextO || ruleKey == Rules.isUpperCaseTextO) && elementText.isEmpty) {
                fieldElements.add(" ");
              }
            }
          }

          if(fieldElements.length == rules.length) {
            for(Map rule in rules) {
              final int ruleValue = rule.values.first;
              if(ruleValue != 0) {
                for(String fieldElement in fieldElements) {
                  if(fieldElement.length == ruleValue) {
                    field = fieldElements.join(" ");
                  }
                }
              } else {
                field = fieldElements.join(" ");
              }
            }
          }
        }
      }
    }
    return field;
  }

  void inputField({required Rules type, required List<String> fieldElements, required String elementText, required Function callBack}) {
    List<String> currentFieldElements = fieldElements;
    void input() {
      if(currentFieldElements.isNotEmpty && currentFieldElements.last != elementText && elementText.isNotEmpty) {
        currentFieldElements.add(elementText);
      } else if(currentFieldElements.isEmpty) {
        currentFieldElements.add(elementText);
      }
    }
    switch(type) {
      case Rules.isNumber:
        if(isNumeric(elementText)) input();
        break;
      case Rules.isNumberO:
        // TODO: Handle this case.
      case Rules.isText:
        input();
        break;
      case Rules.isTextO:
        input();
        break;
      case Rules.isUpperCaseText:
        if(isUpperCase(elementText)) input();
        break;
      case Rules.isLowerCaseText:
        // TODO: Handle this case.
      case Rules.isUpperCaseTextO:
        if(isUpperCase(elementText) && elementText.length > 2) input();
        break;
      case Rules.date:
        if(isValidDateTime(elementText)) input();
        break;
    }
    callBack(currentFieldElements);
  }

  bool isNumeric(String s) {
    List<String> stringList = [];
    s.split("").forEach((char) {
      String finalChar = "";
      switch(char) {
        case "b":
          finalChar = mixingCharacters(wrongCharacter: "b", exceptedCharacter: "6");
          break;
        case "I":
          finalChar = mixingCharacters(wrongCharacter: "I", exceptedCharacter: "1");
          break;
        default:
          finalChar = char;
          break;
      }
      stringList.add(finalChar);
    });

    return double.tryParse(s) != null;
  }

  bool isUpperCase(String str) {
    final upperCaseRegExp = RegExp(r'^[A-Z]+$');
    return upperCaseRegExp.hasMatch(str);
  }

  bool isValidDateTime(String input) {
    try {
      DateTime.parse(input);
      return true;
    } catch (e) {
      return false;
    }
  }

  bool isValidRule({required String value, required Rules rule}) {
    switch(rule) {
      case Rules.isNumber: return isNumeric(value);
      case Rules.isNumberO: return isNumeric(value);
      case Rules.isText: return true;
      case Rules.isTextO: return true;
      case Rules.isUpperCaseText: return isUpperCase(value);
      case Rules.isUpperCaseTextO: return isUpperCase(value);
      case Rules.isLowerCaseText: return true;
      case Rules.date: return isValidDateTime(value);
    }
  }

  String mixingCharacters({required String wrongCharacter, required String exceptedCharacter}) {
    final Random random = Random();
    int randomNumber = random.nextInt(2);
    String character = exceptedCharacter;
    if(randomNumber == 1) {
      character = wrongCharacter;
    }
    return character;
  }
}

enum Rules {
  isNumber,
  isNumberO,
  isText,
  isTextO,
  isUpperCaseText,
  isUpperCaseTextO,
  isLowerCaseText,
  date
}