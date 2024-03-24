import 'dart:io';
import 'dart:typed_data';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:wombo_app/AboutUs.dart';
import 'package:wombo_app/Animation.dart';
import 'package:wombo_app/ImageCountPage.dart';
import 'package:wombo_app/SupportUsPage.dart';
import 'firebase_options.dart';
import 'dart:ui';

// var kColorScheme =
//     ColorScheme.fromSeed(seedColor:Color.fromARGB(255, 57, 23, 135));

// var kDarkColorScheme = ColorScheme.fromSeed(
//     brightness: Brightness.dark,
//     seedColor:const Color.fromARGB(255, 5, 99, 125));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  HttpOverrides.global = MyHttpOverrides();

  runApp(
    MaterialApp(
      theme: ThemeData(
        // Your provided ThemeData here
        primaryColor: Color(0xFF6A0DAD), // A shade of purple
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch:
              Colors.blue, // You can choose a different shade of blue
        ).copyWith(
          secondary: Color(0xFF0000FF), // Same shade of blue as secondary
        ), // A shade of blue
        highlightColor: Color(0xFFFF00FF), // Pink
        backgroundColor: Color(0xFF4B0082),
        scaffoldBackgroundColor: Color(0xFF4B0082), // Deep purple
        textTheme: TextTheme(
          headline1: TextStyle(color: Colors.white),
          headline2: TextStyle(color: Colors.white),
          headline3: TextStyle(color: Colors.white),
          headline4: TextStyle(color: Colors.white),
          headline5: TextStyle(color: Colors.white),
          headline6: TextStyle(color: Colors.white),
          subtitle1: TextStyle(color: Colors.white),
          subtitle2: TextStyle(color: Colors.white),
          bodyText1: TextStyle(color: Colors.white),
          bodyText2: TextStyle(color: Colors.white),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Color(0xFFFF00FF), // Pink
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: MyApp(),
    ),
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class Style {
  final int id;
  final String name;

  Style({required this.id, required this.name});

  factory Style.fromJson(Map<String, dynamic> json) {
    return Style(
      id: json['id'],
      name: json['name'],
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onSave;

  FullScreenImage({required this.imageUrl, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6A0DAD),
        foregroundColor: Colors.white,
        title: const Text(
          'Generated Image',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          // child: Center(
          child: Hero(
            tag: 'imageHero',
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height,
              // width: MediaQuery.of(context).size.width,
            ),
          )
          // ),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: onSave,
        child: const Icon(Icons.save),
      ),
    );
  }
}

class MyUser {
  final String uid;
  final String? email; // Add email property

  MyUser({required this.uid, this.email});
}

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  MyUser? _userFromFirebase(User? user) {
    return user != null ? MyUser(uid: user.uid, email: user.email) : null;
  }

  Future<MyUser?> signInAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      return _userFromFirebase(result.user);
    } catch (e) {
      print('Error signing in anonymously: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Stream<MyUser?> get user {
    return _auth.authStateChanges().map((User? user) {
      final myUser = _userFromFirebase(user);
      print('Auth State Changed: $myUser');
      return myUser;
    });
  }
}

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool isSigningup = false;

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: const AlignmentDirectional(
          4.0,
          0.3,
        ),
        children: [
          Image.asset(
            'assets/images/backimg.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SingleChildScrollView(
            //  Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Create an account\n",
                    style: TextStyle(color: Colors.white, fontSize: 40),
                  ),
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.yellowAccent),
                      hintText: 'example@gmail.com',
                      hintStyle: TextStyle(color: Colors.white),
                      prefixIcon: Icon(Icons.email_outlined,
                          color: Colors.yellowAccent),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        borderSide: BorderSide(
                          color: Colors
                              .yellowAccent, // Set the color of the outline when not focused
                          width: 1.0,
                        ),
                      ),
                       errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      enabled: true,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 2.0,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.yellowAccent),
                      prefixIcon: Icon(Icons.vpn_key_outlined,
                          color: Colors.yellowAccent),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        borderSide: BorderSide(
                          color: Colors
                              .yellowAccent, // Set the color of the outline when not focused
                          width: 1.0,
                        ),
                      ),
                       errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      enabled: true,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 2.0,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      labelStyle: TextStyle(color: Colors.yellowAccent),
                      prefixIcon: Icon(Icons.vpn_key_outlined,
                          color: Colors.yellowAccent),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        borderSide: BorderSide(
                          color: Colors
                              .yellowAccent, // Set the color of the outline when not focused
                          width: 1.0,
                        ),
                      ),
                       errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      enabled: true,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 2.0,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isSigningup = true;
                      });
                      String email = _emailController.text.trim();
                      String password = _passwordController.text.trim();
                      String confirmPassword =
                          _confirmPasswordController.text.trim();
                      FocusManager.instance.primaryFocus?.unfocus();

                      if (email.isNotEmpty &&
                          password.isNotEmpty &&
                          confirmPassword.isNotEmpty) {
                        if (password == confirmPassword) {
                          try {
                            await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                              email: email,
                              password: password,
                            );
                            setState(() {
                              isSigningup = false;
                            });
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyHomePage()),
                            );
                          } on FirebaseException catch (e) {
                            setState(() {
                              isSigningup = false;
                            });

                            if (e.code == 'weak-password') {
                              MotionToast.error(
                                position: MotionToastPosition.top,
                                width: MediaQuery.of(context).size.width * 5,
                                dismissable: true,
                                title: Text("Error !"),
                                description:
                                    Text("The password provided is too weak."),
                              ).show(context);
                            } else if (e.code == 'email-already-in-use') {
                              MotionToast.error(
                                position: MotionToastPosition.top,
                                width: MediaQuery.of(context).size.width * 5,
                                dismissable: true,
                                title: Text("Error !"),
                                description: Text(
                                    'The account already exists for that email.'),
                              ).show(context);
                            } else if (e.code == 'user-not-found' ||
                                e.code == 'wrong-password') {
                              MotionToast.error(
                                position: MotionToastPosition.top,
                                width: MediaQuery.of(context).size.width * 5,
                                dismissable: true,
                                title: Text("Error !"),
                                description:
                                    Text("Incorrect email or password."),
                              ).show(context);
                              // Handle user not found or wrong password error
                            } else if (e.code == 'invalid-email') {
                              MotionToast.error(
                                position: MotionToastPosition.top,
                                width: MediaQuery.of(context).size.width * 5,
                                dismissable: true,
                                title: Text("Error !"),
                                description: Text("Invalid email address."),
                              ).show(context);
                            } else {
                              setState(() {
                                isSigningup = false;
                              });
                              MotionToast.error(
                                position: MotionToastPosition.top,
                                width: MediaQuery.of(context).size.width * 5,
                                dismissable: true,
                                title: Text("Error !"),
                                description: Text("An unknown error occurred."),
                              ).show(context);
                              print('Error: ${e.message}');
                              // Handle other errors
                            }
                          }
                        }
                      }
                      if (confirmPassword != password) {
                        setState(() {
                          isSigningup = false;
                        });
                        MotionToast.warning(
                          position: MotionToastPosition.top,
                          width: MediaQuery.of(context).size.width * 5,
                          dismissable: true,
                          title: Text("Error !"),
                          description: Text(
                              "Confirm password and password do not match."),
                        ).show(context);
                      }
                      if (email.isEmpty ||
                          password.isEmpty ||
                          confirmPassword.isEmpty) {
                        setState(() {
                          isSigningup = false;
                        });
                        MotionToast.warning(
                          position: MotionToastPosition.top,
                          width: MediaQuery.of(context).size.width * 5,
                          dismissable: true,
                          title: Text("Error !"),
                          description: Text("Please fill all the fields."),
                        ).show(context);
                      }
                    },
                    child: isSigningup
                        ? SpinKitFadingCircle(
                            color:
                                Colors.blue, // Set the color as per your design
                            size: 50.0, // Set the size of the spinner
                          )
                        : Text('Sign Up'),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.yellowAccent),
                      side: MaterialStateProperty.resolveWith<BorderSide>(
                        (Set<MaterialState> states) {
                          return const BorderSide(
                            color: Colors.yellow, // Outline color
                            width: 2.0,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      // Navigate to the sign-in screen
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Already have an account? Sign In',
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.yellow, // Underline color
                        decorationThickness: 2.0, // Underline thickness
                        // Other text styles if needed
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ),
          ),
        ],
      ),
    );
  }
}

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  double _containerWidth = 0.0;
  double _containerHeight = 0.0;
  double _opacity = 1.0;
  bool _isLoggingIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _containerWidth = MediaQuery.of(context).size.width * 0.6;
    _containerHeight = MediaQuery.of(context).size.height * 0.3;

    return Scaffold(
      body: Stack(
        alignment: const AlignmentDirectional(
          4.0,
          0.3,
        ),
        children: [
          Image.asset(
            'assets/images/backimg.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Welcome to\nImagify.\n",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 40),
                  ),
                  TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.yellowAccent),
                        hintText: 'example@gmail.com',
                        hintStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(Icons.email_outlined,
                            color: Colors.yellowAccent),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                          borderSide: BorderSide(
                            color: Colors
                                .yellowAccent, // Set the color of the outline when not focused
                            width: 1.0,
                          ),
                        ),
                         errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      enabled: true,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2.0,
                            style: BorderStyle.solid,
                          ),
                        ),
                      )
                      ),
                      
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.yellowAccent),
                      prefixIcon: Icon(Icons.vpn_key_outlined,
                          color: Colors.yellowAccent),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        borderSide: BorderSide(
                          color: Colors
                              .yellowAccent, // Set the color of the outline when not focused
                          width: 1.0,
                        ),
                      ),
                       errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      enabled: true,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 2.0,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      String email = _emailController.text.trim();
                      String password = _passwordController.text.trim();
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() {
                        _isLoggingIn = true;
                      });

                      if (email.isNotEmpty && password.isNotEmpty) {
                        try {
                          await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                            email: email,
                            password: password,
                          );
                          setState(() {
                            _isLoggingIn = false;
                          });
                        } on FirebaseException catch (e) {
                          setState(() {
                            _isLoggingIn = false;
                          });
                          if (e.code == 'user-not-found') {
                            MotionToast.error(
                              position: MotionToastPosition.top,
                              width: MediaQuery.of(context).size.width * 5,
                              dismissable: true,
                              title: Text("Error !"),
                              description: Text("User not found."),
                            ).show(context);
                            // Handle user not found error
                          } else if (e.code == 'wrong-password') {
                            MotionToast.error(
                              position: MotionToastPosition.top,
                              width: MediaQuery.of(context).size.width * 5,
                              dismissable: true,
                              title: Text("Error !"),
                              description: Text("Incorrect password."),
                            ).show(context);
                            // Handle wrong password error
                          } else if (e.code == 'invalid-email') {
                            MotionToast.error(
                              position: MotionToastPosition.top,
                              width: MediaQuery.of(context).size.width * 5,
                              dismissable: true,
                              title: Text("Error !"),
                              description: Text("Invalid email address."),
                            ).show(context);
                            // Handle wrong password error
                          } else if (e.code == 'too-many-requests') {
                            MotionToast.error(
                              position: MotionToastPosition.top,
                              width: MediaQuery.of(context).size.width * 5,
                              dismissable: true,
                              title: Text("Error !"),
                              description: Text(
                                  "Too many unsuccessful login attempts. Try again later."),
                            ).show(context);
                            // Handle wrong password error
                          }
                        }
                      } else {
                        _isLoggingIn = false;

                        MotionToast.warning(
                          position: MotionToastPosition.top,
                          width: MediaQuery.of(context).size.width * 5,
                          dismissable: true,
                          title: Text("Warning !"),
                          description: Text("Please fill in all fields."),
                        ).show(context);
                      }
                    },
                    child: _isLoggingIn
                        ? SpinKitFadingCircle(
                            color:
                                Colors.blue, // Set the color as per your design
                            size: 50.0, // Set the size of the spinner
                          )
                        : Text('Sign In'),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.yellowAccent),
                      side: MaterialStateProperty.resolveWith<BorderSide>(
                        (Set<MaterialState> states) {
                          return const BorderSide(
                            color: Colors.yellow, // Outline color
                            width: 2.0,
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signUp');
                    },
                    child: const Text(
                      'New to Imagify?,Create an account',
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.yellow, // Underline color
                        decorationThickness: 2.0, // Underline thickness
                        // Other text styles if needed
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ),
        ],
      ),
    );
  }
}

class SignOutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Out'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await Auth().signOut();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Text('Sign Out'),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    precacheImage(const AssetImage("assets/images/backimg.jpg"), context);
    return MaterialApp(
      home: SplashScreen(), // Use your splash screen as the initial screen
      routes: {
        '/home': (context) =>
            HomeWrapper(), // Use HomeWrapper to handle user authentication
        '/signUp': (context) => SignUpScreen(),
      },
    );
  }
}

class HomeWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MyUser?>(
      stream: Auth().user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return MyHomePage();
          } else {
            return SignInScreen();
          }
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController promptController = TextEditingController();
  final FocusNode promptFocus = FocusNode();
  final String baseUrl = "https://api.luan.tools/api/tasks/";
  final String stylesUrl = "https://api.luan.tools/api/styles/";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String apiKey = '';
  String imageUrl = '';
  String prompt = '';
  bool _isLoading = false;
  List<Style> styles = [];
  Style? selectedStyle;
  String? _userEmail;
  double parallaxValue = 0.0;

  int generatedImageCount = 0;

  @override
  void initState() {
    super.initState();
    loadGeneratedImageCount();
    getApiKeyFromFirebase();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        // User logged in, store the email
        setState(() {
          _userEmail = user.email;
        });
      } else {
        // User logged out, clear the stored email
        setState(() {
          _userEmail = null;
        });
      }
    });
  }

  Future<bool> isConnectedToInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> loadGeneratedImageCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      generatedImageCount = prefs.getInt('generatedImageCount') ?? 0;
    });
  }

  Future<void> incrementGeneratedImageCount() async {
    setState(() {
      generatedImageCount++;
    });

    // Save the updated count to shared preferences
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('generatedImageCount', generatedImageCount);
  }

  Future<void> getApiKeyFromFirebase() async {
    try {
      CollectionReference<Map<String, dynamic>> collection =
          FirebaseFirestore.instance.collection('Dreamtoimg');
      DocumentSnapshot<Map<String, dynamic>> document =
          await collection.doc('api').get();

      if (document.exists) {
        setState(() {
          apiKey = document.data()?['api'] ?? '';
        });

        if (apiKey.isNotEmpty) {
          fetchStyles();
        } else {
          print('Error: API key is empty');
        }
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching API key: $e');
    }
  }

  Future<void> fetchStyles() async {
    try {
      final response = await http.get(Uri.parse(stylesUrl), headers: {
        'Authorization': 'bearer $apiKey',
      });

      if (response.statusCode == 200) {
        final List<dynamic> stylesJson = json.decode(response.body);
        setState(() {
          styles = stylesJson.map((json) => Style.fromJson(json)).toList();
        });
      } else {
        print('Failed to load styles. Error ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> sendTaskToDreamAPI() async {
    // print("fetched api key=$apiKey");
    if (promptController.text.isEmpty ||
        promptController.text == null ||
        selectedStyle == null) {
      MotionToast.warning(
        position: MotionToastPosition.bottom,
        width: MediaQuery.of(context).size.width * 5,
        dismissable: true,
        title: Text("Error !"),
        description: Text("Please enter a prompt and select a style"),
      ).show(context);
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });

      var postResponse = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
            {"use_target_image": false}), // Update based on your requirements
      );
      print(postResponse.body);
      var taskData = jsonDecode(postResponse.body);
      var taskId = taskData['id'];

      var putResponse = await http.put(
        Uri.parse('$baseUrl$taskId'),
        headers: {
          'Authorization': 'bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "input_spec": {
            "style": selectedStyle?.id,
            "prompt": promptController.text,
            "target_image_weight": 0.1,
            "width": 960,
            "height": 1560,
            // Update with your parameters
          },
        }),
      );
      print('PUT Response: ${putResponse.statusCode}');
      print('PUT Response Body: ${putResponse.body}');

      while (true) {
        var getResponse = await http.get(
          Uri.parse('$baseUrl$taskId'),
          headers: {'Authorization': 'bearer $apiKey'},
        );

        var taskStatus = jsonDecode(getResponse.body)['state'];

        if (taskStatus == 'completed') {
          var imageUrl = jsonDecode(getResponse.body)['result'];
          print('Image URL: $imageUrl');

          setState(() {
            this.imageUrl = imageUrl;
            promptController.clear();
            promptFocus.unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
            selectedStyle = null;
            _isLoading = false;
          });
          await incrementGeneratedImageCount();
          break;
        } else if (taskStatus == 'failed') {
          Toast.show('Image generation failed',
              duration: Toast.lengthShort, gravity: Toast.center);
          print('Image generation failed');
          break;
        }

        print('Task status: $taskStatus');
        await Future.delayed(Duration(seconds: 3));
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> saveImage(BuildContext context, Uint8List bytes) async {
    // try {
    //   await ImageGallerySaver.saveImage(bytes);
    //   MotionToast.success(
    //     position: MotionToastPosition.center,
    //     width: MediaQuery.of(context).size.width * 5,
    //     dismissable: true,
    //     title: Text("Success !!"),
    //     description: Text("Image saved to Gallery"),
    //   ).show(context);
    // } catch (e) {
    //   print('Error saving image: $e');
    //   MotionToast.warning(
    //     position: MotionToastPosition.center,
    //     width: MediaQuery.of(context).size.width * 5,
    //     dismissable: true,
    //     title: Text("Error"),
    //     description: Text("Error saving image"),
    //   ).show(context);
    // }
    try {
      await ImageGallerySaver.saveImage(bytes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Image saved to Gallery"),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error saving image: $e');

       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving image"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4B0082),
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xFF6A0DAD),
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Text('Dream to Image '),
          ],
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            // Open the drawer when the menu button is tapped
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            onPressed: () async {
              Auth auth = Auth();
              if (auth.user != null) {
                await auth.signOut();
              } else {
                await auth.signInAnonymously();
              }
            },
            icon: StreamBuilder<MyUser?>(
              stream: Auth().user,
              builder: (context, snapshot) {
                return Icon(
                  snapshot.data != null ? Icons.exit_to_app : Icons.login,
                );
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Color(0xFF4B0082),
        width: MediaQuery.of(context).size.width * 0.6,
        child: StreamBuilder<MyUser?>(
          stream: Auth().user,
          builder: (context, snapshot) {
            final user = snapshot.data;
            return ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  curve: Curves.linear,
                  decoration: BoxDecoration(
                    color: Color(0xFF6A0DAD),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Text(
                          _userEmail!.isNotEmpty == true
                              ? _userEmail![0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                              fontSize: 28, color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 15),
                      if (_userEmail != null)
                        Text(
                          _userEmail!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.image,
                    color: Colors.white,
                  ),
                  title: const Text('Generated Images Count',
                      style: TextStyle(color: Colors.white)),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) =>
                          ImageCountPage(imageCount: generatedImageCount))),
                  // tileColor: Colors.white, // Change the background color
                  // dense: true,
                ),
                const SizedBox(
                  height: 3,
                ),
                const Divider(),
                const SizedBox(
                  height: 10,
                ),
                ListTile(
                  leading:
                      Icon(Icons.health_and_safety_sharp, color: Colors.white),
                  title: const Text('Support Us',
                      style: TextStyle(color: Colors.white)),
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => SupportUsPage())),
                  // tileColor: Colors.white, // Change the background color
                  // dense: true
                ),
                const Divider(),
                const SizedBox(
                  height: 10,
                ),
                ListTile(
                  leading: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                  title: const Text('About Us',
                      style: TextStyle(color: Colors.white)),
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (ctx) => AboutPage())),
                  // tileColor: Colors.white, // Change the background color
                  // dense: true
                ),
                const Divider(),
                const SizedBox(
                  height: 10,
                ),
                ListTile(
                  leading: Icon(Icons.power_settings_new_outlined,
                      color: Colors.white),
                  title: Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    // Sign out logic
                    await Auth().signOut();
                    Navigator.pop(context);
                  },
                  // tileColor: Colors.white, // Change the background color
                  // dense: true
                ),
                const Divider(),
              ],
            );
          },
        ),
      ),
      body: NotificationListener<ScrollUpdateNotification>(
        onNotification: (notification) {
          // Update parallaxValue when the user scrolls
          setState(() {
            parallaxValue = (notification.metrics.pixels / 100).clamp(0.0, 1.0);
          });
          return true;
        },
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(
                  top: 20.0,
                  left: MediaQuery.of(context).size.width * 0.05,
                  right: MediaQuery.of(context).size.width * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Form(
                    child: TextFormField(
                      style: const TextStyle(color: Colors.white),
                      controller: promptController,
                      decoration: const InputDecoration(
                        labelText: 'Prompt',
                        labelStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(
                          Icons.text_fields,
                          color: Colors.white,
                        ),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(10.0),
                        hintText:
                            'A peaceful landscape with mountains and a lake',
                        hintStyle: TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFFFF00FF),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(32.0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(32.0),
                          ),
                        ),
                        errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      enabled: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a prompt';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        setState(() {
                          prompt = value!;
                          // print(prompt);
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  GestureDetector(
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      showStyleDropdown(context);
                    },
                    child: AbsorbPointer(
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.text_fields,
                            color: Colors.white,
                          ),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(1.0),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFFF00FF),
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(32.0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(32.0),
                            ),
                          ),
                        ),
                        isEmpty: selectedStyle == null,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Style>(
                            style: const TextStyle(color: Colors.white),
                            value: selectedStyle,
                            items: styles.map((Style style) {
                              return DropdownMenuItem<Style>(
                                value: style,
                                child: Text(style.name),
                              );
                            }).toList(),
                            onChanged: (Style? newValue) {
                              setState(() {
                                selectedStyle = newValue;
                              });
                            },
                            hint: const Text(
                              'Select Style',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Color(0xFFFF00FF),
                        ),
                        foregroundColor:
                            MaterialStatePropertyAll(Color(0xFF0000FF))),
                    onPressed: () async {
                      await sendTaskToDreamAPI();
                    },
                    child: Text(
                      _isLoading ? 'Generating Image' : 'Generate Image',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _isLoading ? CircularProgressIndicator() : SizedBox(),
                          _isLoading
                              ? SizedBox()
                              : imageUrl.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                FullScreenImage(
                                              imageUrl: imageUrl,
                                              onSave: () async {
                                                final response = await http
                                                    .get(Uri.parse(imageUrl));
                                                final bytes = response.bodyBytes
                                                    as Uint8List;
                                                await saveImage(context, bytes);
                                                ;
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height -
                                                340,
                                        child: PageView(
                                          scrollDirection: Axis.horizontal,
                                          children: [
                                            Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Blurred overlay for a trendy look
                                    )
                                  : Text(
                                      'Image will be displayed here after generation',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 20),
                                    ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showStyleDropdown(BuildContext context) {
    if (styles.isNotEmpty) {
      final RenderBox box = context.findRenderObject() as RenderBox;
      final Offset offset = box.localToGlobal(Offset.zero);

      final screenWidth = MediaQuery.of(context).size.width;
      final centerScreen = screenWidth / 2;

      double xPosition = centerScreen - 100;

      showMenu(
        context: context,
        position:
            RelativeRect.fromLTRB(xPosition, offset.dy, offset.dx, offset.dy),
        items: styles.map((Style style) {
          return PopupMenuItem<Style>(
            value: style,
            child: Text(style.name),
          );
        }).toList(),
      ).then((Style? newValue) {
        if (newValue != null) {
          setState(() {
            selectedStyle = newValue;
          });
        }
      });
    } else {
      MotionToast.error(
        position: MotionToastPosition.bottom,
        width: MediaQuery.of(context).size.width * 5,
        dismissable: true,
        title: Text("Error !"),
        description:
            Text("Internet connection is weak or no Internet connection. Restart the app if you are connected to Internet."),
      ).show(context);
      // Handle the case where styles list is empty
      print('Error: Styles list is empty');
      // You might want to show a message or handle it in some way
    }
  }
}
