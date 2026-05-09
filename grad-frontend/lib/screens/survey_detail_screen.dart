import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; 
import 'survey_screen.dart'; 

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

  /// A local state manager that confirms the survey has been fully completed (Validation) and 
  /// updates the data model with the user's new answers, setting the system to the ‘Answered’ (isAnswered = true) state.
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('survey_detail_title'.tr(),style: const TextStyle(fontWeight: FontWeight.bold,),),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if (widget.poll.isAnswered)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: isDark ? Colors.green.withOpacity(0.2) : Colors.green.shade50, 
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
                    color: isDark ? Colors.grey.shade900 : Colors.white, 
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
                              fillColor: isDark ? Colors.grey.shade800 : Colors.white, 
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
                  color: isDark ? Colors.grey.shade900 : Colors.white, 
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${index + 1}. ${question.questionText.tr()}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        
                        // [DYNAMIC COMPONENT RENDERING & STATE MUTATION]
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
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.white, 
              boxShadow: [
                BoxShadow(color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.shade300, blurRadius: 5, offset: const Offset(0, -3))
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