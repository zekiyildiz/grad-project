import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; 

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
    // Okunması için karanlık mod kontrolü
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
                // Karanlık modda arka planı şeffaf yapıp temayı bozmamak için
                color: isDark ? Colors.blue.withOpacity(0.1) : Colors.blue.withOpacity(0.05), // DÜZELTİLDİ
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
                      // Textfield içi karanlık/aydınlık mod ayarı
                      fillColor: isDark ? Colors.grey.shade800 : Colors.white, // DÜZELTİLDİ
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
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
                // Kart arka planını temaya uyumlu hale getir
                color: isDark ? Colors.grey.shade900 : Colors.white, // DÜZELTİLDİ
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

class SurveyDetailScreen extends StatefulWidget {
  final PollItem poll;

  const SurveyDetailScreen({Key? key, required this.poll}) : super(key: key);

  @override
  State<SurveyDetailScreen> createState() => _SurveyDetailScreenState();
}

class _SurveyDetailScreenState extends State<SurveyDetailScreen> {
  final Map<int, String> _answers = {};
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.poll.isAnswered && widget.poll.previousAnswers != null) {
      _answers.addAll(widget.poll.previousAnswers!);
    }
    if (widget.poll.isAnswered && widget.poll.extraComment != null) {
      _commentController.text = widget.poll.extraComment!.tr();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitSurvey() {
    if (_answers.length < widget.poll.questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('survey_err_incomplete'.tr()), backgroundColor: Colors.red),
      );
      return; 
    }

    widget.poll.isAnswered = true;
    widget.poll.previousAnswers = Map.from(_answers);
    
    if (_commentController.text.trim().isNotEmpty) {
      widget.poll.extraComment = _commentController.text.trim();
    } else {
      widget.poll.extraComment = null;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('survey_ans_saved'.tr()), backgroundColor: Colors.green),
    );
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Okunması için karanlık mod kontrolü
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('survey_detail_title'.tr()),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if (widget.poll.isAnswered)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              // Bilgi kutusunun arka planını karanlık mod uyumlu yap
              color: isDark ? Colors.green.withOpacity(0.2) : Colors.green.shade50, // DÜZELTİLDİ
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(child: Text("survey_update_info".tr(), style: const TextStyle(color: Colors.green))),
                ],
              ),
            ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: widget.poll.questions.length + 1, 
              itemBuilder: (context, index) {
                
                if (index == widget.poll.questions.length) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 20.0, top: 10.0),
                    elevation: 3,
                    // Kart arka planını temaya uyumlu hale getir
                    color: isDark ? Colors.grey.shade900 : Colors.white, // DÜZELTİLDİ
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.comment, color: Colors.blue, size: 20),
                              const SizedBox(width: 8),
                              Text("survey_extra_comment".tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _commentController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'survey_extra_comment_hint'.tr(),
                              border: const OutlineInputBorder(),
                              filled: true,
                              // Textfield içi karanlık/aydınlık mod ayarı
                              fillColor: isDark ? Colors.grey.shade800 : Colors.white, // DÜZELTİLDİ
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final question = widget.poll.questions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 20.0),
                  elevation: 3,
                  // Kart arka planını temaya uyumlu hale getir
                  color: isDark ? Colors.grey.shade900 : Colors.white, // DÜZELTİLDİ
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${index + 1}. ${question.questionText.tr()}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        
                        ...question.options.map((optionKey) {
                          return RadioListTile<String>(
                            title: Text(optionKey.tr()),
                            value: optionKey,
                            groupValue: _answers[index], 
                            activeColor: Colors.blue,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (String? value) {
                              setState(() {
                                _answers[index] = value!; 
                              });
                            },
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // --- Burası: Submit Survey butonunun arkasındaki beyaz alanı düzeltiyoruz ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              // Sabit Colors.white yerine temanın kendi rengini veya uygun karanlık rengi veriyoruz
              color: isDark ? Colors.grey.shade900 : Colors.white, // DÜZELTİLDİ
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.shade300, 
                  blurRadius: 5, 
                  offset: const Offset(0, -3)
                )
              ],
            ),
            child: ElevatedButton(
              onPressed: _submitSurvey,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.poll.isAnswered ? Colors.orange : Colors.blue, 
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: Text(widget.poll.isAnswered ? 'survey_update_btn'.tr() : 'survey_submit_btn'.tr()),
            ),
          )
        ],
      ),
    );
  }
}