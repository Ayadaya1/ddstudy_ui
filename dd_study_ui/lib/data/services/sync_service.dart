import 'package:dd_study_ui/data/services/data_service.dart';
import 'package:dd_study_ui/domain/repository/api_repository.dart';

import '../../domain/models/post.dart';
import '../../domain/models/post_model.dart';
import '../../internal/dependencies/repository_module.dart';

class SyncService
{
  final ApiRepository _api = RepositoryModule.apiRepository();
  final DataService _dataService = DataService();

  Future syncPosts() async 
  { 
    var postModels = await _api.getPosts(100, 0);
    var authors = postModels.map((e) => e.user).toSet();
    var postContents = postModels.expand((x) => x.attaches.map((e) => e.copyWith(postId: x.id))).toList();
    var posts = postModels.map((e) => Post.fromJson(e.toJson()).copyWith(authorId: e.user.id)).toList(); 

    await _dataService.rangeUpdateEntities(authors);
    await _dataService.rangeUpdateEntities(posts);
    await _dataService.rangeUpdateEntities(postContents);
    }
}