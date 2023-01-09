import 'dart:io';

import 'package:dd_study_ui/domain/models/attach_meta.dart';
import 'package:dd_study_ui/internal/dependencies/repository_module.dart';
import 'package:dd_study_ui/ui/common/cam_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/services/auth_service.dart';
import '../../domain/models/user.dart';
import '../../internal/config/app_config.dart';
import '../../internal/config/shared_prefs.dart';
import '../../internal/config/token_secure_storage.dart';
import '../roots/app_navigator.dart';


class _ViewModelState {
  final String? text;

  const _ViewModelState(
    {
      this.text,
    }
  );

  _ViewModelState copyWith({
    String? text,
    List<AttachMeta>? meta,
  })
  {
    return _ViewModelState(
      text:text??this.text,
    );
  }
  
}
class _ViewModel  extends ChangeNotifier {
  BuildContext context;
  final _api = RepositoryModule.apiRepository();
    var textTec = TextEditingController();
    List<AttachMeta> files;

  var _state = const _ViewModelState();
  set state (_ViewModelState val)
  {
    _state = _state.copyWith(text: val.text);
    notifyListeners();
  }
  _ViewModel({required this.context, required this.files})
  {
    textTec.addListener((){
      _state = _state.copyWith(text: textTec.text);
    });
    asyncInit();
  }

  Map<int,int> pager = <int,int>{};

  Map<String, String>? headers;

  void omPageChanged(int ListIndex, int pageIndex)
  {
    pager[ListIndex] = pageIndex;
    notifyListeners();
  }
  User? _user;

  User? get user => _user;
  set user(User? val)
  {
    _user = val;
    notifyListeners();
  }


  void asyncInit() async
  {
    files = <AttachMeta>[];
    var token = await TokenStorage.getAccessToken();
    headers = {"Authorization": "Bearer $token"};
    user = await SharedPrefs.getStoredUser();
    var img = await NetworkAssetBundle(Uri.parse("$baseUrl${user!.avatar}")).load("$baseUrl${user!.avatar}");
      avatar =  Image.memory(img.buffer.asUint8List());
    
  }
  
  void addPost() async
  {
    var text = textTec.text;
    try
    {
    await _api.addPost(text!=null?text:"", files).then((value) => Navigator.of(context).pop());
    }
    catch(e)
    {
      print(e.toString());
    }
  }

  String? _imagePath;
  String? get imagePath => _imagePath;
  set imagePath(String? val)
  {
    _imagePath = val;
    notifyListeners();
  }
  Image? _avatar;
  Image? get avatar => _avatar;
  set avatar(Image? val)
  {
    _avatar = val;
    notifyListeners();
  }

  Future addPhoto() async
  {
    await Navigator.of(context).push(MaterialPageRoute(builder: (newContext)=>
    Scaffold(backgroundColor: Colors.black, appBar: AppBar(backgroundColor: Colors.black,),body:SafeArea(child: CamWidget(onFile: (file)
    {
      imagePath = file.path;
      Navigator.of(newContext).pop();
    }),))));
    if(_imagePath!=null)
    {
    avatar = null;
    var t = await _api.uploadTemp(files: [File(imagePath!)]);
    if(t.isNotEmpty)
    {
      files.add(t.first);
      notifyListeners();
    }
    }
  }
  
}

class AddPost extends StatelessWidget {
  const AddPost({Key? key}):super(key:key);
  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<_ViewModel>();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        
        onPressed: viewModel.addPhoto,
        child:const Icon(Icons.add_a_photo)),
      appBar: AppBar(title:  
      
            const Text("Создание поста"),
            
            ),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                      TextField(decoration: const InputDecoration(hintText: "Текст поста"),controller: viewModel.textTec,),
                      Expanded(child:
                PageView.builder(
              itemCount: viewModel.files.length, itemBuilder: ( pageContext, pageIndex)=>Container
            (color:Colors.yellow ,
            child: Center(child: Text(viewModel.files[pageIndex].name))))),
            ElevatedButton(onPressed: () {viewModel.addPost();}, child: const Text("Добавить пост"))
                    ],
                  ),
              ),
            );


  }

  static Widget create()
  {
    return ChangeNotifierProvider(create: (BuildContext context) => _ViewModel(context: context, files: []), child: const AddPost(),);
  }
}