import 'package:dd_study_ui/data/services/auth_service.dart';
import 'package:dd_study_ui/data/services/data_service.dart';
import 'package:dd_study_ui/data/services/sync_service.dart';
import 'package:dd_study_ui/internal/config/app_config.dart';
import 'package:dd_study_ui/internal/config/shared_prefs.dart';
import 'package:dd_study_ui/internal/config/token_secure_storage.dart';
import 'package:dd_study_ui/ui/roots/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/post.dart';
import '../../domain/models/post_model.dart';
import '../../domain/models/user.dart';

class _ViewModel  extends ChangeNotifier {
  BuildContext context;
  final _authService = AuthService();
  final _dataService = DataService();
  final _lvc = ScrollController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool val)
  {
    _isLoading = val;
    notifyListeners();
  }

  _ViewModel({required this.context})
  {
    asyncInit();
    _lvc.addListener(() {
      print(_lvc.offset);
     var max = _lvc.position.maxScrollExtent;
     var current = _lvc.offset;
     var percent = current/max*100;
     if(percent>80)
     {
      if(!isLoading)
      {
        isLoading = true;
        Future.delayed(const Duration(seconds: 1)).then((value)
        {
          posts = <PostModel>[...posts!, ...posts!];
          isLoading = false;
        });
      }

     }
     });
  }


  User? _user;

  User? get user => _user;
  set user(User? val)
  {
    _user = val;
    notifyListeners();
  }



  List<PostModel>? _posts;
  List<PostModel>? get posts => _posts;
  set posts(List<PostModel>? val)
  {
    _posts = val;
    notifyListeners();
  }

  Map<int,int> pager = <int,int>{};

  Map<String, String>? headers;

  void omPageChanged(int ListIndex, int pageIndex)
  {
    pager[ListIndex] = pageIndex;
    notifyListeners();
  }

  void asyncInit() async
  {
    user = await SharedPrefs.getStoredUser();
    await SyncService().syncPosts();
    posts = await _dataService.getPosts();
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
  void onclick()
  {
    var offset = _lvc.offset;
    _lvc.animateTo(0, duration: const Duration(seconds: 1), curve: Curves.easeInCubic);
  }
}

class AppMain extends StatelessWidget {
  const AppMain({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<_ViewModel>();
    var size = MediaQuery.of(context).size;
    var itemCount = viewModel.posts?.length??0;

    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: viewModel.onclick, child: const Icon(Icons.arrow_upward)),
      appBar: AppBar(title: 
    viewModel.user!=null&&viewModel.headers!=null?
    Text(

            "Добро пожаловать, ${viewModel.user!.name}!",
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
            color:  Colors.black,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            fontFamily: 'Open Sans',
            fontSize: 20),) : const Text("Загрузка"),
    actions: [ 
      IconButton(onPressed: viewModel._myPage, icon: const Icon(Icons.person_outline))
    ],),
    body: Container( 
      child: viewModel.posts==null?
      const Center(child: CircularProgressIndicator()):
      Column(children:[
        Expanded(child: 
      ListView.separated( controller: viewModel._lvc,itemBuilder: (context, listIndex)  {
        Widget res;
        var posts = viewModel.posts;
        if(posts!=null) 
        {
          var post = posts[listIndex];
          res = Container(color: Colors.grey, height: size.width, child: Column(
            children: [
              Expanded(child:
            PageView.builder(
              onPageChanged: ((value) => viewModel.omPageChanged(listIndex, value)),
              itemCount: post.attaches.length, itemBuilder: ( pageContext, pageIndex)=>Container
            (color:Colors.yellow ,
            child: Image(image: NetworkImage("$baseUrl${post.attaches[pageIndex].contentLink}")),))),
            PageIndicator(count: post.attaches.length , current: viewModel.pager[listIndex]),
             Text(post.text??"")
          ]),
);
        }
        else
        {
          res = const SizedBox.shrink();
        }
        return res;
        }, separatorBuilder: (context, index) => const Divider(), itemCount: itemCount),
        ),
        if (viewModel.isLoading) const LinearProgressIndicator()
      ],
      
      )
    ),
    );
  }

  static Widget create()
  {
    return ChangeNotifierProvider(create: (BuildContext context) => _ViewModel(context: context ), child: const AppMain(),);
  }
} 

class PageIndicator extends StatelessWidget {
  final int count;
  final int? current;
  final double width;
  const PageIndicator({Key? key, required this.count, required this.current, this.width = 10}): super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = <Widget>[];
    for(var i = 0; i<count; i++)
    {
      widgets.add(Icon(i==(current??0)?Icons.circle : Icons.circle_outlined, size: width));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widgets,);
  }
}