import 'dart:html';
import 'package:angular/angular.dart';

//  <!-- <input [moneyMask]="{'mask': 'mask'}"  [maxlength]="11"  type="text" > -->
@Directive(selector: '[moneyMask]')
class MoneyMaskDirective {
  InputElement inputElement;
  String decimalSeparator;
  String thousandSeparator;
  String rightSymbol;
  String leftSymbol;
  int precision;
  double _lastValue = 0.0;
  double initialValue = 0.0;

  MoneyMaskDirective(Element element) {
    inputElement = element as InputElement;
    decimalSeparator = ',';
    thousandSeparator = '.';
    rightSymbol = '';
    leftSymbol = 'R\$ ';
    precision = 2;

    inputElement.onInput.listen((e) {
      updateValue(numberValue);
    });
    
    updateValue(initialValue);
  }
  
  void updateValue(double value) {
    var valueToUse = value;

    if (value.toStringAsFixed(0).length > 12) {
      valueToUse = _lastValue;
    } else {
      _lastValue = value;
    }

    var masked = _applyMask(valueToUse);

    if (rightSymbol.isNotEmpty) {
      masked += rightSymbol;
    }

    if (leftSymbol.isNotEmpty) {
      masked = leftSymbol + masked;
    }

    if (masked != inputElement.value) {
      inputElement.value = masked;
      //var cursorPosition = this.inputElement.value.length - this.rightSymbol.length;
      inputElement.setSelectionRange(inputElement.value.length, inputElement.value.length);
    }
  }

  double get numberValue {
    var onlyNumbers = _getOnlyNumbers(inputElement.value);
    var parts = onlyNumbers.split('').toList(growable: true);
    if (parts.length >= precision) {
      parts.insert(parts.length - precision, '.');
    } else {
      return double.parse('0.0$onlyNumbers');
    }
    return double.parse(parts.join());
  }

  _validateConfig() {
    var rightSymbolHasNumbers = _getOnlyNumbers(rightSymbol).isNotEmpty;

    if (rightSymbolHasNumbers) {
      throw ArgumentError('rightSymbol must not have numbers.');
    }
  }

  String _getOnlyNumbers(String text) {
    var cleanedText = text;

    var onlyNumbersRegex = RegExp(r'[^\d]');

    cleanedText = cleanedText.replaceAll(onlyNumbersRegex, '');

    return cleanedText;
  }

  String _applyMask(double value) {
    var textRepresentation = value
        .toStringAsFixed(precision)
        .replaceAll('.', '')
        .split('')
        .reversed
        .toList(growable: true);

    textRepresentation.insert(precision, decimalSeparator);

    for (var i = precision + 4; true; i = i + 4) {
      if (textRepresentation.length > i) {
        textRepresentation.insert(i, thousandSeparator);
      } else {
        break;
      }
    }

    return textRepresentation.reversed.join('');
  }

  bool isNumeric(int val) {
    return ((val >= 48 && val <= 57) || (val == 8) || (val == 46));
  }

  String charAt(String value, int index) {
    //return inputValue.substring(0, 1);
    if (value == null) {
      throw ArgumentError('o parametro value não pode ser nulo');
    }
    if ((index < 0) || (index >= value.length)) {
      throw StringIndexOutOfBoundsException();
    }
    return value[index];
  }
}

class StringIndexOutOfBoundsException implements Exception {
  String cause;
  StringIndexOutOfBoundsException({this.cause = 'String Index Out Of Bounds Exception'});
}
