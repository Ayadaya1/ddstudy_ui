import 'package:dd_study_ui/ui/roots/app.dart';
import 'package:dd_study_ui/ui/roots/loader.dart';
import 'package:dd_study_ui/ui/widgets/add_post.dart';
import 'package:dd_study_ui/ui/widgets/profie.dart';
import 'package:dd_study_ui/ui/roots/registration.dart';
import 'package:flutter/cupertino.dart';

import '../../domain/models/user.dart';
import 'auth.dart';
import 'home.dart';
import 'app.dart';
import '../widgets/profie.dart';

class NavigationRoutes
{
  static const loaderWidget = "/";
  static const auth = "/auth";
  static const app = "/app";
  static const profile = "/mypage";
  static const registration = "/register";
  static const addPost = "/add_post";
}

class AppNavigator
{
  static final key = GlobalKey<NavigatorState>();

  static Future toLoader() async
  {
    return key.currentState?.pushNamedAndRemoveUntil(NavigationRoutes.loaderWidget, ((route) => false));
  }
  static void toAuth()
  {
    key.currentState?.pushNamedAndRemoveUntil(NavigationRoutes.auth, ((route) => false));
  }
  static void toHome()
  {
    key.currentState?.pushNamedAndRemoveUntil(NavigationRoutes.app, ((route) => false));
  }

  static void toMyPage({String? token, User? user})
  {
    key.currentState?.pushNamed(NavigationRoutes.profile, arguments: {"Token":token, "User":user}); //Не работает так, как хотелось бы, но буду стараться довести до ума.
  }

  static void toRegistration()
  {
    key.currentState?.pushNamed(NavigationRoutes.registration);
  }
  static void toAddPost()
  {
    key.currentState?.pushNamed(NavigationRoutes.addPost);
  }

  static Route<dynamic>? onGeneratedRoute(RouteSettings settings, BuildContext context)
  {
    switch(settings.name)
    {
      case NavigationRoutes.loaderWidget:
        return PageRouteBuilder(pageBuilder: (_,__,___) =>  LoaderWidget.create());
      case NavigationRoutes.auth:
        return PageRouteBuilder(pageBuilder: (_,__,___) => Auth.create());
      case NavigationRoutes.app:
        return PageRouteBuilder(pageBuilder: (_,__,___) => AppMain.create());
      case NavigationRoutes.profile:
        return PageRouteBuilder(pageBuilder: (_,__,___) => Profile.create());
      case NavigationRoutes.registration:
        return PageRouteBuilder(pageBuilder: (_,__,___) => Registration.create());
      case NavigationRoutes.addPost:
        return PageRouteBuilder(pageBuilder: (_,__,___) => AddPost.create());
    }
    return null;
  }
}