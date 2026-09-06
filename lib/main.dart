import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EnglishCurriculumApp());
}

class EnglishCurriculumApp extends StatelessWidget {
  const EnglishCurriculumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'منهاج اللغة الإنجليزية - الصف السادس',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List units = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final String response = await rootBundle.loadString('assets/data.json');
      final data = await json.decode(response);
      setState(() {
        units = data['units'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'خطأ في قراءة ملف البيانات: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('منهاج اللغة الإنجليزية - الصف السادس'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: units.length,
                  itemBuilder: (context, index) {
                    final unit = units[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text('${unit['id']}'),
                        ),
                        title: Text(
                          unit['title'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(unit['description'] ?? ''),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(unit: unit),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

class DetailScreen extends StatefulWidget {
  final Map unit;
  const DetailScreen({super.key, required this.unit});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Map<int, String> selectedAnswers = {};

  @override
  Widget build(BuildContext context) {
    List questions = widget.unit['questions'] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(widget.unit['title'] ?? '')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'النص الإنجليزي:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                widget.unit['content_en'] ?? '',
                style: const TextStyle(fontSize: 16),
              ),
              const Divider(height: 32),
              Text(
                'الترجمة العربية:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                widget.unit['content_ar'] ?? '',
                style: const TextStyle(fontSize: 16),
              ),
              const Divider(height: 32),
              Text(
                'القاموس والترجمة:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (widget.unit['dictionary'] != null)
                ...Map<String, String>.from(widget.unit['dictionary'])
                    .entries
                    .map(
                      (e) => ListTile(
                        dense: true,
                        title: Text(e.key),
                        trailing: Text(e.value),
                      ),
                    ),
              if (questions.isNotEmpty) ...[
                const Divider(height: 32),
                Text(
                  'الأسئلة التفاعلية:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...questions.asMap().entries.map((entry) {
                  int qIndex = entry.key;
                  Map q = entry.value;
                  return Card(
                    color: Colors.indigo.shade50,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'س${qIndex + 1}: ${q['question']}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 8),
                          ...(q['options'] as List).map((opt) {
                            bool isSelected = selectedAnswers[qIndex] == opt;
                            bool isCorrect = opt == q['answer'];
                            Color tileColor = Colors.transparent;

                            if (selectedAnswers.containsKey(qIndex)) {
                              if (isSelected && isCorrect) {
                                tileColor = Colors.green.shade100;
                              } else if (isSelected && !isCorrect) {
                                tileColor = Colors.red.shade100;
                              } else if (isCorrect) {
                                tileColor = Colors.green.shade50;
                              }
                            }

                            return Container(
                              color: tileColor,
                              child: RadioListTile<String>(
                                title: Text(opt),
                                value: opt,
                                groupValue: selectedAnswers[qIndex],
                                onChanged: (val) {
                                  setState(() {
                                    selectedAnswers[qIndex] = val!;
                                  });
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                }),
              ]
            ],
          ),
        ),
      ),
    );
  }
}