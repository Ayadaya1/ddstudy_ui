import 'dart:io';

import 'package:dd_study_ui/data/clients/api_client.dart';
import 'package:dd_study_ui/data/clients/auth_client.dart';
import 'package:dd_study_ui/domain/models/attach_meta.dart';
import 'package:dd_study_ui/domain/models/comment_model.dart';
import 'package:dd_study_ui/domain/models/like_model.dart';
import 'package:dd_study_ui/domain/models/post_model.dart';
import 'package:dd_study_ui/domain/models/register_model.dart';
import 'package:dd_study_ui/domain/models/settings_model.dart';
import 'package:dd_study_ui/domain/repository/api_repository.dart';

import '../../domain/models/refresh_token_request.dart';
import '../../domain/models/token_request.dart';
import '../../domain/models/token_response.dart';
import '../../domain/models/user.dart';

class ApiDataRepository extends ApiRepository
{
  final AuthClient _auth;
  final ApiClient _api;
  ApiDataRepository(this._auth, this._api);

  @override
  Future<TokenResponse?> getToken({required String login, required String password}) async
  {
    return await _auth.getToken(TokenRequest(login: login, password: password));

  } 
  @override
  Future<TokenResponse?> refreshToken(String refreshToken) async
  {
    await _auth.getRefreshToken(RefreshTokenRequest(refreshToken: refreshToken));
  }
  @override
  Future<User?> getUser () => _api.getUser();

  @override
  Future<List<PostModel>> getPosts(int take, int skip) =>_api.getPosts(take, skip);

  @override
  Future<List<AttachMeta>> uploadTemp({required List<File> files}) {
    return _api.uploadTemp(files: files);
  }
  
  @override
  Future addAvatarToUser(AttachMeta model) {
    return _api.addAvatarToUser(model);
  }

  @override
  Future registerUser(RegisterModel model) {
    return _auth.registerUser(model);
  }
  
  @override
  Future addPost(String text,  List<AttachMeta> models) {
    return _api.addPost(text, models);
  }
  
  @override
  Future addLike(LikeModel model) {
    return _api.addLike(model);
  }

  @override
  Future<bool> checkLike(LikeModel model) {
    return _api.checkLike(model);
  }

  @override
  Future removeLike(LikeModel model) {
    return _api.removeLike(model);
  }

  @override
  Future<PostModel> getPost(String postId) {
    return _api.getPost(postId);
  }

  @override
  Future<List<CommentModel>> getAllComments(String postId) {
    return _api.getAllComments(postId);
  }

  @override
  Future addCommentToPost(String postId, String comment) {
    return _api.addComment(postId, comment);
  }

  @override
  Future<User?> getUserById(String userId) {
    return _api.getUserById(userId);
  }

  @override
  Future<CommentModel?> getCommentById(String commentId) {
    return _api.getCommentById(commentId);
  }

  @override
  Future<List<User>>? getSubscribers(String userId) {
    return _api.getSubscribers(userId);
  }

  @override
  Future<List<User>>? getSubscriptions(String userId) {
    return _api.getSubscriptions(userId);
  }

  @override
  Future subscribe(String targetId) {
    return _api.subscribe(targetId);
  }

  @override
  Future unsubscribe(String targetId) {
    return _api.unsubscribe(targetId);
  }

  @override
  Future<bool> checkSub(String targetId) {
    return _api.checkSub(targetId);
  }

  @override
  Future changePrivacySettings(PrivacySettingsModel model) {
    return _api.changePrivacySettings(model);
  }

  @override
  Future<PrivacySettingsModel> getPrivacySettings() {
    return _api.getPrivacySettings();
  }
  @override 
  Future<List<PostModel>>? getUsersPosts(int take, int skip, String userId) {
    return _api.getUsersPosts(take, skip, userId);
  }
}