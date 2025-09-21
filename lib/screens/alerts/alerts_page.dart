import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '/services/firestore_service.dart';
import 'package:sih_project/l10n/app_localizations.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  _AlertsPageState createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 2, // We have two tabs: Reports and Announcements
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.allAlerts),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.reports),
              Tab(text: l10n.announcements),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // --- Tab 1: Reports ---
            _buildReportsTab(),
            // --- Tab 2: Announcements ---
            _buildAnnouncementsTab(),
          ],
        ),
      ),
    );
  }

  // Widget for the "Reports" tab
  Widget _buildReportsTab() {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getPredictionsStream(),
      builder: (context, predictionSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: _firestoreService.getClinicReportsStream(),
          builder: (context, clinicSnapshot) {
            if (predictionSnapshot.connectionState == ConnectionState.waiting ||
                clinicSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (predictionSnapshot.hasError || clinicSnapshot.hasError) {
              return Center(child: Text(l10n.failedToLoadAlerts));
            }
            final predictionDocs = predictionSnapshot.data?.docs ?? [];
            final clinicDocs = clinicSnapshot.data?.docs ?? [];
            final allAlerts = _processAndCombineReports(predictionDocs, clinicDocs, l10n);
            if (allAlerts.isEmpty) {
              return Center(
                child: Text(
                  l10n.noAlertsToShow,
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.all(8.0),
              children: allAlerts.map((alert) {
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: ExpansionTile(
                    leading: Icon(alert['icon'], color: alert['color'], size: 30),
                    title: Text(alert['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(alert['subtitle']),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: (alert['details'] as Map<String, dynamic>).entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_formatDetailKey(entry.key), style: TextStyle(color: Colors.grey.shade600)),
                                  Text(entry.value.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  // Widget for the "Announcements" tab
  Widget _buildAnnouncementsTab() {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getAnnouncementsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(l10n.failedToLoadAlerts));
        }
        final announcements = snapshot.data?.docs ?? [];
        if (announcements.isEmpty) {
          return Center(
            child: Text(
              l10n.noAlertsToShow,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: announcements.length,
          itemBuilder: (context, index) {
            final data = announcements[index].data() as Map<String, dynamic>;
            final message = data['message'] ?? 'No message content.';
            final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
            final formattedDate = timestamp != null
                ? DateFormat('dd MMM yyyy, hh:mm a').format(timestamp)
                : l10n.justNow;

            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: ListTile(
                leading: const Icon(Icons.campaign, color: Colors.deepPurpleAccent),
                title: Text(message),
                subtitle: Text(formattedDate),
              ),
            );
          },
        );
      },
    );
  }


  String _formatDetailKey(String key) {
    return key.replaceAll('_', ' ').split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  List<Map<String, dynamic>> _processAndCombineReports(
    List<QueryDocumentSnapshot> predictions,
    List<QueryDocumentSnapshot> clinics,
    AppLocalizations l10n,
  ) {
    List<Map<String, dynamic>> combinedList = [];
    for (var doc in predictions) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
      final risk = data['predictedClass'] ?? 'Unknown';
      final location = data['location'] ?? 'N/A';
      final details = Map<String, dynamic>.from(data);
      details.remove('predictedClass');
      details.remove('location');
      details.remove('timestamp');
      combinedList.add({
        'timestamp': timestamp ?? DateTime.now(),
        'title': '${l10n.waterQualityRisk}: $risk',
        'subtitle': '$location ${l10n.on} ${timestamp != null ? DateFormat('dd MMM yyyy').format(timestamp) : l10n.noDate}',
        'icon': Icons.water_drop_outlined,
        'color': risk == 'High' ? Colors.red : risk == 'Medium' ? Colors.orange : Colors.green,
        'details': details,
      });
    }

    for (var doc in clinics) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
      final disease = data['disease_type'] ?? 'Unknown';
      final count = data['patient_count'] ?? 0;
      final location = data['location'] ?? 'N/A';
      final details = Map<String, dynamic>.from(data);
       details.remove('timestamp');
      combinedList.add({
        'timestamp': timestamp ?? DateTime.now(),
        'title': '${l10n.clinicReport}: $count ${l10n.patientsWith} $disease',
        'subtitle': '$location ${l10n.on} ${timestamp != null ? DateFormat('dd MMM yyyy').format(timestamp) : l10n.noDate}',
        'icon': Icons.local_hospital_outlined,
        'color': Colors.blue.shade700,
        'details': details,
      });
    }

    combinedList.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    return combinedList;
  }
}
