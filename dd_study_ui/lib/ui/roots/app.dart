import 'package:dd_study_ui/data/clients/api_client.dart';
import 'package:dd_study_ui/data/services/auth_service.dart';
import 'package:dd_study_ui/data/services/data_service.dart';
import 'package:dd_study_ui/data/services/sync_service.dart';
import 'package:dd_study_ui/domain/models/like_model.dart';
import 'package:dd_study_ui/internal/config/app_config.dart';
import 'package:dd_study_ui/internal/config/shared_prefs.dart';
import 'package:dd_study_ui/internal/config/token_secure_storage.dart';
import 'package:dd_study_ui/ui/roots/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/post.dart';
import '../../domain/models/post_model.dart';
import '../../domain/models/user.dart';
import '../../internal/dependencies/repository_module.dart';

class _ViewModel  extends ChangeNotifier {
  BuildContext context;
  final _authService = AuthService();
  final _dataService = DataService();
  final _lvc = ScrollController();
  final _api = RepositoryModule.apiRepository();

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
          likes = <bool>[...likes!, ...likes!];
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

  List<bool>? _likes;
  List<bool>? get likes => _likes;
  set likes(List<bool>? val)
  {
    _likes = val;
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
    if(posts!=null)
      likes = await _dataService.getLikes(posts!);
    
  }

  void _myPage(String userId) async
  {
    AppNavigator.toMyPage(userId);
  }
  void toComments(String postId) async
  {
    AppNavigator.toComments(postId);
    notifyListeners();
  }
  void onclick()
  {
    _lvc.animateTo(0, duration: const Duration(seconds: 1), curve: Curves.easeInCubic);
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
  Future<bool> isPostLiked(String postId) async
  {
    LikeModel model = LikeModel(contentType: "Post", contentId: postId);
    return await _api.checkLike(model);

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
    viewModel.user!=null?
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
      IconButton(onPressed:() {viewModel._myPage(viewModel.user!.id);}, icon: const Icon(Icons.person_outline))
    ],),
    body: Container( 
      child: viewModel.posts==null && viewModel.likes==null?
      const Center(child: CircularProgressIndicator()):
      Column(children:[
        Expanded(child: 
      ListView.separated( controller: viewModel._lvc,itemBuilder: (context, listIndex)  {
        Widget res;
        var posts = viewModel.posts;
        var likes = viewModel.likes;
        if(posts!=null &&likes!=null) 
        {
          var post = posts[listIndex];
          var like = likes[listIndex];
          res = Container(color: Colors.lightBlue, height: size.width, child: Column(
            children: [
              Row(
              children: [
                GestureDetector(child:
                CircleAvatar(
                  radius: 20.0,
                  backgroundImage: NetworkImage("$baseUrl${viewModel.user!.avatar}"),
                ),
                onTap: () {
                  viewModel._myPage(post.user.id);
                }
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(post.user.name, style: const TextStyle(fontWeight: FontWeight.bold),),
                      Text(post.text??""),
                    ],
                  ),
                ),
              ],
            ),
              Expanded(child:
            PageView.builder(
              onPageChanged: ((value) => viewModel.omPageChanged(listIndex, value)),
              itemCount: post.attaches.length, itemBuilder: ( pageContext, pageIndex)=>Container
            (color:Colors.white ,
            child: Image(image: NetworkImage("$baseUrl${post.attaches[pageIndex].contentLink}")),))),
            PageIndicator(count: post.attaches.length , current: viewModel.pager[listIndex]),
            Row(children: [
            IconButton(icon : (like)? const Icon(Icons.favorite) : const Icon(Icons.favorite_border), onPressed: () async{
              like? viewModel.unlikePost(post.id, listIndex) :viewModel.likePost(post.id, listIndex) ;
            },), Text(post.likes.toString(),),
             IconButton(icon: const Icon(Icons.comment), onPressed: (){viewModel.toComments(post.id);},),
              Text(post.comments.toString())
            ],),
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
