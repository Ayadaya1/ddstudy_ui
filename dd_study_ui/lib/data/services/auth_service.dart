import 'dart:io';

import 'package:dd_study_ui/domain/repository/api_repository.dart';
import 'package:dd_study_ui/internal/config/shared_prefs.dart';
import 'package:dd_study_ui/internal/config/token_secure_storage.dart';
import 'package:dd_study_ui/internal/dependencies/repository_module.dart';
import 'package:dio/dio.dart';

class AuthService
{
  final ApiRepository _api = RepositoryModule.apiRepository();
  Future auth(String? login, String? password) async
  {
    if(login!=null && login.isNotEmpty && password != null && password.isNotEmpty )
    {
      try
      {
      var token = await _api.getToken(login: login, password: password);
      if(token!=null)
      {
        await TokenStorage.setStoredToken(token);
        var user = await _api.getUser();
        if(user!=null)
        {
          SharedPrefs.setStoredUser(user);
        }
      } 
      }
      on DioError catch(e)
      {
        if(e.error is SocketException)
        {
          throw NoNetworkException();
        }
        else
          if(<int>[404].contains(e.response?.statusCode))
          {
            throw WrongCredentialsException();
          }
          else if(<int>[500].contains(e.response?.statusCode))
          {
            throw UnexpectedException();
          }
      }
    }
  }

  Future<bool> tryGetUser() async
  {
    try
    {
      var user = await _api.getUser();
      return true;
    }
    catch(e)
    {
      return false;
    }
  }

  Future<bool> checkAuth()async
  {
    return ((await TokenStorage.getAccessToken()) != null) &&  (await SharedPrefs.getStoredUser()!= null);

  }

  Future logout() async
  {
    await TokenStorage.setStoredToken(null);
  }

  


}

class UnexpectedException implements Exception {
}

class WrongCredentialsException implements Exception
{

}

class NoNetworkException implements Exception
{
}

