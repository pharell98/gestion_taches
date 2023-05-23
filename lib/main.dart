import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:Groupe_10/ui/Auth/login_page.dart';
import 'package:Groupe_10/theme.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'model_theme.dart';

// Fonction asynchrone principale pour démarrer l'application
Future<void> main() async {
  // Assurez-vous que Flutter est initialisé
  WidgetsFlutterBinding.ensureInitialized();
  // Initialise Firebase
  await Firebase.initializeApp();
  // Initialise GetStorage pour la gestion du stockage local
  await Get.putAsync(() => GetStorage.init());
  // Obtient le jeton FCM (Firebase Cloud Messaging)
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print(fcmToken);
  // Configure Firebase Messaging pour gérer les messages en arrière-plan
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // Lance l'application Flutter
  runApp(const MyApp());
}

// Fonction pour gérer les messages Firebase en arrière-plan
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

// Classe principale de l'application Flutter
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Configure Firebase Messaging
    configureFirebaseMessaging();
    return ChangeNotifierProvider(
      create: (_) => ModelTheme(),
      child: Consumer<ModelTheme>(
        builder: (context, ModelTheme themeNotifier, child) {
          return GetMaterialApp(
            title: 'Flutter Demo',
            theme: themeNotifier.isDark
                ? ThemeData(
              brightness: Brightness.dark,
            )
                : ThemeData(
                brightness: Brightness.light,
                primaryColor: Colors.green,
                primarySwatch: Colors.green),
            debugShowCheckedModeBanner: false,
            home: FutureBuilder(
              // Attend la fin de l'initialisation de Firebase
              future: Firebase.initializeApp(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Affiche un écran de chargement pendant l'initialisation
                  return Scaffold(
                    backgroundColor: Colors.white,
                    body: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                      ),
                    ),
                  );
                } else {
                  // Navigue vers l'écran de connexion une fois l'initialisation terminée
                  return SignInScreen();
                }
              },
            ),
          );
        },
      ),
    );
  }
}

// Fonction pour configurer Firebase Messaging
void configureFirebaseMessaging() {
  // Écoute les messages Firebase reçus lorsque l'application est en premier plan
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received message: ${message.notification?.title}');
    // Traitez le message reçu ici selon vos besoins
  });

  // Écoute les messages Firebase reçus lorsque l'application est ouverte à partir de la notification
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Opened app from notification: ${message.notification?.title}');
    // Traitez l'ouverture de l'application à partir de la notification ici selon vos besoins
  });
}
