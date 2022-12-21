
import 'package:dd_study_ui/data/services/auth_service.dart';
import 'package:dd_study_ui/ui/roots/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _ViewModelState {
  final String? name;
  final String? email;
  final String? password;
  final String? retryPassword;
  final String? birthDate;
  final bool isLoading;
  final String? errorText;
  const _ViewModelState({
     this.name,
     this.email,
     this.password,
     this.retryPassword,
     this.birthDate,
    this.isLoading = false,
    this.errorText,
  });

  _ViewModelState copyWith({
    String? name,
    String? email,
    String? birthDate,
    String? retryPassword,
    String? password,
    bool? isLoading = false,
    String? errorText,
  }) {
    return _ViewModelState(
      name: name ?? this.name,
      email:email??this.email,
      password: password ?? this.password,
      retryPassword: retryPassword??this.retryPassword,
      birthDate: birthDate?? this.birthDate,
      isLoading: isLoading ?? this.isLoading,
      errorText: errorText ?? this.errorText,
    );
  }
}


class _ViewModel extends ChangeNotifier
{

  var nameTec = TextEditingController();
  var passwordTec = TextEditingController();
  var retryPasswordTec = TextEditingController();
  var birthDateTec = TextEditingController();
  var emailTec = TextEditingController();
  final _authService = AuthService();
  BuildContext context;
  
  _ViewModel({required this.context})
  {
    nameTec.addListener((){
      state = state.copyWith(name: nameTec.text);
    });
    passwordTec.addListener((){
      state = state.copyWith(password: passwordTec.text);
    });
    retryPasswordTec.addListener((){
      state = state.copyWith(retryPassword: retryPasswordTec.text);
    });
    birthDateTec.addListener((){
      state = state.copyWith(birthDate: birthDateTec.text);
    });
    emailTec.addListener((){
      state = state.copyWith(email: emailTec.text);
    });

  }   


  var _state = const _ViewModelState();

  set state (_ViewModelState val)
  {
    _state = _state.copyWith(name: val.name, password: val.password, retryPassword: val.retryPassword, birthDate: val.birthDate, email: val.email);
    notifyListeners();
  }
  _ViewModelState get state => _state;

  bool checkFields()
  {
    return (state.name?.isNotEmpty??false) && (state.password?.isNotEmpty?? false )&& (state.retryPassword?.isNotEmpty?? false )&& (state.birthDate?.isNotEmpty?? false )&& (state.email?.isNotEmpty?? false );
  }

  void register() async
  { 
    _state = _state.copyWith(isLoading: true);

     await _authService.register(state.email, state.name, state.password, state.retryPassword, state.birthDate)
     .then((value) =>  _authService.auth(state.email, state.password))
     .then((value) => AppNavigator.toHome());

  }
}



class Registration extends StatelessWidget
{
  const Registration ({Key? key}):super(key: key);

  @override 
  Widget build(BuildContext context)
  {
    var viewModel = context.watch<_ViewModel>();

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(child: 
    Padding (
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[ 
            TextField(decoration: const InputDecoration(hintText: "E-mail "), keyboardType: TextInputType.emailAddress, controller: viewModel.emailTec,),
            TextField(decoration: const InputDecoration(hintText: "Имя ",), controller: viewModel.nameTec,),
            TextField(decoration: const InputDecoration(hintText: "Пароль ",),obscureText: true, controller: viewModel.passwordTec,),
            TextField(decoration: const InputDecoration(hintText: "Повторите пароль ",), obscureText: true, controller: viewModel.retryPasswordTec,),
            TextField(decoration: const InputDecoration(hintText: "Дата рождения ",), controller: viewModel.birthDateTec,),
            ElevatedButton(onPressed: viewModel.checkFields()? viewModel.register:null , child: const Text("Зарегистрироваться")),
            if(viewModel.state.isLoading) const CircularProgressIndicator(),
           ],

      )

    ,)
      

  ,),),),);
  }
  
  static Widget create() => ChangeNotifierProvider<_ViewModel>(
    create: (context) => _ViewModel(context: context),
    child: const Registration(),
    );
}