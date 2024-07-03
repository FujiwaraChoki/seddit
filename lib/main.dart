import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:seddit/pages/HomePage.dart";
import "package:get_storage/get_storage.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:seddit/providers/PostsProvider.dart";
import "package:seddit/services/PostsService.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await GetStorage.init();

  PostsService service = PostsService();

  PostsProvider provider = PostsProvider(service);

  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => provider),
    ],
    child: const SedditApp(),),
  );
}

class SedditApp extends StatelessWidget {
  const SedditApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Demo",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: Homepage(),
    );
  }
}
