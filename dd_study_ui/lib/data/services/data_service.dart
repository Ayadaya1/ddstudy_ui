import 'package:dd_study_ui/domain/db_model.dart';
import 'package:dd_study_ui/domain/models/like_model.dart';
import 'package:dio/dio.dart';

import '../../domain/models/comment_model.dart';
import '../../domain/models/post.dart';
import '../../domain/models/post_content.dart';
import '../../domain/models/post_model.dart';
import '../../domain/models/user.dart';
import '../../internal/dependencies/repository_module.dart';
import 'database.dart';

class DataService 
{
  final _api = RepositoryModule.apiRepository();
  Future cuUser(User user) async
  {
    await DB.instance.createUpdate(user);
  }

  Future rangeUpdateEntities<T extends DbModel>(Iterable<T> elems) async
  {
    await DB.instance.createUpdateRange(elems);
  }

  Future <List<PostModel>> getPosts() async
  {
    var res = <PostModel>[];
    var posts = await DB.instance.getAll<Post>();
    for(var post in posts)
    {
      var author = await DB.instance.get<User>(post.authorId);
      var contents =
          (await DB.instance.getAll<PostContent>(whereMap: {"postId": post.id,}))
              .toList();
      if(author!=null)
      {
        res.add(PostModel( id: post.id, attaches: contents, user: author, text: post.text, likes: post.likes, comments: post.comments));
      }
    }
    return res;
  }

  Future <List<bool>> getLikes(List<PostModel> posts) async
  {
    var res = <bool>[];
    for(var post in posts)
    {
      LikeModel model = LikeModel(contentType: "Post", contentId: post.id);
      res.add(await _api.checkLike(model));
    }
        return res;
    }

  Future <List<bool>> getCommentLikes(List<CommentModel> comments) async
  {
    var res = <bool>[];
    for(var comment in comments)
    {
      LikeModel model = LikeModel(contentType: "Comment", contentId: comment.id);
      res.add(await _api.checkLike(model));
    }
        return res;
  }
  Future <List<bool>> getSubs(List<User> users) async
  {
    var res = <bool>[];
    for(var user in users)
    {
      res.add(await _api.checkSub(user.id));
    }
        return res;
  }
}