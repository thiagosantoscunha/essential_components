import 'dart:async';
import 'dart:html';

import 'package:intl/intl.dart';
import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';

import 'datatable_render_interface.dart';
import 'response_list.dart';
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
class EssentialDataTableComponent implements OnInit, AfterChanges, AfterViewInit {
  @ViewChild("tableElement") //HtmlElement
  TableElement tableElement;

  DataTableFilter dataTableFilter = DataTableFilter();

  @ViewChild("inputSearchElement")
  InputElement inputSearchElement;

  @ViewChild("itemsPerPageElement")
  SelectElement itemsPerPageElement;

  @ViewChild("paginateContainer")
  HtmlElement paginateContainer;

  @ViewChild("paginateDiv")
  HtmlElement paginateDiv;

  @ViewChild("paginatePrevBtn")
  HtmlElement paginatePrevBtn;

  @ViewChild("paginateNextBtn")
  HtmlElement paginateNextBtn;

  String _orderDir = 'asc';
  bool _isTitlesRendered = false;

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
    draw();
  }

  bool get showCheckboxSelect {
    return _showCheckBoxToSelectRow;
  }

  RList<IDataTableRender> _data;
  RList<IDataTableRender> selectedItems = RList<IDataTableRender>();

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

  int _currentPage = 1;
  int _btnQuantity = 5;
  PaginationType paginationType = PaginationType.carousel;
  //StreamSubscription _prevBtnStreamSub;
  //StreamSubscription _nextBtnStreamSub;

  /*final NodeValidatorBuilder _htmlValidator = new NodeValidatorBuilder.common()
    ..allowHtml5()
    ..allowImages()
    ..allowInlineStyles()
    ..allowTextElements()
    ..allowSvg()
    ..allowElement('a', attributes: ['href'])
    ..allowElement('img', attributes: ['src']);*/

  @override
  void ngOnInit() {}

  /*@override
  void ngOnChanges(Map<String, SimpleChange> changes) {
    draw();
  }*/

  ngAfterViewInit() {
    inputSearchElement.onKeyPress.listen((KeyboardEvent e) {
       //e.preventDefault();
      e.stopPropagation();
      if (e.keyCode == KeyCode.ENTER) {
        onSearch();
      }
     
    });
    /*_prevBtnStreamSub = paginatePrevBtn.onClick.listen(prevPage);
    _nextBtnStreamSub = paginateNextBtn.onClick.listen(nextPage);*/
    paginatePrevBtn.onClick.listen(prevPage);
    paginateNextBtn.onClick.listen(nextPage);
  }

  @override
  void ngAfterChanges() {
    draw();
    drawPagination();
  }

  void draw() {
    try {
      //clear tbody if not get data
      if (_data == null || _data.isEmpty) {
        var tbody = tableElement.querySelector('tbody');
        if (tbody != null) {
          tbody.innerHtml = "<tr><td>Dados indisponiveis</td></tr>";
        } else {
          TableSectionElement tBody = tableElement.createTBody();
          tBody.innerHtml = "<tr><td>Dados indisponiveis</td></tr>";
        }
      }

      if (_data != null) {
        if (_data.isNotEmpty) {
          TableSectionElement tBody;
          if (tableElement.querySelector('tbody') == null) {
            tableElement.innerHtml = "";
            tBody = tableElement.createTBody();
          } else {
            tableElement.querySelector('tbody').innerHtml = "";
            tBody = tableElement.querySelector('tbody');
          }

          if (!_isTitlesRendered) {
            _isTitlesRendered = true;
            // Element tableHead =//
            tableElement.createTHead();
            TableRowElement tableHeaderRow = tableElement.tHead.insertRow(-1);
            //show checkbox on tableHead to select all rows
            if (_showCheckBoxToSelectRow) {
              var th = Element.tag('th');
              th.attributes['class'] = "datatable-first-col";
              var label = Element.tag('label');
              label.classes.add("pure-material-checkbox");
              var input = CheckboxInputElement();
              //input.type = "checkbox";
              input.onClick.listen(onSelectAll);
              var span = Element.tag('span');
              label.append(input);
              label.append(span);
              th.append(label);
              tableHeaderRow.insertAdjacentElement('beforeend', th);
            }

            //render colunas de titulo
            DataTableRow columnsTitles = _data[0].getRowDefinition();
            for (DataTableColumn col in columnsTitles.getSets()) {
              var th = Element.tag('th');
              th.attributes['class'] = 'dataTableSorting';
              th.text = col.title;
              //ordenação
              th.onClick.listen((e) {
                if (this.enableOrdering == true) {
                  tableElement.querySelectorAll('th:not(.datatable-first-col)').forEach((el) {
                    el.attributes['class'] = 'dataTableSorting';
                  });

                  if (_orderDir == 'asc') {
                    _orderDir = 'desc';
                    th.attributes['class'] = 'dataTableSorting dataTableSortingDesc';
                  } else if (_orderDir == 'desc') {
                    _orderDir = 'asc';
                    th.attributes['class'] = 'dataTableSorting dataTableSortingAsc';
                  }

                  dataTableFilter.orderBy = col.key;
                  dataTableFilter.orderDir = _orderDir;
                  onRequestData();
                }
              });

              tableHeaderRow.insertAdjacentElement('beforeend', th);
            }
          }

          //render linhas

          for (final item in _data) {
            TableRowElement tableRow = tBody.insertRow(-1);
            //show checkbox to select single row
            if (_showCheckBoxToSelectRow) {
              var tdcb = Element.tag('td');
              tdcb.attributes['class'] = "datatable-first-col";
              var label = Element.tag('label');
              label.onClick.listen((e) {
                e.stopPropagation();
              });
              label.classes.add("pure-material-checkbox");
              var input = CheckboxInputElement();
              //input.type = "checkbox";
              input.attributes['cbSelect'] = "true";
              input.onClick.listen((MouseEvent event) {
                onSelect(event, item);
              });
              var span = Element.tag('span');
              span.onClick.listen((e) {
                e.stopPropagation();
              });
              label.append(input);
              label.append(span);
              tdcb.append(label);
              tableRow.insertAdjacentElement('beforeend', tdcb);
            }

            tableRow.onClick.listen((event) {
              /*if (_showCheckBoxToSelectRow) {
              HtmlElement el = event.target;
              TableCellElement tc = el.closest("td");
              if (tc != null && tc.cellIndex > 0) {
                onRowClick(item);
              }
            } else {
              onRowClick(item);
            }*/
              onRowClick(item);
            });

            //draw columns
            DataTableRow settings = item.getRowDefinition();
            for (DataTableColumn colSet in settings.getSets()) {
              var tdContent = "";

              switch (colSet.type) {
                case DataTableColumnType.date:
                  if (colSet.value != null) {
                    var fmt = colSet.format == null ? 'dd/MM/yyyy' : colSet.format;
                    var formatter = DateFormat(fmt);
                    var date = DateTime.tryParse(colSet.value.toString());
                    if (date != null) {
                      tdContent = formatter.format(date);
                    }
                  }
                  break;
                case DataTableColumnType.dateTime:
                  if (colSet.value != null) {
                    var fmt = colSet.format == null ? 'dd/MM/yyyy HH:mm:ss' : colSet.format;
                    var formatter = DateFormat(fmt);
                    var date = DateTime.tryParse(colSet.value.toString());
                    if (date != null) {
                      tdContent = formatter.format(date);
                    }
                  }
                  break;
                case DataTableColumnType.text:
                  var str = colSet.value.toString();
                  if (colSet.limit != null) {
                    str = DataTableUtils.truncate(str, colSet.limit);
                  }
                  tdContent = str;
                  break;
                case DataTableColumnType.img:
                  var src = colSet.value.toString();
                  if (src != "null") {
                    var img = ImageElement();
                    img.src = src;
                    img.height = 40;
                    tdContent = img.outerHtml;
                  } else {
                    tdContent = "-";
                  }
                  break;
                default:
                  var str = colSet.value.toString();
                  if (colSet.limit != null) {
                    str = DataTableUtils.truncate(str, colSet.limit);
                  }
                  tdContent = str;
              }

              tdContent = tdContent == "null" ? "-" : tdContent;

              var td = Element.tag('td');
              td.setInnerHtml(tdContent, treeSanitizer: NodeTreeSanitizer.trusted);

              tableRow.insertAdjacentElement('beforeend', td);
            }
          }
        }
      }
    } catch (exception, stackTrace) {
      print("draw() exception: " + exception.toString());
      print(stackTrace.toString());
    }
    isLoading = false;
  }

  int numPages() {
    var totalPages = (this.totalRecords / this.dataTableFilter.limit).ceil();
    return totalPages;
  }

  void drawPagination() {
    var self = this;
    //quantidade total de paginas
    var totalPages = numPages();

    //quantidade de botões de paginação exibidos
    var btnQuantity = self._btnQuantity > totalPages ? totalPages : self._btnQuantity;
    var currentPage = self._currentPage; //pagina atual
    //clear paginateContainer for new draws
    self.paginateContainer.innerHtml = "";
    if (self.totalRecords < self.dataTableFilter.limit) {
      return;
    }

    if (btnQuantity == 1) {
      return;
    }

    if (currentPage == 1) {
      paginatePrevBtn.classes.remove('disabled');
      paginatePrevBtn.classes.add('disabled');
    }

    if (currentPage == totalPages) {
      paginateNextBtn.classes.remove('disabled');
      paginateNextBtn.classes.add('disabled');
    }

    var idx = 0;
    var loopEnd = 0;
    switch (paginationType) {
      case PaginationType.carousel:
        idx = (currentPage - (btnQuantity / 2)).toInt();
        if (idx <= 0) {
          idx = 1;
        }
        loopEnd = idx + btnQuantity;
        if (loopEnd > totalPages) {
          loopEnd = totalPages + 1;
          idx = loopEnd - btnQuantity;
        }
        while (idx < loopEnd) {
          var link = Element.tag('a');
          link.classes.add("paginate_button");
          if (idx == currentPage) {
            link.classes.add("current");
          }
          link.text = idx.toString();
          var liten = (event) {
            var pageBtnValue = int.tryParse(link.text);
            if (self._currentPage != pageBtnValue) {
              self._currentPage = pageBtnValue;
              self.changePage(self._currentPage);
            }
          };
          link.onClick.listen(liten);
          self.paginateContainer.append(link);
          idx++;
        }
        break;
      case PaginationType.cube:
        var facePosition = (currentPage % btnQuantity) == 0 ? btnQuantity : currentPage % btnQuantity;
        loopEnd = btnQuantity - facePosition + currentPage;
        idx = currentPage - facePosition;
        while (idx < loopEnd) {
          idx++;
          if (idx <= totalPages) {
            var link = Element.tag('a');
            link.classes.add("paginate_button");
            if (idx == currentPage) {
              link.classes.add("current");
            }
            link.text = idx.toString();
            var liten = (event) {
              var pageBtnValue = int.tryParse(link.text);
              if (self._currentPage != pageBtnValue) {
                self._currentPage = pageBtnValue;
                self.changePage(self._currentPage);
              }
            };
            link.onClick.listen(liten);
            self.paginateContainer.append(link);
          }
        }
        break;
    }
  }

  prevPage(Event event) {
    if (this._currentPage == 0) {
      return;
    }
    if (this._currentPage > 1) {
      this._currentPage--;
      changePage(this._currentPage);
    }
  }

  nextPage(Event event) {
    if (this._currentPage == numPages()) {
      return;
    }
    if (this._currentPage < this.numPages()) {
      this._currentPage++;
      changePage(this._currentPage);
    }
  }

  changePage(page) {
    onRequestData();
    if (page != this._currentPage) {
      this._currentPage = page;
    }
    selectedItems.clear();
  }

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

  bool isLoading = true;

  onRequestData() {
    isLoading = true;
    var currentPage = this._currentPage == 1 ? 0 : this._currentPage - 1;
    dataTableFilter.offset = currentPage * dataTableFilter.limit;
    _dataRequest.add(dataTableFilter);
  }

  reload() {
    dataTableFilter.clear();
    onRequestData();
  }

  onSelectAll(event) {
    var cbs = tableElement.querySelectorAll('input[cbselect=true]');
    if (event.target.checked) {
      for (CheckboxInputElement item in cbs) {
        item.checked = true;
      }
      selectedItems.clear();
      selectedItems.addAll(_data);
    } else {
      selectedItems.clear();
      for (CheckboxInputElement item in cbs) {
        item.checked = false;
      }
    }
  }

  onSelect(MouseEvent event, IDataTableRender item) {
    event.stopPropagation();
    CheckboxInputElement cb = event.target;
    if (cb.checked) {
      if (selectedItems.contains(item) == false) {
        selectedItems.add(item);
      }
    } else {
      if (selectedItems.contains(item)) {
        selectedItems.remove(item);
      }
    }
  }
}

enum PaginationType { carousel, cube }
