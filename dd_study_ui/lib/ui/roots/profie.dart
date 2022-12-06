import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/auth_service.dart';
import '../../domain/models/user.dart';
import '../../internal/config/app_config.dart';
import '../../internal/config/shared_prefs.dart';
import '../../internal/config/token_secure_storage.dart';
import 'app_navigator.dart';


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
  
  void _logout () 
  {
     _authService.logout();
  }

  
}

class Profile extends StatelessWidget {
  const Profile({Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<_ViewModel>();
    return Scaffold(
      appBar: AppBar(title:  
      
            viewModel.user!=null&&viewModel.headers!=null?
            Text(
            "ID: ${viewModel.user!.id}",
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
            color:  Color.fromARGB(255, 51, 50, 47),
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            fontFamily: 'Open Sans',
            fontSize: 12),
            ): const Text("Загрузка"),
            actions: [
              IconButton(onPressed: viewModel._logout, icon: const Icon(Icons.exit_to_app_outlined)),
            ],
            ),

      body: SafeArea(child:
      Padding(padding:EdgeInsets.all(10),
      child: viewModel.user!=null&&viewModel.headers!=null?
      SizedBox.expand(
        child: Column
        (
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.blueAccent,
            radius: 120,
            child: CircleAvatar(
              radius:110,
              backgroundImage: NetworkImage(
                    "$baseUrl${viewModel.user!.avatar}",
                    headers: viewModel.headers),
            ),
          ),
          Text(
            "${viewModel.user!.name}",
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            fontFamily: 'Open Sans',
            fontSize: 40),
            
            ),
            Text(
            "${viewModel.user!.email}",
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            fontFamily: 'Open Sans',
            fontSize: 20),
            ),
            Text(
            "${viewModel.user!.birthDate.substring(0,10)}",
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            fontFamily: 'Open Sans',
            fontSize: 15),
            ),
        
        
      ],),):null,),
      
    ));
  }

  static Widget create()
  {
    return ChangeNotifierProvider(create: (BuildContext context) => _ViewModel(context: context), child: const Profile(),);
  }
}