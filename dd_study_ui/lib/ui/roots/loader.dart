import 'package:dd_study_ui/data/services/auth_service.dart';
import 'package:dd_study_ui/ui/roots/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _ViewModel extends ChangeNotifier
{
    final _authService = AuthService();

  BuildContext context;
  _ViewModel({required this.context})
  {
    _asyncInit();
  }

  void _asyncInit() async 
  {
    if(await  _authService.checkAuth())
    {

        AppNavigator.toHome();
    }
    else
    {
      AppNavigator.toAuth();
    }
  }
}

class LoaderWidget extends StatelessWidget
{
  const LoaderWidget({Key? key}): super(key: key);
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      
      body: Center(child: const CircularProgressIndicator()),); 
  }

  static Widget create()=>ChangeNotifierProvider<_ViewModel>(create:(context) => _ViewModel(context: context),
  child: const LoaderWidget(),
  lazy: false,
  );
}