import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; 
import 'survey_detail_screen.dart';

class PollQuestion {
  final String questionText;
  final List<String> options;

  PollQuestion(this.questionText, this.options);
}

class PollItem {
  final String title;
  final String status;
  final Color statusColor;
  final double progress;
  final List<PollQuestion> questions;
  
  bool isAnswered; 
  Map<int, String>? previousAnswers; 
  String? extraComment;

  PollItem(
    this.title, 
    this.status, 
    this.statusColor, 
    this.progress, 
    this.questions, 
    {this.isAnswered = false, this.previousAnswers, this.extraComment}
  );
}

/// A data model that consolidates survey questions, the user's previous answers (previousAnswers), and 
/// the survey's completion status (isAnswered) under a single umbrella, providing a state to the UI layer.
final List<PollItem> dummyPolls = [
  PollItem(
    "s1_title", "status_active", Colors.green, 0.65,
    [
      PollQuestion("s1_q1", ["s1_q1_o1", "s1_q1_o2", "s1_q1_o3", "s1_q1_o4"]),
      PollQuestion("s1_q2", ["s1_q2_o1", "s1_q2_o2", "s1_q2_o3", "s1_q2_o4"]),
      PollQuestion("s1_q3", ["s1_q3_o1", "s1_q3_o2", "s1_q3_o3", "s1_q3_o4"]),
      PollQuestion("s1_q4", ["s1_q4_o1", "s1_q4_o2", "s1_q4_o3", "s1_q4_o4"]),
    ],
  ),
  PollItem(
    "s2_title", "status_2days", Colors.blue, 0.80,
    [
      PollQuestion("s2_q1", ["s2_q1_o1", "s2_q1_o2", "s2_q1_o3", "s2_q1_o4"]),
      PollQuestion("s2_q2", ["s2_q2_o1", "s2_q2_o2", "s2_q2_o3", "s2_q2_o4"]),
      PollQuestion("s2_q3", ["s2_q3_o1", "s2_q3_o2", "s2_q3_o3", "s2_q3_o4"]),
      PollQuestion("s2_q4", ["s2_q4_o1", "s2_q4_o2", "s2_q4_o3", "s2_q4_o4"]),
      PollQuestion("s2_q5", ["s2_q5_o1", "s2_q5_o2", "s2_q5_o3", "s2_q5_o4"]),
    ],
    isAnswered: true,
    previousAnswers: {0: "s2_q1_o3", 1: "s2_q2_o3", 2: "s2_q3_o3", 3: "s2_q4_o2", 4: "s2_q5_o1"},
    extraComment: "s2_comment", 
  ),
  PollItem(
    "s3_title", "status_active", Colors.orange, 0.30,
    [
      PollQuestion("s3_q1", ["s3_q1_o1", "s3_q1_o2", "s3_q1_o3", "s3_q1_o4"]),
      PollQuestion("s3_q2", ["s3_q2_o1", "s3_q2_o2", "s3_q2_o3", "s3_q2_o4"]),
      PollQuestion("s3_q3", ["s3_q3_o1", "s3_q3_o2", "s3_q3_o3", "s3_q3_o4"]),
      PollQuestion("s3_q4", ["s3_q4_o1", "s3_q4_o2", "s3_q4_o3", "s3_q4_o4"]),
    ],
  ),
  PollItem(
    "s4_title", "status_new", Colors.purple, 0.10,
    [
      PollQuestion("s4_q1", ["s4_q1_o1", "s4_q1_o2", "s4_q1_o3", "s4_q1_o4"]),
      PollQuestion("s4_q2", ["s4_q2_o1", "s4_q2_o2", "s4_q2_o3", "s4_q2_o4"]),
      PollQuestion("s4_q3", ["s4_q3_o1", "s4_q3_o2", "s4_q3_o3", "s4_q3_o4"]),
      PollQuestion("s4_q4", ["s4_q4_o1", "s4_q4_o2", "s4_q4_o3", "s4_q4_o4"]),
    ],
  ),
];

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({Key? key}) : super(key: key);

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final TextEditingController _suggestionController = TextEditingController();

  @override
  void dispose() {
    _suggestionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check for dark mode before rendering
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('survey_appbar_title'.tr()), 
        backgroundColor: Colors.blue, 
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("survey_header".tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text("survey_subheader".tr(), style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                // To keep the background transparent in dark mode without disrupting the theme
                color: isDark ? Colors.blue.withOpacity(0.1) : Colors.blue.withOpacity(0.05), 
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("survey_new_suggestion".tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _suggestionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'survey_suggestion_hint'.tr(),
                      border: const OutlineInputBorder(),
                      filled: true,
                      // Dark/light mode setting for the text field
                      fillColor: isDark ? Colors.grey.shade800 : Colors.white, 
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    // A module that allows citizens to provide real-time feedback outside of official surveys 
                    // and facilitates sequential data entry by resetting the local state.
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_suggestionController.text.trim().isEmpty) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('survey_success_snack'.tr()), backgroundColor: Colors.green, duration: const Duration(seconds: 3)),
                        );
                        _suggestionController.clear();
                        FocusScope.of(context).unfocus();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      icon: const Icon(Icons.send),
                      label: Text('survey_send_btn'.tr()),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            Text("survey_active_polls".tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            ...dummyPolls.map((poll) {
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                // Make the card background match the theme
                color: isDark ? Colors.grey.shade900 : Colors.white, 
                child: ListTile(
                  title: Text(poll.title.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      poll.isAnswered 
                        ? Text("survey_already_answered".tr(), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12))
                        : Text("${'survey_status_label'.tr()}${poll.status.tr()}", style: TextStyle(color: poll.statusColor, fontSize: 12)),
                    ],
                  ),
                  trailing: Icon(poll.isAnswered ? Icons.check_circle : Icons.chevron_right, color: poll.isAnswered ? Colors.green : Colors.grey),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SurveyDetailScreen(poll: poll)),
                    );
                    setState(() {});
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}