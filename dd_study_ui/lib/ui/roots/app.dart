import 'package:dd_study_ui/data/services/auth_service.dart';
import 'package:dd_study_ui/internal/config/shared_prefs.dart';
import 'package:dd_study_ui/internal/config/token_secure_storage.dart';
import 'package:dd_study_ui/ui/roots/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/user.dart';

class _ViewModel  extends ChangeNotifier {
  BuildContext context;
  final _authService = AuthService();

  _ViewModel({required this.context})
  {
    asyncInit();
  }


  User? _user;

  User? get user => _user;
  set user(User? val)
  {
    _user = val;
    notifyListeners();
  }

  Map<String, String>? headers;

  void asyncInit() async
  {
    var token = await TokenStorage.getAccessToken();
    headers = {"Authorization": "Bearer $token"};
    user = await SharedPrefs.getStoredUser();
  }
  
  void _logout () async
  {
    await _authService.logout().then((value) => AppNavigator.toLoader());
  }

  void _refresh() async
  {
      await _authService.tryGetUser();
  }
  void _myPage() async
  {
    AppNavigator.toMyPage();
  }
}

class AppMain extends StatelessWidget {
  const AppMain({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<_ViewModel>();
    return Scaffold(appBar: AppBar(title: 
    viewModel.user!=null&&viewModel.headers!=null?
    Text(

            "Добро пожаловать, ${viewModel.user!.name}!",
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
            color:  Colors.black,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            fontFamily: 'Open Sans',
            fontSize: 20),) : const Text("Загрузка"),
    actions: [ 
      IconButton(onPressed: viewModel._myPage, icon: const Icon(Icons.person_outline))
    ],),
    body: Container(
      child: Column(children: [

      ]),

    ),);
  }

  static Widget create()
  {
    return ChangeNotifierProvider(create: (BuildContext context) => _ViewModel(context: context ), child: const AppMain(),);
  }
} 