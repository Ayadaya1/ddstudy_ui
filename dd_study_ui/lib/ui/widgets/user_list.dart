import 'package:dd_study_ui/data/services/data_service.dart';
import 'package:dd_study_ui/domain/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../internal/config/app_config.dart';
import '../../internal/dependencies/repository_module.dart';


class _ViewModel  extends ChangeNotifier {
  BuildContext context;
  List<User>? users;
  final _api = RepositoryModule.apiRepository();
  final _dataService = DataService();

   _ViewModel({required this.context, required this.users})
  {
    asyncInit();
  }
  List<bool>? _subs;
  List<bool>? get subs =>_subs;
  set subs(List<bool>? val)
  {
    _subs = val;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool val)
  {
    _isLoading = val;
    notifyListeners();
  }
  void asyncInit() async
  {
    if(users!=null)
    {
      subs = await _dataService.getSubs(users!);
    }
    notifyListeners();
  }

  void subscribe(String userId, int index) async
  {
    _api.subscribe(userId).then((value)  {
    subs![index] = true;
    }).then((value) {notifyListeners();});
  }

  void unsubscribe(String userId, int index) async
  {
    _api.unsubscribe(userId).then((value)  {
    subs![index] = false;
    }).then((value) {notifyListeners();});
  }
}

class UserList extends StatelessWidget {
  const UserList({Key? key}):super(key:key);

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<_ViewModel>();
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: 
    viewModel.users!=null?
    const Text(

            "Добро пожаловать!",
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
            color:  Colors.black,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            fontFamily: 'Open Sans',
            fontSize: 20),) : const Text("Загрузка"),),
    body: Container( 
      child: viewModel.users==null?
      const Center(child: CircularProgressIndicator()):
      Column(children:[
        Expanded(child: 
      ListView.separated(
  itemBuilder: (context, listIndex)  {
    Widget res;
    var users = viewModel.users;
    if(users!=null) 
    {
      var user = users[listIndex];
      res = Card(
        child: Container(
          height: 80,
          child: Row(
            children: [
              GestureDetector(
                child: CircleAvatar(
                  radius: 20.0,
                  backgroundImage: NetworkImage("$baseUrl${user.avatar}"),
                ),
                onTap: () {
                  //viewModel._myPage(user.id);
                }
              ),
              SizedBox(width: 16),
              Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
              const Spacer(),
              viewModel.subs!=null?
              OutlinedButton(
                child: viewModel.subs![listIndex]? const Text("Отписаться")
                :const Text("Подписаться"),
                onPressed: () {
                  viewModel.subs![listIndex]?
                  viewModel.unsubscribe(user.id, listIndex):
                  viewModel.subscribe(user.id,listIndex);
                },
              ):const CircularProgressIndicator()
              ,
            ],
          ),
        ),
      );
    }
    else
    {
      res = const SizedBox.shrink();
    }
    return res;
  },
  separatorBuilder: (context, index) => const Divider(),
  itemCount: viewModel.users!.length,
),
        ),
        if (viewModel.isLoading) const LinearProgressIndicator()
      ],
      
      )
    ),
    );
  }

  static Widget create(List<User> users)
  {
    return ChangeNotifierProvider(create: (BuildContext context) => _ViewModel(context: context, users: users), child: const UserList(),);
  }
}

