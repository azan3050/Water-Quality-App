import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:async/async.dart';
import 'package:url_launcher/url_launcher.dart'; // --- NEW: Import for launching URLs ---
import '../role_selection_page.dart';
import 'package:sih_project/l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

enum TimeFilter { last7Days, last30Days, allTime }

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  TimeFilter _selectedFilter = TimeFilter.last7Days;

  Duration? _getDurationForFilter() {
    switch (_selectedFilter) {
      case TimeFilter.last7Days:
        return const Duration(days: 7);
      case TimeFilter.last30Days:
        return const Duration(days: 30);
      case TimeFilter.allTime:
        return null;
    }
  }

  // --- NEW: Method to launch the URL ---
  Future<void> _launchURL() async {
    final Uri url = Uri.parse("https://sih-project-ba4a6.web.app"); // Replace with your link
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Show an error message if the URL can't be launched
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  // Method to show the post announcement dialog
  void _showPostAnnouncementDialog() {
    final TextEditingController controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.postAnAnnouncement),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(),
            maxLines: 4,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text(l10n.post),
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  await _firestoreService.saveAnnouncement(controller.text);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.announcementPosted)),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filterDuration = _getDurationForFilter();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminDashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showPostAnnouncementDialog,
        tooltip: l10n.postAnAnnouncement,
        child: const Icon(Icons.campaign_outlined),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterDropdown(),
            const SizedBox(height: 16),
            StreamBuilder<List<QuerySnapshot>>(
              stream: StreamZip([
                _firestoreService.getPredictionsStream(within: filterDuration),
                _firestoreService.getClinicReportsStream(within: filterDuration),
              ]),
              builder: (context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ));
                }
                if (!snapshot.hasData) {
                   return Card(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(l10n.noDataAvailable,
                          
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }
                final predictions = snapshot.data![0].docs;
                final reports = snapshot.data![1].docs;

                if (predictions.isEmpty && reports.isEmpty) {
                   return Card(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(l10n.noDataAvailable,
                          
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRiskHotspotsSection(predictions, reports),
                    const SizedBox(height: 24),
                    _buildKpiSection(predictions),
                    const SizedBox(height: 24),
                    _buildPieChartSection(predictions),
                    const SizedBox(height: 24),
                    _buildRecentPredictionsSection(predictions),
                    const SizedBox(height: 24),
                    const Divider(thickness: 2),
                    const SizedBox(height: 24),
                    _buildDiseaseBarChartSection(reports),
                    const SizedBox(height: 24),
                    _buildRecentClinicReportsSection(reports),
                    const SizedBox(height: 24),
                    const Divider(thickness: 2),
                    // --- NEW: Button to launch the URL ---
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.open_in_browser),
                        onPressed: _launchURL,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                        ),
                        label: Text(l10n.viewFullReport),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TimeFilter>(
          value: _selectedFilter,
          isExpanded: true,
          items: [
            DropdownMenuItem(
              value: TimeFilter.last7Days,
              child: Text(l10n.last7Days),
            ),
            DropdownMenuItem(
              value: TimeFilter.last30Days,
              child: Text(l10n.last30Days),
            ),
            DropdownMenuItem(
              value: TimeFilter.allTime,
              child: Text(l10n.allTime),
            ),
          ],
          onChanged: (TimeFilter? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedFilter = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildRiskHotspotsSection(
      List<QueryDocumentSnapshot> predictions, List<QueryDocumentSnapshot> reports) {
    final l10n = AppLocalizations.of(context)!;
    final Map<String, int> dangerScores = {};
    for (var doc in predictions) {
      final data = doc.data() as Map<String, dynamic>;
      final location = data['location'] as String?;
      final risk = data['predictedClass'] as String?;
      if (location != null && risk != null) {
        int score = (risk == 'High' ? 3 : (risk == 'Medium' ? 2 : 1));
        dangerScores[location] = (dangerScores[location] ?? 0) + score;
      }
    }
    for (var doc in reports) {
      final data = doc.data() as Map<String, dynamic>;
      final location = data['location'] as String?;
      if (location != null) {
        dangerScores[location] = (dangerScores[location] ?? 0) + 5;
      }
    }
    if (dangerScores.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.riskHotspots,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8.0, 
          runSpacing: 8.0,
          children: dangerScores.entries.map((entry) {
            final location = entry.key;
            final score = entry.value;
            final color = _getDangerColor(score);
            return Card(
              color: color,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Text(
                  location,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getDangerColor(int score) {
    if (score > 10) return Colors.red.shade700;
    if (score > 5) return Colors.orange.shade700;
    return Colors.green.shade600;
  }

  Widget _buildKpiSection(List<QueryDocumentSnapshot> predictions) {
    final l10n = AppLocalizations.of(context)!;
    int totalPredictions = predictions.length;
    int highRiskCount =
        predictions.where((doc) => doc['predictedClass'] == 'High').length;
    var uniqueLocations =
        predictions.map((doc) => doc['location']).toSet().length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatCard(
            l10n.totalPredictions, totalPredictions.toString(), Icons.analytics),
        _buildStatCard(l10n.highRiskAlerts, highRiskCount.toString(), Icons.warning,
            color: Colors.red.shade700),
        _buildStatCard(
            l10n.locationsTested, uniqueLocations.toString(), Icons.location_city),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon,
      {Color color = Colors.blue}) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(value,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPieChartSection(List<QueryDocumentSnapshot> predictions) {
    final l10n = AppLocalizations.of(context)!;
    if (predictions.isEmpty) return const SizedBox.shrink();
    int lowCount =
        predictions.where((doc) => doc['predictedClass'] == 'Low').length;
    int mediumCount =
        predictions.where((doc) => doc['predictedClass'] == 'Medium').length;
    int highCount =
        predictions.where((doc) => doc['predictedClass'] == 'High').length;
    int total = lowCount + mediumCount + highCount;
    if (total == 0) return const SizedBox.shrink();
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(l10n.predictionBreakdown,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                        value: lowCount.toDouble(),
                        title:
                            '${((lowCount / total) * 100).toStringAsFixed(0)}%',
                        color: Colors.green,
                        radius: 50),
                    PieChartSectionData(
                        value: mediumCount.toDouble(),
                        title:
                            '${((mediumCount / total) * 100).toStringAsFixed(0)}%',
                        color: Colors.orange,
                        radius: 50),
                    PieChartSectionData(
                        value: highCount.toDouble(),
                        title:
                            '${((highCount / total) * 100).toStringAsFixed(0)}%',
                        color: Colors.red,
                        radius: 50),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPredictionsSection(
      List<QueryDocumentSnapshot> predictions) {
    final l10n = AppLocalizations.of(context)!;
    if (predictions.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.recentPredictions,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: predictions.length > 5 ? 5 : predictions.length,
          itemBuilder: (context, index) {
            var prediction = predictions[index];
            DateTime timestamp = (prediction['timestamp'] as Timestamp).toDate();
            String formattedDate =
                DateFormat('dd MMM yyyy, hh:mm a').format(timestamp);
            String location = prediction['location'] ?? 'N/A';
            String result = prediction['predictedClass'];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: Icon(
                  result == 'High'
                      ? Icons.error_outline
                      : result == 'Medium'
                          ? Icons.warning_amber
                          : Icons.check_circle_outline,
                  color: result == 'High'
                      ? Colors.red
                      : result == 'Medium'
                          ? Colors.orange
                          : Colors.green,
                ),
                title: Text('${l10n.location}: $location'),
                subtitle: Text('${l10n.result}: $result\n${l10n.on}: $formattedDate'),
                isThreeLine: true,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDiseaseBarChartSection(List<QueryDocumentSnapshot> reports) {
    final l10n = AppLocalizations.of(context)!;
    if (reports.isEmpty) return const SizedBox.shrink();
    final Map<String, int> patientCountsByDisease = {};
    for (var doc in reports) {
      final data = doc.data() as Map<String, dynamic>;
      final disease = data['disease_type'] as String;
      final count = data['patient_count'] as int;
      patientCountsByDisease[disease] =
          (patientCountsByDisease[disease] ?? 0) + count;
    }
    if (patientCountsByDisease.isEmpty) return const SizedBox.shrink();
    final List<BarChartGroupData> barGroups = [];
    int index = 0;
    patientCountsByDisease.forEach((disease, count) {
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
                toY: count.toDouble(), color: Colors.teal, width: 16)
          ],
        ),
      );
      index++;
    });
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.patientReportsByDisease,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (patientCountsByDisease.values
                          .reduce((a, b) => a > b ? a : b) *
                      1.2),
                  barGroups: barGroups,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final disease = patientCountsByDisease.keys
                              .elementAt(value.toInt());
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(disease,
                                style: const TextStyle(fontSize: 10),
                                overflow: TextOverflow.ellipsis),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData:
                      const FlGridData(show: true, drawVerticalLine: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentClinicReportsSection(List<QueryDocumentSnapshot> reports) {
    final l10n = AppLocalizations.of(context)!;
    if (reports.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.recentClinicReports,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reports.length > 5 ? 5 : reports.length,
          itemBuilder: (context, index) {
            var report = reports[index];
            DateTime timestamp = (report['timestamp'] as Timestamp).toDate();
            String formattedDate =
                DateFormat('dd MMM yyyy, hh:mm a').format(timestamp);
            String location = report['location'] ?? 'N/A';
            String disease = report['disease_type'] ?? 'Unknown';
            int count = report['patient_count'] ?? 0;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading:
                    const Icon(Icons.local_hospital, color: Colors.blueAccent),
                title: Text('$disease ($count ${l10n.cases})'),
                subtitle:
                    Text('${l10n.reportedFrom}: $location\n${l10n.on}: $formattedDate'),
                isThreeLine: true,
              ),
            );
          },
        ),
      ],
    );
  }
}
