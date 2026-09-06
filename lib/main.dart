import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

void main() {
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
        units = data['units'];
      });
    } catch (e) {
      debugPrint("Error loading data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('منهاج اللغة الإنجليزية - الصف السادس'),
        centerTitle: true,
      ),
      body: units.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: units.length,
              itemBuilder: (context, index) {
                final unit = units[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${unit['id']}'),
                    ),
                    title: Text(
                      unit['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(unit['description']),
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

class DetailScreen extends StatelessWidget {
  final Map unit;
  const DetailScreen({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(unit['title'])),
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
                unit['content_en'],
                style: const TextStyle(fontSize: 16),
              ),
              const Divider(height: 32),
              Text(
                'الترجمة العربية:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                unit['content_ar'],
                style: const TextStyle(fontSize: 16),
              ),
              const Divider(height: 32),
              Text(
                'القاموس والترجمة:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...Map<String, String>.from(unit['dictionary']).entries.map(
                    (e) => ListTile(
                      dense: true,
                      title: Text(e.key),
                      trailing: Text(e.value),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
