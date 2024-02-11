import 'package:aiko_ben_expense_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:intl/intl.dart';

import '../../services/notification_service.dart';

class NotificationSettings extends StatefulWidget {
  @override
  _NotificationSettingsState createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  bool isDailyReminderOn = false;
  // Use a default time of 9 PM
  TimeOfDay selectedTime = TimeOfDay(hour: 21, minute: 0);

  @override
  Widget build(BuildContext context) {

    String uid = AuthService().currentUser!.uid;
    DocumentReference settingsDoc = FirebaseFirestore.instance.collection('settings').doc(uid);

    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('settings')
            .doc(uid)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            if (data.containsKey('notificationTime')) {
              Timestamp timestamp = data['notificationTime'];
              DateTime dateTime = timestamp.toDate();
              selectedTime = TimeOfDay.fromDateTime(dateTime);
              isDailyReminderOn = true;
            }
          }
          return Scaffold(
            appBar: AppBar(
              title: Text('Notifications'),
              automaticallyImplyLeading: true, // Add a back button
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 48, 0, 0),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.06,
                      decoration: ShapeDecoration(
                        color: Color(0xFFF9F9FC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Center(
                        child: ListTile(
                          title: Text('Daily Reminder'),
                          trailing: Switch(
                            value: isDailyReminderOn,
                            onChanged: (bool value) {
                              // if isDailyReminderOn is false , then we remove the notification time in firebase
                              if (!value) {
                                settingsDoc.update({'notificationTime': FieldValue.delete()});
                              }

                              setState(() {
                                isDailyReminderOn = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    if (isDailyReminderOn)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 48, 0, 0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.15,
                          decoration: ShapeDecoration(
                            color: Color(0xFFF9F9FC),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: TimePickerSpinner(
                            time: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, selectedTime.hour, selectedTime.minute),
                            is24HourMode: false,
                            normalTextStyle:
                                TextStyle(fontSize: 24, color: Colors.grey),
                            highlightedTextStyle:
                                TextStyle(fontSize: 24, color: Colors.black),
                            spacing: 50,
                            itemHeight: 50,
                            isForce2Digits: true,
                            onTimeChange: (time) async {
                              // want to send this time to firebase setting collection
                              // Update the time in the settings document
                              await settingsDoc
                                  .update({'notificationTime': time});

                              // Call the scheduleNotification method
                              await NotificationService().scheduleNotification(
                                title: 'SpendWise Reminder',
                                body: "Don't forget to log your expenses today",
                                scheduleNotificationTimeOfDay: selectedTime,
                              );

                              setState(() {
                                selectedTime = TimeOfDay.fromDateTime(time);
                              }
                              );
                            },
                          ),
                        ),
                      ),

                    // //for debugging the local notfication
                    ElevatedButton(
                      onPressed: () {
                        NotificationService().showNotification(
                          id: 0,
                          title: 'SpendWise Reminder',
                          body: "Don't forget to log your expenses today",
                        );
                      },
                      child: Text('Show Notification'),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}