import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const EnglishApp());
}

class EnglishApp extends StatelessWidget {
  const EnglishApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'English Grade 6',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const UnitsScreen(),
    );
  }
}

class UnitsScreen extends StatefulWidget {
  const UnitsScreen({super.key});

  @override
  State<UnitsScreen> createState() => _UnitsScreenState();
}

class _UnitsScreenState extends State<UnitsScreen> {
  List _units = [];

  Future<void> loadData() async {
    final String response = await rootBundle.loadString('assets/data.json');
    final data = await json.decode(response);
    setState(() {
      _units = data;
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('منهاج اللغة الإنجليزية - السادس'),
        centerTitle: true,
      ),
      body: _units.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _units.length,
              itemBuilder: (context, index) {
                final unit = _units[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${unit['unit_number']}'),
                    ),
                    title: Text('${unit['title_en']} - ${unit['title_ar']}'),
                    subtitle: Text(unit['term']),
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
      appBar: AppBar(
        title: Text(unit['title_en']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'النص الأساسي:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                unit['text_en'],
                style: const TextStyle(fontSize: 18),
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