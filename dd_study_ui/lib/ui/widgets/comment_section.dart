  import 'package:dd_study_ui/data/services/data_service.dart';
import 'package:dd_study_ui/domain/models/comment_model.dart';
import 'package:dd_study_ui/domain/models/like_model.dart';
import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';

import '../../domain/models/post_model.dart';
import '../../internal/config/app_config.dart';
import '../../internal/dependencies/repository_module.dart';
import '../roots/app.dart';
import '../roots/app_navigator.dart';


class _ViewModelState {
  final String? comment;
  const _ViewModelState({
    this.comment,
  });

  _ViewModelState copyWith({
    String? comment,

  }) {
    return _ViewModelState(
      comment: comment ?? this.comment,
    );
  }
}


  class _ViewModel  extends ChangeNotifier {
    final _api = RepositoryModule.apiRepository();
    final _dataService = DataService();
    String postId;
    BuildContext context;

    var commentTec = TextEditingController();

    bool _isLoading = false;
    bool get isLoading => _isLoading;
    set isLoading(bool val)
    {
      _isLoading = val;
      notifyListeners();
    }
    
    
    var _state = const _ViewModelState();

    set state (_ViewModelState val)
    {
      _state = _state.copyWith(comment: val.comment);
      notifyListeners();
    }
    _ViewModelState get state => _state;

    _ViewModel({required this.context, required this.postId})
    {
      asyncInit();
      commentTec.addListener((){
      state = state.copyWith(comment: commentTec.text);
    });
    }

    Map<int,int> pager = <int,int>{};
    void omPageChanged(int ListIndex, int pageIndex)
    {
      pager[ListIndex] = pageIndex;
      notifyListeners();
    }
    void toProfile(String userId) async
  {
    AppNavigator.toMyPage(userId);
  }
    List<CommentModel>? _comments;
    List<CommentModel>? get comments => _comments;
    set comments(List<CommentModel>? val)
    {
      _comments = val;
      notifyListeners();
    }
    PostModel? _post;
    PostModel? get post => _post;
    set post(PostModel? val)
  {
    _post = val;
    notifyListeners();
  }

  List<bool>? _likes;
  List<bool>? get likes => _likes;
  set likes(List<bool>? val)
  {
    _likes = val;
    notifyListeners();
  }

    bool? _liked;
    bool? get liked=>_liked;
    set liked(bool? val)
    {
      _liked = val;
      notifyListeners();
    }

  void asyncInit() async
  {
    _post = await _api.getPost(postId);
    _comments = await _api.getAllComments(postId);
    if(_post!=null)
    {
      _liked = await _api.checkLike(LikeModel(contentType: "Post", contentId: post!.id));
    }
    if(comments!=null)
    {
      likes = await _dataService.getCommentLikes(comments!);
    }
    notifyListeners();
  }
  void likePost()
  {
    LikeModel model = LikeModel(contentType: "Post", contentId: post!.id);
    _api.addLike(model).then((value) async {liked = true;
    post = await _api.getPost(postId);
    }).then((value) {notifyListeners();});
  }
  void unlikePost()
  {
    LikeModel model = LikeModel(contentType: "Post", contentId: post!.id);
    _api.removeLike(model).then((value) async {liked = false;
    post = await _api.getPost(postId);
    }).then((value) {notifyListeners();});
  }

  void likeComment(String commentId, int index)
  {
    LikeModel model = LikeModel(contentType: "Comment", contentId: commentId);
    _api.addLike(model).then((value) async  {comments![index]=  (await _api.getCommentById(commentId))!;
    likes![index] = true;
    }).then((value) {notifyListeners();});
    
    
  }
  void unlikeComment(String commentId, int index) async
  {
    LikeModel model = LikeModel(contentType: "Comment", contentId: commentId);
    _api.removeLike(model).then((value) async  {comments![index]=  (await _api.getCommentById(commentId))!;
    likes![index] = false;
    }).then((value) {notifyListeners();});
  }

  void addComment()
  {
    _api.addCommentToPost(post!.id, state.comment!).then((value)async {
      comments = await _api.getAllComments(postId);
      likes = await _dataService.getCommentLikes(comments!);
    }).then((value) {notifyListeners();});
  }
  }

  class Comments extends StatelessWidget {
    const Comments({Key? key}): super(key: key);




    @override
    Widget build(BuildContext context) {
      var viewModel = context.watch<_ViewModel>();
      var post = viewModel.post;
      var liked = viewModel.liked;
      var size = MediaQuery.of(context).size;
      return Scaffold(
  appBar: AppBar(
    title: viewModel.post != null ? Text(viewModel.post!.id) : const Text("Загрузка")
  ),
  body: Container( 
      child: viewModel.post==null && viewModel.liked==null?
      const Center(child: CircularProgressIndicator()):
      Column(children:[
        Expanded(child: 
      ListView.separated(itemBuilder: (context, listIndex)  {
        Widget res;

        if(post!=null) 
        {
          if(listIndex==0)
          {
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
                                backgroundImage: NetworkImage("$baseUrl${post.user.avatar}"),
                            ),
                            onTap: () async {
                                viewModel.toProfile(post.user.id);
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
                            icon: liked!
                                ? Icon(Icons.favorite)
                                : Icon(Icons.favorite_border),
                            color: liked! ? Colors.red : Colors.black,
                            onPressed: () async {
                                liked? viewModel.unlikePost() : viewModel.likePost();
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
                    ],
                ),
            ),
        ],
    ),
);
        }
      else
      {
        var comment = viewModel.comments![listIndex-1];
        var like = viewModel.likes![listIndex-1];
                      res = Container(
    color: const Color.fromARGB(255, 78, 215, 233),
    child: Column(
        children: [
            Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                    children: [
                        GestureDetector(
                            child: CircleAvatar(
                                radius: 30.0,
                                backgroundImage: NetworkImage("$baseUrl${comment.author.avatar}"),
                            ),
                            onTap: () async {
                                viewModel.toProfile(comment.author.id);
                            },
                        ),
                        SizedBox(width: 8.0),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Text(
                                        comment.author.name,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0,
                                        ),
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(comment.text),
                                ],
                            ),
                        ),
                        Column(
                            children: [
                                IconButton(
                                    icon: like
                                        ? Icon(Icons.favorite)
                                        : Icon(Icons.favorite_border),
                                    color: Colors.red,
                                    onPressed: () {
                                        like
                                            ? viewModel.unlikeComment(
                                                comment.id, listIndex - 1)
                                            : viewModel.likeComment(
                                                comment.id, listIndex - 1);
                                    },
                                ),
                                Text(
                                    comment.likes.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                    ),
                                ),
                            ],
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
    }, separatorBuilder: (context, index) => const Divider(), itemCount: viewModel.comments!.length+1),
        ),
        if (viewModel.isLoading) const LinearProgressIndicator(),
         TextField(
  decoration: const InputDecoration(labelText: "Введите комментарий"),
  controller: viewModel.commentTec,
),
ElevatedButton(
  onPressed: () {
    viewModel.addComment();
  },
  child: const Text("Добавить комментарий"),
),
      
      ],
      
      )
    ),
      );
    }

    static Widget create(String postId)
  {
    return ChangeNotifierProvider(create: (BuildContext context) => _ViewModel(context: context, postId: postId), child: const Comments( ),);
  }
  }
