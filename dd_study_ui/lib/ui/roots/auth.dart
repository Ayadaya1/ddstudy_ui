import 'dart:isolate';

import 'package:dd_study_ui/data/services/auth_service.dart';
import 'package:dd_study_ui/ui/roots/app_navigator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;

class _ViewModelState {
  final String? login;
  final String? password;
  final bool isLoading;
  final String? errorText;
  const _ViewModelState({
    this.login,
    this.password,
    this.isLoading = false,
    this.errorText,
  });

  _ViewModelState copyWith({
    String? login,
    String? password,
    bool? isLoading = false,
    String? errorText,
  }) {
    return _ViewModelState(
      login: login ?? this.login,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      errorText: errorText ?? this.errorText,
    );
  }
}


class _ViewModel extends ChangeNotifier
{

  var loginTec = TextEditingController();
  var passwordTec = TextEditingController();
  final _authService = AuthService();
  BuildContext context;
  
  _ViewModel({required this.context})
  {
    loginTec.addListener((){
      state = state.copyWith(login: loginTec.text);
    });
    passwordTec.addListener((){
      state = state.copyWith(password: passwordTec.text);
    });

  }   


  var _state = const _ViewModelState();

  set state (_ViewModelState val)
  {
    _state = _state.copyWith(login: val.login, password: val.password);
    notifyListeners();
  }
  _ViewModelState get state => _state;

  bool checkFields()
  {
    return (state.login?.isNotEmpty??false) && (state.password?.isNotEmpty?? false);
  }

  void login() async
  { 
    _state = _state.copyWith(isLoading: true);
    try
    {
     await _authService.auth(state.login, state.password)
     .then((value){
      AppNavigator.toLoader()
    .then((value) => {state = state.copyWith(isLoading: false)});
    });
    }
    on NoNetworkException
    {
      state = state.copyWith(errorText: "Отсутствует сеть");
    } 
    on WrongCredentialsException
    {
      state = state.copyWith(errorText: "Неверный логин или пароль");
    }
  }
}



class Auth extends StatelessWidget
{
  const Auth ({Key? key}):super(key: key);

  @override 
  Widget build(BuildContext context)
  {
    var viewModel = context.watch<_ViewModel>();

    return Scaffold(body: SafeArea(child: 
    Padding (
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[ 
            TextField(decoration: const InputDecoration(hintText: "Введите логин "), keyboardType: TextInputType.emailAddress, controller: viewModel.loginTec,),
            TextField(decoration: const InputDecoration(hintText: "Введите пароль ",),obscureText: true, controller: viewModel.passwordTec,),
            ElevatedButton(onPressed: viewModel.checkFields()? viewModel.login:null , child: const Text("Войти")),
            if(viewModel.state.isLoading) const CircularProgressIndicator(),
           ],

      )

    ,)
      

  ,),),),);
  }
  
  static Widget create() => ChangeNotifierProvider<_ViewModel>(
    create: (context) => _ViewModel(context: context),
    child: const Auth(),
    );
}