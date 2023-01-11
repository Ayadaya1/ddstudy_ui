import 'package:dd_study_ui/domain/models/settings_model.dart';
import 'package:dd_study_ui/internal/config/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../internal/dependencies/repository_module.dart';


class _ViewModel extends ChangeNotifier {
  BuildContext context;
  final _api = RepositoryModule.apiRepository();
  _ViewModel({required this.context})
  {
    asyncInit();
  }
  void asyncInit() async
  {
    var settings = await _api.getPrivacySettings();
    posts = settings.postAccess;
    avatar = settings.avatarAccess;
    comments = settings.commentAccess;
    messages = settings.messageAccess;
    notifyListeners();
  }
  int posts = 0;
  int avatar = 0;
  int comments = 0;
  int messages = 0;
  void submit()
  {
    PrivacySettingsModel model = PrivacySettingsModel(avatarAccess: avatar, postAccess: posts, messageAccess: messages, commentAccess: comments);
    _api.changePrivacySettings(model);
  }
  }

class Settings extends StatelessWidget {
  @override
  const Settings({Key? key}):super(key: key);
  Widget build(BuildContext context) {
    final viewModel = Provider.of<_ViewModel>(context);

    return Scaffold(
  appBar: AppBar(title: const Text("Settings")),
  body: SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListTile(
            title: const Text('Кто имеет доступ к моим постам?'),
            trailing: DropdownButton(
              value: viewModel.posts,
              items: [
                const DropdownMenuItem(
                  value: 0,
                  child: const Text('Только подписчики'),
                ),
                const DropdownMenuItem(
                  value: 1,
                  child: const Text('Все'),
                ),
              ],
              onChanged: (value) {
                viewModel.posts = value!;
                viewModel.notifyListeners();
              },
            ),
          ),
          ListTile(
            title: const Text('Кто может видеть мой аватар?'),
            trailing: DropdownButton(
              value: viewModel.avatar,
              items: [
                DropdownMenuItem(
                  value: 0,
                  child: Text('Только подписчики'),
                ),
                DropdownMenuItem(
                  value: 1,
                  child: Text('Все'),
                ),
              ],
              onChanged: (value) {
                viewModel.avatar = value!;
                viewModel.notifyListeners();
              },
            ),
          ),
          ListTile(
            title: const Text('Кто может оставлять комментарии под моими постами?'),
            trailing: DropdownButton(
              value: viewModel.comments,
              items: [
                DropdownMenuItem(
                  value: 0,
                  child: Text('Только подписчики'),
                ),
                DropdownMenuItem(
                  value: 1,
                  child: Text('Все'),
                ),
              ],
              onChanged: (value) {
                viewModel.comments = value!;
                viewModel.notifyListeners();
              },
            ),
          ),
          ListTile(
            title: const Text('Кто может отправлять мне сообщения?'),
            trailing: DropdownButton(
              value: viewModel.messages,
              items: [
                 DropdownMenuItem(
                  value: 0,
                  child: Text('Только подписчики'),
                ),
                DropdownMenuItem(
                  value: 1,
                  child: Text('Все'),
                ),
              ],
              onChanged: (value) {
                viewModel.messages = value!;
                viewModel.notifyListeners();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: OutlinedButton(
              onPressed: () {
                viewModel.submit();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: const Text("Изменения применены!"),
                  duration: const Duration(seconds: 3),),
                );
              },
              child: const Text('Применить настройки'),
            ),
          ),
        ],
      ),
    ),
  ),
);
}

static Widget create()
  {
    return ChangeNotifierProvider(
  create: (context) => _ViewModel(context: context),
  child: const  Settings(),
);
  }
}

