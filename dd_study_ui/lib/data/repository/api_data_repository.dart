import 'package:dd_study_ui/data/clients/api_client.dart';
import 'package:dd_study_ui/data/clients/auth_client.dart';
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
}