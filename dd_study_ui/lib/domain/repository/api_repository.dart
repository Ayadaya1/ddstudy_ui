import 'dart:io';

import 'package:dd_study_ui/domain/models/attach_meta.dart';
import 'package:dd_study_ui/domain/models/comment_model.dart';
import 'package:dd_study_ui/domain/models/like_model.dart';
import 'package:dd_study_ui/domain/models/refresh_token_request.dart';
import 'package:dd_study_ui/domain/models/token_request.dart';
import 'package:dd_study_ui/domain/models/token_response.dart';

import '../models/post_model.dart';
import '../models/register_model.dart';
import '../models/user.dart';

abstract class ApiRepository
{
  Future<TokenResponse?> getToken({required String login, required String password});

  Future<TokenResponse?> refreshToken(String refreshToken);

  Future registerUser(RegisterModel model);

  Future<User?> getUser ();

  Future<List<PostModel>> getPosts(int take, int skip);

  Future<List<AttachMeta>> uploadTemp({required List<File> files});

  Future addAvatarToUser(AttachMeta model);

  Future addPost(String text, List<AttachMeta> models);

  Future addLike(LikeModel model);

  Future<bool> checkLike(LikeModel model);

  Future removeLike(LikeModel model);

  Future getPost(String postId);

  Future<List<CommentModel>> getAllComments(String postId);

  Future addCommentToPost(String postId, String comment);

  Future<User?> getUserById(String userId);

  Future<CommentModel?> getCommentById(String commentId);
}