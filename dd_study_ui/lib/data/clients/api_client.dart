import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';

import '../../domain/models/user.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient 
{
  factory ApiClient(Dio dio, {String? baseUrl}) = _ApiClient;

  @POST("api/User/GetCurrentUser")
  Future<User?> getUser();
}