import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'date_picker.dart';
import 'dart:html';
import 'package:intl/intl.dart';
import '../core/helper.dart';

import '../dropdown/toggle.dart';
import '../dropdown/dropdown.dart';
import '../dropdown/menu.dart';
import '../button/toggle.dart';

String defaultFormat = 'yMMMd';
String _defaultLocale = 'en_US';

/// Creates an [NgEsDatePickerPopup], this is a date-picker component that is popup when user clicks
/// on the input box or on the button at the right of the input box.
@Component(selector: "es-date-picker-popup", styleUrls: ['date_picker_popup.css'],

templateUrl: 'date_picker_popup.html', directives: [
  EsDropdownDirective,
  EsDropdownMenuDirective,
  EsDropdownToggleDirective,
  EsDatePickerComponent,
  EsToggleButtonDirective,
  coreDirectives,
  formDirectives
], pipes: [
  commonPipes
])
class EsDatePickerPopupComponent extends EsDatePickerBase {
  /// Constructs a DatePickerPopup
  EsDatePickerPopupComponent(this.ngModel, HtmlElement elementRef) : super(elementRef) {
    ngModel.valueAccessor = this;
  }

  /// provides access to entered value
  NgModel ngModel;

  /// if `true` shows the button bar at the bottom of the popup menu
  @Input()
  bool showButtonBar = true;

  /// provides the text that will be showed in the current-day button
  @Input()
  String currentText = 'Today';

  /// provides the text that will be showed in the clear button
  @Input()
  String clearText = 'Clear';

  /// provides the text that will be displayed in the close button
  @Input()
  String closeText = 'Close';

  /// if `true` the dropdown-menu will be open, and the date-picker visible
  bool isOpen;

  /// format pattern used to show the input value
  ///
  /// See [DateFormat] for more information.
  @Input()
  String format = defaultFormat;

  /// locale used to localize the output values
  @Input()
  String locale = _defaultLocale;

  valueChanged(value) {
    var df = DateFormat(format, locale);
    try {
      ngModel.viewToModelUpdate(df.parse(value));
    } catch (e) {
      print(e);
    }
  }
}