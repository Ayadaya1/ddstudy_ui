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
  Future toComments(String postId) async
  {
    await AppNavigator.toComments(postId);
    posts = await _dataService.getPosts();
    likes = await _dataService.getLikes(posts!);
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
          res = Container(
    color: Colors.lightBlue,
    height: size.width,
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
                        viewModel.omPageChanged(listIndex, value)),
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
                current: viewModel.pager[listIndex],
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
                                like ? viewModel.unlikePost(post.id, listIndex) : viewModel.likePost(post.id, listIndex);
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
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  const PageIndicator({
    Key? key,
    required this.count,
    required this.current,
    this.size = 10,
    this.activeColor = Colors.white,
    this.inactiveColor = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return Container(
          width: size,
          height: size,
          margin: EdgeInsets.symmetric(horizontal: 3.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: current == index ? activeColor : inactiveColor,
          ),
        );
      }),
    );
  }
}

