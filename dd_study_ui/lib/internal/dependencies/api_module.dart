import 'package:dd_study_ui/data/clients/auth_client.dart';
import 'package:dd_study_ui/data/services/auth_service.dart';
import 'package:dd_study_ui/domain/models/refresh_token_request.dart';
import 'package:dd_study_ui/domain/models/token_request.dart';
import 'package:dd_study_ui/internal/config/token_secure_storage.dart';
import 'package:dd_study_ui/ui/roots/app_navigator.dart';
import 'package:dio/dio.dart';
import '../../data/clients/api_client.dart';
import '../config/app_config.dart';


class ApiModule
{
   static AuthClient? _authClient;
   static ApiClient? _apiClient;
   static AuthClient auth()
   {
    if(_authClient==null)
    {
      final dio = Dio();
      _authClient = AuthClient(dio, baseUrl: baseUrl);
    }
    return _authClient!;
   }

   static ApiClient api() => _apiClient ?? ApiClient(_addInterceptors(Dio()), baseUrl: baseUrl,);

  static Dio _addInterceptors(Dio dio)
  {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async
      {
        final token = await TokenStorage.getAccessToken();
        options.headers.addAll({"Authorization":"Bearer $token"});
        return handler.next(options);
      },
      onError: (e, handler) async 
      {
        if(e.response?.statusCode == 401)
        {
          // ignore: deprecated_member_use
          dio.lock();
          RequestOptions options = e.response!.requestOptions;
          var rt = await TokenStorage.getRefreshToken();
          try
          {
          if(rt!=null)
          {
            var token = await auth().getRefreshToken(RefreshTokenRequest(refreshToken: rt));
            await TokenStorage.setStoredToken(token);
            options.headers["Authorization"] = "Bearer ${token!.accessToken}";
          }
          }
          catch(e)
          {
            var service = AuthService();
            //if(await service.checkAuth())
            {
              await service.logout();
              AppNavigator.toLoader();
            }
            return handler.resolve(Response(requestOptions: options, statusCode: 400));

          }
          finally
          {
            // ignore: deprecated_member_use
            dio.unlock();
          }
          return handler.resolve(await dio.fetch(options));
        } 
        else
        {
          return handler.next(e);   
        }
        
      }
    ));
    return dio;
  }
}