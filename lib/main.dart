import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:seddit/firebase_options.dart";
import "package:seddit/pages/HomePage.dart";
import "package:seddit/providers/CommunityProvider.dart";
import "package:seddit/services/CommunityService.dart";
import "package:seddit/services/PostsService.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:seddit/providers/PostsProvider.dart";
import "package:firebase_ui_auth/firebase_ui_auth.dart";
import "package:firebase_auth/firebase_auth.dart" hide EmailAuthProvider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  PostsService service = PostsService();
  PostsProvider provider = PostsProvider(service);

  CommunityService communityService = CommunityService();
  CommunityProvider communityProvider = CommunityProvider(communityService);

  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => provider),
      ChangeNotifierProvider(create: (context) => communityProvider),
    ],
    child: const SedditApp(),),
  );
}

class SedditApp extends StatelessWidget {
  const SedditApp({super.key});

  @override
  Widget build(BuildContext context) {
    final providers = [EmailAuthProvider()];
  
    return MaterialApp(
      title: "Seddit - Change the way you socialize!",
      initialRoute: FirebaseAuth.instance.currentUser != null ? "/" : "/login",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      routes: {
        "/": (context) => Homepage(),
        "/login": (context) {
          return SignInScreen(
            providers: providers,
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) {
                Navigator.pushReplacementNamed(context, "/");
              }),
            ],
          );
        },
        "/profile": (context) {
          return ProfileScreen(
            providers: providers,
            actions: [
              SignedOutAction((context) {
                Navigator.pushReplacementNamed(context, "/login");
              }),
            ],
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                // back button with icon and text
                child: Center(
                  child: Row(
                    // center it
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back),
                      Text("Go Back"),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      },
    );
  }
}
