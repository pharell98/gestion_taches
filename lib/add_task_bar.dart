// Importation des paquets nécessaires
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Groupe_10/theme.dart';
import 'package:Groupe_10/widgets/button.dart';
import 'package:Groupe_10/widgets/input_field.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'home_page.dart';

// Création de la page d'ajout de tâche
class AddTaskPage extends StatefulWidget {
  final String? taskId;

  const AddTaskPage({Key? key, this.taskId}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  // ajouter cette ligne pour suivre si la tâche est publique ou non
  bool _isPublic = false;

  // Initialisation des contrôleurs de texte
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Initialisation des variables pour la gestion des dates et des heures
  DateTime _selectedDate = DateTime.now();
  String _dateFin = "12:00 H";
  String _dateDebut = DateFormat("hh:mm a").format(DateTime.now()).toString();

  // Initialisation des variables pour la gestion de la couleur et du mode d'édition
  int _selectedColor = 0;
  bool _isEditing = false;

  // Accès à la base de données Firestore
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Chargement des données de la tâche si une taskId est fournie
    if (widget.taskId != null) {
      _loadTaskData();
    }
  }

  // Fonction pour charger les données de la tâche à partir de Firestore
  void _loadTaskData() async {
    if (widget.taskId != null) {
      DocumentSnapshot taskSnapshot =
          await firestore.collection('tasks').doc(widget.taskId).get();
      Map<String, dynamic> taskData =
          taskSnapshot.data() as Map<String, dynamic>;
      setState(() {
        // Mise à jour des contrôleurs de texte et des autres variables avec les données de la tâche
        _titreController.text = taskData['titre'];
        _descriptionController.text = taskData['description'];
        _selectedDate = (taskData['date'] as Timestamp).toDate();
        _dateDebut = taskData['dateDebut'];
        _dateFin = taskData['dateFin'];
        _selectedColor = taskData['couleur'];
        _isPublic = taskData['isPublic'] ?? false; // Charger la valeur de 'isPublic' ici
        _isEditing = true;
      });
    }
  }

  // Fonction pour construire l'interface utilisateur
  @override
  Widget build(BuildContext context) {
    // Définition de la structure de base de la page
    return Scaffold(
      appBar: _appBar(),
      body: Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ajout tâche",
                style: HeadingStyle,
              ),
              MyInputField(
                title: "Titre",
                hint: "Saisir le titre",
                controller: _titreController,
              ),
              MyInputField(
                title: "Description",
                hint: "Saisir la description",
                controller: _descriptionController,
              ),
              MyInputField(
                title: "Date",
                hint: DateFormat.yMd().format(_selectedDate),
                widget: IconButton(
                  icon: Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    print("bonjour");
                    _getDateFromUser();
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                      child: MyInputField(
                    title: "Date Début",
                    hint: _dateDebut,
                    widget: IconButton(
                      onPressed: () {
                        _getTimeFromUser(isStartTime: true);
                      },
                      icon: Icon(
                        Icons.access_time_rounded,
                        color: Colors.grey,
                      ),
                    ),
                  )),
                  SizedBox(
                    width: 12,
                  ),
                  Expanded(
                      child: MyInputField(
                    title: "Date Fin",
                    hint: _dateFin,
                    widget: IconButton(
                      onPressed: () {
                        _getTimeFromUser(isStartTime: false);
                      },
                      icon: Icon(
                        Icons.access_time_rounded,
                        color: Colors.grey,
                      ),
                    ),
                  ))
                ],
              ),

              //Pour les couleurs
              SizedBox(
                height: 18,
              ),
          Row(
            children: [
              Text("Public"),
              Switch(
                value: _isPublic,
                onChanged: (value) {
                  setState(() {
                    _isPublic = value;
                  });
                },
              ),
            ],
          ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _colorPalette(),
                  MyButton(
                      label: _isEditing ? "Modifier Tâche" : "Créer Tâche",
                      onTap: () => _validation()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

// Fonction pour valider les données de la tâche et les envoyer à Firestore
  _validation() {
    // Vérification que tous les champs ont été remplis
    if (_titreController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty) {
      // Accéder à la collection 'tasks' de Firestore
      CollectionReference tasks = firestore.collection('tasks');
      // Obtenir l'ID de l'utilisateur actuellement connecté
      String userId = FirebaseAuth.instance.currentUser!.uid;
      if (_isEditing) {
        // Si on est en mode édition, mettre à jour la tâche existante
        tasks.doc(widget.taskId).update({
          'titre': _titreController.text,
          'description': _descriptionController.text,
          'date': Timestamp.fromDate(_selectedDate),
          'dateDebut': _dateDebut,
          'dateFin': _dateFin,
          'couleur': _selectedColor,
          'createdBy': userId, // Ajouter l'ID de l'utilisateur qui met à jour la tâche
        }).then((value) {
          print("Task Updated");
          Get.back();
        }).catchError((error) {
          print("Failed to update task: $error");
        });
      } else {
        // Si on n'est pas en mode édition, ajouter une nouvelle tâche
        tasks.add({
          'titre': _titreController.text,
          'description': _descriptionController.text,
          'date': Timestamp.fromDate(_selectedDate),
          'dateDebut': _dateDebut,
          'dateFin': _dateFin,
          'couleur': _selectedColor,
          'isPublic': _isPublic, // ajouter cette ligne pour enregistrer si la tâche est publique ou non
          'createdBy': userId, // Ajouter l'ID de l'utilisateur qui crée la tâche
        }).then((value) {
          print("Task Added");
          Get.back();
        }).catchError((error) {
          print("Failed to add task: $error");
        });
      }
    } else if (_titreController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      // Si tous les champs n'ont pas été remplis, afficher une alerte à l'utilisateur
      Get.snackbar("Alert", "Tous les champs sont obligatoires",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.deepOrangeAccent,
          icon: Icon(Icons.warning_amber_rounded, color: Colors.red));
    }
  }

  // Fonction pour afficher la palette de couleurs
  _colorPalette() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Texte 'Couleur'
        Text("Couleur", style: titleStyle),
        SizedBox(
          height: 8.0,
        ),
        // Génération de la liste des couleurs disponibles
        Wrap(
          children: List<Widget>.generate(3, (int index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  // Mise à jour de la couleur sélectionnée
                  _selectedColor = index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 7.0),
                child: CircleAvatar(
                  radius: 14,
                  // Affichage de la couleur
                  backgroundColor: index == 0
                      ? Colors.teal
                      : index == 1
                          ? Colors.pink
                          : Colors.amber,
                  child: _selectedColor == index
                      ? Icon(Icons.done, color: Colors.white, size: 16)
                      : Container(),
                ),
              ),
            );
          }),
        )
      ],
    );
  }

  // Fonction pour créer la barre d'application
  _appBar() {
    return AppBar(
      leading: GestureDetector(
        onTap: () {
          // Navigation vers la page d'accueil lorsque l'utilisateur clique sur le bouton retour
          Get.to(HomePage(isGoogleSignIn: true,));
        },
        child: Icon(
          Icons.arrow_back_ios,
          size: 20,
        ),
      ),
      actions: [
        Icon(
          Icons.person,
          size: 20,
        ),
      ],
    );
  }

  // Fonction pour obtenir la date de l'utilisateur
  _getDateFromUser() async {
    DateTime? _pickerDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015),
        lastDate: DateTime(2123));
    if (_pickerDate != null) {
      setState(() {
        // Mise à jour de la date sélectionnée
        _selectedDate = _pickerDate;
      });
    } else {
      print("");
    }
  }

  // Fonction pour obtenir l'heure de l'utilisateur
  _getTimeFromUser({required bool isStartTime}) async {
    var pickedTime = await _showtimePicker();
    String _formatedTime = pickedTime.format(context);
    if (pickedTime == null) {
      print("time canceled");
    } else if (isStartTime == true) {
      setState(() {
        // Mise à jour de l'heure de début
        _dateDebut = _formatedTime;
      });
    } else if (isStartTime == false) {
      setState(() {
        // Mise à jour de l'heure de fin
        _dateFin = _formatedTime;
      });
    }
  }

  // Fonction pour afficher le sélecteur d'heure
  _showtimePicker() {
    return showTimePicker(
        initialEntryMode: TimePickerEntryMode.input,
        context: context,
        initialTime: TimeOfDay(
          hour: int.parse(_dateDebut.split(":")[0]),
          minute: int.parse(_dateDebut.split(":")[1].split("")[0]),
        ));
  }
} // Fin de la classe _AddTaskPageState
