// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:taskmanagerr/pages/login_page.dart';
import 'package:taskmanagerr/pages/registar_page.dart';

class LoginOrRegister extends StatefulWidget{
  const LoginOrRegister ({super.key});

  @override
  State<LoginOrRegister> createState() => _loginOrRegisterState(); 
}
class _loginOrRegisterState extends State<LoginOrRegister>{
  // Initially show lgin page
  bool showLoginPage = true;

  //Toogle between login and register pages
  void togglePages(){
    setState(() {
      showLoginPage=!showLoginPage;
    });
  }
  @override
  Widget build(BuildContext context){
    //display the appropriate page base on the value of showlogin page
    return Scaffold(
      appBar: AppBar(title: Text(showLoginPage? 'Loing':'Registar'),
      ),
      body: showLoginPage? LoginPage(onTap:togglePages)
      :RegisterPage(onTap:togglePages)
    );
  }
}