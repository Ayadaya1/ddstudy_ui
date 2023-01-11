import 'dart:io';
import 'dart:ui';
import 'package:dd_study_ui/data/services/data_service.dart';
import 'package:dd_study_ui/internal/dependencies/repository_module.dart';
import 'package:dd_study_ui/ui/common/cam_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/services/auth_service.dart';
import '../../domain/models/like_model.dart';
import '../../domain/models/post_model.dart';
import '../../domain/models/user.dart';
import '../../internal/config/app_config.dart';
import '../../internal/config/shared_prefs.dart';
import '../../internal/config/token_secure_storage.dart';
import '../roots/app.dart';
import '../roots/app_navigator.dart';


class _ViewModel  extends ChangeNotifier {
  BuildContext context;
  final _authService = AuthService();
  final _api = RepositoryModule.apiRepository();
  final String userId;
  final _dataService = DataService();

  _ViewModel({required this.context, required this.userId})
  {
    asyncInit();
  }

  Map<int,int> pager = <int,int>{};
  void omPageChanged(int ListIndex, int pageIndex)
  {
    pager[ListIndex] = pageIndex;
    notifyListeners();
  }

  bool? _subscribed;
  bool? get subscribed => _subscribed;
  set subscribed(bool? val)
  {
    _subscribed = val;
    notifyListeners();
  }

  User? _user;

  User? get user => _user;
  set user(User? val)
  {
    _user = val;
    notifyListeners();
  }

   User? _owner;

  User? get owner => _owner;
  set owner(User? val)
  {
    _owner = val;
    notifyListeners();
  }

  Map<String, String>? headers;
  
  List<PostModel>? _posts;
  List<PostModel>? get posts => _posts;
  set posts(List<PostModel>? val)
  {
    _posts = val;
    notifyListeners();
  }

  List<bool>? _likes;
  List<bool>? get likes => _likes;
  set likes(List<bool>? val)
  {
    _likes = val;
    notifyListeners();
  }


  void asyncInit() async
  {
    owner = await _api.getUserById(userId);
    var token = await TokenStorage.getAccessToken();
    headers = {"Authorization": "Bearer $token"};
    user = await SharedPrefs.getStoredUser();
    if(owner!=null)
    {
      subscribed = await _api.checkSub(owner!.id);
    }
    var img = await NetworkAssetBundle(Uri.parse("$baseUrl${owner!.avatar}")).load("$baseUrl${owner!.avatar}");
      avatar =  Image.memory(img.buffer.asUint8List());
    try{
    posts = await _api.getUsersPosts(100, 0, owner!.id);
    }
    on DioError catch(e)
    {
      print(e.error);
    }
    if(posts!=null)
    {
      likes = await _dataService.getLikes(posts!);
    }
    notifyListeners();
  }
  
  void _myPage(String userId) async
  {
    AppNavigator.toMyPage(userId);
  }

  void _logout () 
  {
     _authService.logout().then((value) => AppNavigator.toLoader());
  }

  void _toSubscribers() async
  {
    if(owner!=null)
    {
      var subscribers = await _api.getSubscribers(owner!.id);
      AppNavigator.toUserList(subscribers);
      notifyListeners();
    }

  }
  void _toSubscriptions() async
  {
    if(owner!=null)
    {
      var subscriptions = await _api.getSubscriptions(owner!.id);
      AppNavigator.toUserList(subscriptions);
      notifyListeners();
    }

  }
  void _toSettings() async
  {
    AppNavigator.toSettings();
    notifyListeners();
  }

  void subscribe() async
  {
    _api.subscribe(userId).then((value)  {
    subscribed = true;
    }).then((value) async {owner = await _api.getUserById(userId);}).then((value) {notifyListeners();});
  }

  void unsubscribe() async
  {
    _api.unsubscribe(userId).then((value)  {
    subscribed = false;
    }).then((value) async {owner = await _api.getUserById(userId);}).then((value) {notifyListeners();});
  }

  String? _imagePath;
  String? get imagePath => _imagePath;
  set imagePath(String? val)
  {
    _imagePath = val;
    notifyListeners();
  }
  Image? _avatar;
  Image? get avatar => _avatar;
  set avatar(Image? val)
  {
    _avatar = val;
    notifyListeners();
  }

  Future changePhoto() async
  {
    await Navigator.of(context).push(MaterialPageRoute(builder: (newContext)=>
    Scaffold(backgroundColor: Colors.black, appBar: AppBar(backgroundColor: Colors.black,),body:SafeArea(child: CamWidget(onFile: (file)
    {
      imagePath = file.path;
      Navigator.of(newContext).pop();
    }),))));
    if(_imagePath!=null)
    {
    avatar = null;
    var t = await _api.uploadTemp(files: [File(imagePath!)]);
    if(t.isNotEmpty)
    {
      await _api.addAvatarToUser(t.first);
      var img = await NetworkAssetBundle(Uri.parse("$baseUrl${owner!.avatar}")).load("$baseUrl${owner!.avatar}");
      avatar =  Image.memory(img.buffer.asUint8List());
    }
    }
  }

  void likePost(String postId, int index)
  {
    LikeModel model = LikeModel(contentType: "Post", contentId: postId);
    _api.addLike(model).then((value) async  {posts![index]=  await _api.getPost(postId);
    likes![index] = true;
    }).then((value) {notifyListeners();});
    
    
  }
  void unlikePost(String postId, int index) async
  {
    LikeModel model = LikeModel(contentType: "Post", contentId: postId);
    _api.removeLike(model).then((value) async  {posts![index]=  await _api.getPost(postId);
    likes![index] = false;
    }).then((value) {notifyListeners();});
  }

  Future toComments(String postId) async
  {
    await AppNavigator.toComments(postId);
    posts = await _dataService.getPosts();
    likes = await _dataService.getLikes(posts!);
    notifyListeners();
  }
  
}

class Profile extends StatelessWidget {
  const Profile({Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<_ViewModel>();
    var itemCount = viewModel.posts?.length??0;
    return Scaffold(
      floatingActionButton: viewModel.owner == viewModel.user?FloatingActionButton(onPressed: (){
        AppNavigator.toAddPost();
      }, 
      child: const Icon(Icons.add),):
      null,
      appBar: AppBar(title:  
      
            viewModel.owner!=null&&viewModel.headers!=null?
            Text(
            "ID: ${viewModel.owner!.id}",
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
            color:  Color.fromARGB(255, 51, 50, 47),
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            fontFamily: 'Open Sans',
            fontSize: 12),
            ): const Text("Загрузка"),
            actions: viewModel.owner == viewModel.user?[
              IconButton(onPressed: (){viewModel._toSettings();}, icon: const Icon(Icons.settings)),
              IconButton(onPressed: viewModel._logout, icon: const Icon(Icons.exit_to_app_outlined)),

            ]:null,
            ),

      body: SafeArea(child:
      Padding(padding:EdgeInsets.all(10),
      child: viewModel.posts==null && viewModel.likes==null && viewModel.owner==null?
      const Center(child: CircularProgressIndicator()):
      SizedBox.expand(
        child: Column
        (
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        Expanded(child: 
        ListView.separated(itemBuilder: (context, listIndex)  {
        Widget res;
        var posts = viewModel.posts;
        var likes = viewModel.likes;
        if(viewModel.owner!=null) 
        {
          if(listIndex==0)
          {
            res = Container(
              child: Column(children: [
              GestureDetector(child:
          CircleAvatar(
            backgroundColor: Colors.blueAccent,
            radius: 120,
            child: CircleAvatar(
              
              radius:110,
              foregroundImage: viewModel.avatar?.image,
            ),
          ),
          onDoubleTap: viewModel.changePhoto,
          ),
          Text(
            "${viewModel.owner!.name}",
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
            "${viewModel.owner!.email}",
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
            "${viewModel.owner!.birthDate.substring(0,10)}",
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            fontFamily: 'Open Sans',
            fontSize: 15),
            ),
            GestureDetector(
              child:
          Text(
            "${viewModel.owner!.subscriberCount.toString()} подписчиков",
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            fontFamily: 'Open Sans',
            fontSize: 15),
            ),
            onTap:(){viewModel._toSubscribers();}
            ),
            GestureDetector(
              child:
          Text(
            "${viewModel.owner!.subscriptionCount.toString()} подписок",
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            fontFamily: 'Open Sans',
            fontSize: 15),
            ),
            onTap:() => viewModel._toSubscriptions(),
            ),

            viewModel.owner!=viewModel.user?
            viewModel.subscribed!=null?
            OutlinedButton(onPressed: (){
              viewModel.subscribed!?
              viewModel.unsubscribe():
              viewModel.subscribe();
            }, child: (viewModel.subscribed!? const Text("Отписаться"):const Text("Подписаться"))): const CircularProgressIndicator(): const SizedBox.shrink(),
              ]
            ));
          }
          else 
          {
          
          var post = posts![listIndex-1];
          var like = likes![listIndex-1];
          res = Container(
    color: Colors.lightBlue,
    child: Column(
        children: [
            Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                    children: [
                        GestureDetector(
                            child: CircleAvatar(
                                radius: 30.0,
                                backgroundImage: NetworkImage("$baseUrl${viewModel.user!.avatar}"),
                            ),
                            onTap: () {
                                viewModel._myPage(post.user.id);
                            },
                        ),
                        SizedBox(width: 8.0),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Text(
                                        post.user.name,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0,
                                        ),
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(post.text ?? ""),
                                ],
                            ),
                        ),
                    ],
                ),
            ),
            Expanded(
                child: PageView.builder(
                    onPageChanged: ((value) =>
                        viewModel.omPageChanged(listIndex-1, value)),
                    itemCount: post.attaches.length,
                    itemBuilder: (pageContext, pageIndex) => Container(
                        color: Colors.white,
                        child: Image(
                            image: NetworkImage(
                                "$baseUrl${post.attaches[pageIndex].contentLink}"),
                        ),
                    ),
                ),
            ),
            PageIndicator(
                count: post.attaches.length,
                current: viewModel.pager[listIndex-1],
            ),
            Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                    children: [
                        IconButton(
                            icon: like
                                ? Icon(Icons.favorite)
                                : Icon(Icons.favorite_border),
                            color: like ? Colors.red : Colors.black,
                            onPressed: () async {
                                like ? viewModel.unlikePost(post.id, listIndex-1) : viewModel.likePost(post.id, listIndex-1);
                            },
                        ),
                        SizedBox(width: 8.0),
                        Text(
                            post.likes.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                            ),
                            ),
                        SizedBox(width: 8.0),
                        IconButton(
                            icon: Icon(Icons.comment),
                            onPressed: () {
                                viewModel.toComments(post.id);
                            },
                        ),
                        SizedBox(width: 8.0),
                        Text(
                            post.comments.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                            ),
                        ),
                    ],
                ),
            ),
        ],
    ),
);
          }
        }
        else
        {
          res = const SizedBox.shrink();
        }
        return res;
        }, separatorBuilder: (context, index) => const Divider(), itemCount: itemCount+1),
        ),
            
      ],),),),
      
    ));
  }

  static Widget create(String userId)
  {
    return ChangeNotifierProvider(create: (BuildContext context) => _ViewModel(context: context, userId: userId), child: const Profile(),);
  }
}