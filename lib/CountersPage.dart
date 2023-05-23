import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CountersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compteurs'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Une erreur s\'est produite'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('Aucune donnée disponible'),
            );
          }

          final tasks = snapshot.data!.docs;
          int publicDataCount = 0;
          int privateDataCount = 0;
          int expiredTaskCount = 0;
          int ongoingTaskCount = 0;
          int notOngoingTaskCount = 0;
          DateTime now = DateTime.now();

          for (var task in tasks) {
            DateTime taskDateTime = (task['date'] as Timestamp).toDate();
            bool isPublic = task['isPublic'] ?? false;

            if (isPublic) {
              publicDataCount++;
            } else {
              privateDataCount++;
            }

            if (taskDateTime.isBefore(now)) {
              expiredTaskCount++;
            } else {
              TimeOfDay taskTime = TimeOfDay.fromDateTime(taskDateTime);
              TimeOfDay nowTime = TimeOfDay.fromDateTime(now);

              if (taskTime.hour <= nowTime.hour && taskTime.minute <= nowTime.minute) {
                ongoingTaskCount++;
              } else {
                notOngoingTaskCount++;
              }
            }
          }

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nombre de données publiques saisies: $publicDataCount',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Nombre de données privées saisies: $privateDataCount',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Nombre de tâches échues: $expiredTaskCount',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Nombre de tâches en cours: $ongoingTaskCount',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Nombre de tâches qui ne sont pas en cours: $notOngoingTaskCount',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
