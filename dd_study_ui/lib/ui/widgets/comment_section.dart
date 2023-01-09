  import 'package:dd_study_ui/domain/models/comment_model.dart';
import 'package:dd_study_ui/domain/models/like_model.dart';
import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';

import '../../domain/models/post_model.dart';
import '../../internal/config/app_config.dart';
import '../../internal/dependencies/repository_module.dart';
import '../roots/app.dart';


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

  void addComment()
  {
    _api.addCommentToPost(post!.id, state.comment!).then((value)async {comments = await _api.getAllComments(postId);}).then((value) {notifyListeners();});
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
          res = Container(color: Colors.lightBlue, height: size.width, child: Column(
            children: [
              Row(
              children: [
                CircleAvatar(
                  radius: 20.0,
                  backgroundImage: NetworkImage(post.user.avatar),
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
            IconButton(icon : (liked!)? const Icon(Icons.favorite) : const Icon(Icons.favorite_border), onPressed: () async{
              liked? viewModel.unlikePost() :viewModel.likePost() ;
            },), Text(post.likes.toString(),),
            ],),
          ]),
);
        }
      else
      {
        var comment = viewModel.comments![listIndex-1];
                      res = Container(
                        color: const Color.fromARGB(255, 78, 215, 233),
                        child: Column(
                        children: [
              Row(
              children: [
                CircleAvatar(
                  radius: 20.0,
                  backgroundImage: NetworkImage(comment.author.avatar),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(comment.author.name, style: const TextStyle(fontWeight: FontWeight.bold),),
                      Text(comment.text),
                    ],
                  ),
                ), 
                Column(
                    children: [
                      IconButton(icon: const Icon(Icons.favorite), onPressed: (){},),
                      Text(comment.likes.toString()),
                    ],
                  ),
              ],
            ),
                        
                ]),);
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
