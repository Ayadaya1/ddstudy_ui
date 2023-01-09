import 'package:dd_study_ui/ui/roots/app.dart';
import 'package:dd_study_ui/ui/roots/loader.dart';
import 'package:dd_study_ui/ui/widgets/add_post.dart';
import 'package:dd_study_ui/ui/widgets/profie.dart';
import 'package:dd_study_ui/ui/roots/registration.dart';
import 'package:dd_study_ui/ui/widgets/settings.dart';
import 'package:flutter/cupertino.dart';

import '../../domain/models/user.dart';
import '../widgets/comment_section.dart';
import '../widgets/user_list.dart';
import 'auth.dart';

class NavigationRoutes
{
  static const loaderWidget = "/";
  static const auth = "/auth";
  static const app = "/app";
  static const profile = "/mypage";
  static const registration = "/register";
  static const addPost = "/add_post";
  static const commentSection = "/comments";
  static const userList = "/users";
  static const settings = "/settings";
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

  static void toMyPage(String userId)
  {
    Map<String, dynamic> args = {'userId':userId};
    key.currentState?.pushNamed(NavigationRoutes.profile, arguments: args); 
  }

  static void toRegistration()
  {
    key.currentState?.pushNamed(NavigationRoutes.registration);
  }
  static void toAddPost()
  {
    key.currentState?.pushNamed(NavigationRoutes.addPost);
  }
  static Future toComments(String postId) async
  {
    Map<String, dynamic> args = {'postId':postId};
    key.currentState?.pushNamed(NavigationRoutes.commentSection, arguments: args);
  }
  static void toUserList(List<User>? users)
  {
    Map<String, dynamic> args = {'users':users};
    key.currentState?.pushNamed(NavigationRoutes.userList, arguments: args);
  }
  static void toSettings() async
  {
    key.currentState?.pushNamed(NavigationRoutes.settings);
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
      if(settings.arguments!=null)
      {
        var userId = settings.arguments ?? {}["userId"];
        return PageRouteBuilder(pageBuilder: (_,__,___) => Profile.create(userId["userId"]));
      }
      else 
      {return null;}
      case NavigationRoutes.registration:
        return PageRouteBuilder(pageBuilder: (_,__,___) => Registration.create());
      case NavigationRoutes.addPost:
        return PageRouteBuilder(pageBuilder: (_,__,___) => AddPost.create());
      case NavigationRoutes.commentSection:
      if(settings.arguments!=null)
      {
        var postId = settings.arguments ?? {}["postId"];
        return PageRouteBuilder(pageBuilder: (_,__,___) => Comments.create(postId["postId"]));
      }
      else
      {
        return null;
      }
      case NavigationRoutes.userList:
      if(settings.arguments!=null)
      {
        var users = settings.arguments ?? {}["users"];
        return PageRouteBuilder(pageBuilder: (_,__,___) => UserList.create(users["users"]));
      }
      else
      {
        return null;
      }
      case NavigationRoutes.settings:
        return PageRouteBuilder(pageBuilder: (_,__,___) => Settings.create());
}
    return null;
  }
}