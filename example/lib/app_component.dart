import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';

import 'package:essential_components/essential_components.dart';
import 'package:example/src/pages/content_page/content_component.dart';
import 'package:example/src/pages/menu_aside_component/menu_aside_component.dart';
import 'package:example/src/pages/menu_sidebar_options_component/menu_sidebar_options_component.dart';
import 'package:example/src/pages/notification_component/notification_component.dart';

@Component(
    selector: 'my-app',
    styleUrls: ['app_component.css'],
    templateUrl: 'app_component.html',
    directives: [
      formDirectives,
      coreDirectives,
      routerDirectives,
      MenuAsideComponent,
      MenuSidebarOptionsComponent,
      ContentComponent,
      TextValidator,
      EssentialNotificationService,
      EssentialNotificationComponent
    ],
    exports: [])
class AppComponent {

  static EssentialNotificationService notificationService = EssentialNotificationService();

  AppComponent();

}
