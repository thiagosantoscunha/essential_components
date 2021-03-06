import 'dart:async';
import 'dart:html';

import 'package:intl/intl.dart';
import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';

import 'datatable_render_interface.dart';
import 'package:essential_rest/essential_rest.dart';
import 'data_table_filter.dart';

//utils
import 'data_table_utils.dart';

@Component(
  selector: 'es-data-table',
  templateUrl: 'data_table.html',
  styleUrls: [
    'data_table.css',
  ],
  directives: [
    formDirectives,
    coreDirectives,
  ],
)
//A Material Design Data table component for AngularDart
class EssentialDataTableComponent {
  @ViewChild("tableElement") //HtmlElement
  TableElement tableElement;

  @ViewChild("itemsPerPageElement")
  SelectElement itemsPerPageElement;

  @ViewChild("inputSearchElement")
  InputElement inputSearchElement;

  @Input()
  bool enableOrdering = true;

  @Input()
  bool showFilter = true;

  @Input()
  bool showItemsLimit = true;

  bool _showCheckBoxToSelectRow = true;

  @Input()
  set showCheckboxSelect(bool showCBSelect) {
    _showCheckBoxToSelectRow = showCBSelect;
  }

  bool get showCheckboxSelect {
    return _showCheckBoxToSelectRow;
  }

  RList<IDataTableRender> _data;
  RList<IDataTableRender> selectedItems = RList<IDataTableRender>();
  DataTableFilter dataTableFilter = DataTableFilter();

  @Input()
  set data(RList<IDataTableRender> data) {
    _data = data;
  }

  RList<IDataTableRender> get data {
    return _data;
  }

  int get totalRecords {
    if (_data != null) {
      return _data.totalRecords;
    }
    return 0;
  }

  List<String> get theads {
    if (_data != null && _data.isNotEmpty) {
      DataTableRow columnsTitles = _data[0].getRowDefinition();
      List<String> listtheads = List<String>();
      for (DataTableColumn col in columnsTitles.getSets()) {
        listtheads.add(col.title);
      }
      return listtheads;
    }
    return null;
  }

  int _currentPage = 1;
  int _btnQuantity = 5;

  final _rowClickRequest = StreamController<IDataTableRender>();

  @Output()
  Stream<IDataTableRender> get rowClick => _rowClickRequest.stream;

  onRowClick(IDataTableRender item) {
    _rowClickRequest.add(item);
  }

  final _searchRequest = StreamController<DataTableFilter>();

  @Output()
  Stream<DataTableFilter> get searchRequest => _searchRequest.stream;

  onSearch() {
    dataTableFilter.searchString = inputSearchElement.value;
    _searchRequest.add(dataTableFilter);
    onRequestData();
  }

  final _limitChangeRequest = StreamController<DataTableFilter>();

  @Output()
  Stream<DataTableFilter> get limitChange => _limitChangeRequest.stream;

  onLimitChange() {
    this._currentPage = 1;
    dataTableFilter.limit = int.tryParse(itemsPerPageElement.value);
    _limitChangeRequest.add(dataTableFilter);
    onRequestData();
  }

  final _dataRequest = StreamController<DataTableFilter>();

  @Output()
  Stream<DataTableFilter> get dataRequest => _dataRequest.stream;

  onRequestData() {
    var currentPage = this._currentPage == 1 ? 0 : this._currentPage - 1;
    dataTableFilter.offset = currentPage * dataTableFilter.limit;
    _dataRequest.add(dataTableFilter);
  }

  reload() {
    dataTableFilter.clear();
    onRequestData();
  }
}
