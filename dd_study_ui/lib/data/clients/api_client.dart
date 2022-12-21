import 'dart:io';

import 'package:dd_study_ui/domain/models/attach_meta.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';

import '../../domain/models/post_model.dart';
import '../../domain/models/user.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient 
{
  factory ApiClient(Dio dio, {String? baseUrl}) = _ApiClient;

  @POST("/api/User/GetCurrentUser")
  Future<User?> getUser();

  @GET("/api/Post/GetTopPosts")
  Future<List<PostModel>> getPosts(@Query("take") int take, @Query("skip") int skip);

  @POST("/api/Attach/UploadFiles")
  Future<List<AttachMeta>> uploadTemp({@Part(name: "files") required List<File> files});

  @POST("/api/User/AddAvatarToUser")
    Future addAvatarToUser(@Body() AttachMeta model);
  
  @POST("/api/Post/AddPost")
    Future addPost(@Query("text")String text, @Body() List<AttachMeta> models);
}