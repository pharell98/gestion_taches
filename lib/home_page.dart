import 'package:Groupe_10/ui/Auth/services/firebase_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Groupe_10/theme.dart';
import 'package:Groupe_10/ui/Auth/login_page.dart';
import 'package:Groupe_10/widgets/button.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import 'add_task_bar.dart';
import 'model_theme.dart';

// Création d'un StatefulWidget
class HomePage extends StatefulWidget {
  final bool isGoogleSignIn;

  const HomePage({Key? key, required this.isGoogleSignIn}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();

  // Accéder à Firestore
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Consumer<ModelTheme>(
        builder: (context, ModelTheme themeNotifier, child) {
          User? currentUser = FirebaseAuth.instance.currentUser;

          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false, // Supprimer l'icône de retour en arrière
              title: Text(currentUser?.displayName ?? 'Utilisateur'),
              actions: [
                IconButton(
                  icon: Icon(
                    themeNotifier.isDark ? Icons.nightlight_round : Icons.wb_sunny,
                  ),
                  onPressed: () {
                    themeNotifier.isDark = !themeNotifier.isDark;
                  },
                ),
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () async {
                    if (widget.isGoogleSignIn) {
                      await FirebaseServices().signOut();
                    } else {
                      await FirebaseAuth.instance.signOut();
                    }
                    print("Déconnecté");
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignInScreen()),
                    );
                  },
                ),
              ],
            ),
        body: Column(
          children: [
            // fonction bar Ajout et date actuel
            _addTaskBar(),
            // fonction qui permet d'afficher
            _addDateBar(),
            // Ajout de la liste des tâches
            _buildTaskList(),
          ],
        ),
      );
    });
  }

  // Afficher la barre des tâches et la date actuelle
  _addTaskBar() {
    return Container(
        margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat.yMMMMd().format(DateTime.now()),
                    style: subHeadingStyle,
                  ),
                  Text(
                    "Aujourd'hui",
                    style: HeadingStyle,
                  )
                ],
              ),
            ),
            // Bouton pour ajouter une tâche
            MyButton(label: "+ Ajout tâche", onTap: () => Get.to(AddTaskPage()))
          ],
        ));
  }

  // Afficher la barre de date
  _addDateBar() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 10),
      child: DatePicker(
        DateTime.now(),
        height: 100,
        width: 80,
        initialSelectedDate: DateTime.now(),
        selectionColor: Colors.blue,
        selectedTextColor: Colors.white,
        dateTextStyle: GoogleFonts.lato(
            textStyle: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey)),
        dayTextStyle: GoogleFonts.lato(
            textStyle: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
        monthTextStyle: GoogleFonts.lato(
            textStyle: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
        onDateChange: (date) {
          // Mise à jour de la date sélectionnée
          _selectedDate = date;
        },
      ),
    );
  }

  // Construire la liste des tâches
  Widget _buildTaskList() {
    List<Color> colors = [
      Colors.teal,
      Colors.pink,
      Colors.amber
    ]; // Liste des couleurs disponibles

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Text('No user is signed in');
    }
    String userId = user.uid;

    // Obtenir les streams des tâches privées de l'utilisateur et des tâches publiques
    Stream<QuerySnapshot> privateTasksStream = firestore
        .collection('tasks')
        .where('createdBy', isEqualTo: userId)
        .where('isPublic', isEqualTo: false)
        .snapshots();

    Stream<QuerySnapshot> publicTasksStream = firestore
        .collection('tasks')
        .where('isPublic', isEqualTo: true)
        .snapshots();

    // Combinez les deux streams en un seul stream
    Stream<List<QuerySnapshot>> combinedStream =
        CombineLatestStream.list<QuerySnapshot>([
      privateTasksStream,
      publicTasksStream,
    ]);

    // Utiliser StreamBuilder pour afficher les tâches en temps réel
    return StreamBuilder<List<QuerySnapshot>>(
      stream: combinedStream,
      builder:
          (BuildContext context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        List<QueryDocumentSnapshot> tasks = snapshot.data!
            .expand((querySnapshot) => querySnapshot.docs)
            .toList();

        // Créer une liste de tâches à partir des données récupérées
        return Expanded(
          child: ListView(
            children: tasks.map((document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return Container(
                width: double.infinity,
                color: colors[data['couleur']],
                child: ListTile(
                  title: Text(data['titre']),
                  subtitle: Text(data['description']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Get.to(AddTaskPage(taskId: document.id));
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          firestore
                              .collection('tasks')
                              .doc(document.id)
                              .delete();
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
