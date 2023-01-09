import 'dart:io';

import 'package:dd_study_ui/domain/models/attach_meta.dart';
import 'package:dd_study_ui/domain/models/comment_model.dart';
import 'package:dd_study_ui/domain/models/like_model.dart';
import 'package:dd_study_ui/domain/models/settings_model.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';

import '../../domain/models/post_model.dart';
import '../../domain/models/user.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient 
{
  factory ApiClient(Dio dio, {String? baseUrl}) = _ApiClient;

  @GET("/api/User/GetCurrentUser")
  Future<User?> getUser();

  @GET("/api/Post/GetTopPosts")
  Future<List<PostModel>> getPosts(@Query("take") int take, @Query("skip") int skip);

  @POST("/api/Attach/UploadFiles")
  Future<List<AttachMeta>> uploadTemp({@Part(name: "files") required List<File> files});

  @POST("/api/User/AddAvatarToUser")
    Future addAvatarToUser(@Body() AttachMeta model);
  
  @POST("/api/Post/AddPost")
    Future addPost(@Query("text")String text, @Body() List<AttachMeta> models);

  @POST("/api/Like/AddLike")
    Future addLike(@Body() LikeModel model);

  @POST("/api/Like/CheckLike")
    Future<bool> checkLike(@Body() LikeModel model);

  @POST("/api/Like/RemoveLike")
    Future removeLike(@Body() LikeModel model);

  @GET("/api/Post/GetPost") 
    Future<PostModel> getPost(@Query("id")String postId);
  @GET("/api/Post/GetAllComments")
    Future<List<CommentModel>> getAllComments(@Query("postId")String postId);
  
  @POST("/api/Post/AddCommentToPost")
    Future addComment(@Query("postId") String postId, @Query("comment") String comment);

  @GET("/api/User/GetUserById")
    Future<User?> getUserById(@Query("userId") String userId);
  
  @GET("/api/Post/GetCommentById")
    Future<CommentModel?> getCommentById(@Query("commentId") String commentId);

  @GET("/api/User/GetSubscribers")
    Future<List<User>>? getSubscribers(@Query("userId")String userId);

  @GET("/api/User/GetSubscriptions")
    Future<List<User>>? getSubscriptions(@Query("userId")String userId);

  @POST("/api/User/SubscribeToUser")
    Future subscribe(@Query("targetId")String targetId);

  @POST("/api/User/UnsubscribeFromUser")
    Future unsubscribe(@Query("targetId")String targetId);

  @GET("/api/User/CheckSubscription")
    Future<bool> checkSub(@Query("targetId")String targetId);

  @GET("/api/User/GetPrivacySettings")
    Future<PrivacySettingsModel> getPrivacySettings();

  @POST("/api/User/ChangePrivacySettings")
    Future changePrivacySettings(@Body() PrivacySettingsModel model);
} 