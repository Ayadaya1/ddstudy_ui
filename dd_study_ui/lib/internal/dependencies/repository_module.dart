
import 'package:dd_study_ui/data/repository/api_data_repository.dart';
import 'package:dd_study_ui/domain/repository/api_repository.dart';
import 'package:dd_study_ui/internal/dependencies/api_module.dart';

class RepositoryModule
{
  static ApiRepository? _apiRepository;
  
  static ApiRepository apiRepository()
  {
    return _apiRepository ?? ApiDataRepository(ApiModule.auth(), ApiModule.api());
  }
}