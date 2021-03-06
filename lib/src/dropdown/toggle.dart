import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'dart:html';
import 'package:intl/intl.dart';
import 'dart:async';
import '../core/helper.dart';
import 'dropdown.dart';

/// Creates a component that will toggle the state of a dropdown-menu,
/// in other words when clicked will open or close the dropdown-menu
@Directive(selector: 'es-dropdown-toggle, .dropdown-toggle')
class EsDropdownToggleDirective {
  EsDropdownDirective dropdown;

  /// Reference to this HTML element
  HtmlElement elementRef;

  EsDropdownToggleDirective(this.elementRef);

  @HostBinding('attr.aria-haspopup')
  bool ariaHaspopup = true;

  /// if `true` this component is disabled
  @Input()
  @HostBinding('class.disabled')
  bool disabled = false;

  /// if `true` the attr.aria-expanded should be `true`
  @HostBinding('attr.aria-expanded')
  bool get isOpen => dropdown?.isOpen ?? false;

  /// toggles the state of the dropdown
  @HostListener('click', ['\$event'])
  void toggleDropdown(MouseEvent event) {
    event.preventDefault();
    event.stopPropagation();
    if (!disabled) {
      dropdown.toggle();
    }    
  }
}
