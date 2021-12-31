import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopify1_app/models/http_exeptions.dart';
import 'package:shopify1_app/providers/auth.dart';

class AuthScreen extends StatelessWidget {
  static const routName = '/auth';

  const AuthScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(color: Colors.deepOrange),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 94),
                      child: const Text(
                        'shopify',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: const AuthCard(),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({Key key}) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

enum AuthMode { login, signUp }

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formkey = GlobalKey();
  AuthMode _authMode = AuthMode.login;

  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  AnimationController _controller;
  Animation<Offset> _slidAnimation;
  Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(microseconds: 300),
    );
    _slidAnimation = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future<void> _submit() async {
    if (!_formkey.currentState.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    _formkey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.login) {
        await Provider.of<Auth>(context, listen: false)
            .logIn(_authData['email'], _authData['password']);
      } else {
        await Provider.of<Auth>(context, listen: false)
            .signUp(_authData['email'], _authData['password']);
      }
    } on HttpExeption catch (error) {
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXIST')) {
        errorMessage = 'this email already in use';
      } else if (error.toString().contains('INVAILD_EMAIL')) {
        errorMessage = 'this email ITS VNOT INVALID';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'this password is too weak';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'this email not found';
      } else if (error.toString().contains('INVAILD_PASSWORD')) {
        errorMessage = 'this password is invaild';
      }
      _showErorDialog(errorMessage);
    } catch (error) {
      const errorMessage = 'try again later please';
      _showErorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.login) {
      setState(() {
        _authMode = AuthMode.signUp;
      });
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.login;
      });
      _controller.reverse();
    }
  }

  void _showErorDialog(String errorMessage) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('an error occured'),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('ok'),
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 8.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
        height: _authMode == AuthMode.signUp ? 320 : 260,
        constraints: BoxConstraints(
          minHeight: _authMode == AuthMode.signUp ? 320 : 260,
        ),
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formkey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'E-mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val.isEmpty || !val.contains('@')) {
                      return 'Invaild Email';
                    }
                    return null;
                  },
                  onSaved: (val) {
                    _authData['email'] = val;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (val) {
                    if (val.isEmpty || val.length < 7) {
                      return 'Password too short';
                    }
                    return null;
                  },
                  onSaved: (val) {
                    _authData['password'] = val;
                  },
                ),
                AnimatedContainer(
                  constraints: BoxConstraints(
                    minHeight: _authMode == AuthMode.signUp ? 60 : 0,
                    maxHeight: _authMode == AuthMode.signUp ? 120 : 0,
                  ),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _slidAnimation,
                      child: TextFormField(
                        enabled: _authMode == AuthMode.signUp,
                        decoration: const InputDecoration(
                            labelText: 'Confirm Password'),
                        obscureText: true,
                        validator: _authMode == AuthMode.signUp
                            ? (val) {
                                if (val != _passwordController.text) {
                                  return 'Password do not match';
                                }
                                return null;
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                if (_isLoading) const CircularProgressIndicator(),

                // ignore: deprecated_member_use
                RaisedButton(
                  onPressed: _submit,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                  color: Colors.orangeAccent,
                  textColor: Colors.white,
                  child: Text(
                    _authMode == AuthMode.login ? 'Login' : 'SignUp',
                  ),
                ),
                // ignore: deprecated_member_use
                FlatButton(
                  child: Text(
                      '${_authMode == AuthMode.login ? 'Signup' : 'login'}Instead'),
                  onPressed: _switchAuthMode,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 4),
                  textColor: Colors.deepOrange,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
