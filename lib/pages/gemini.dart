import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

final gemini = Gemini.instance;

class GeminiClass extends StatefulWidget {
  const GeminiClass({super.key});

  @override
  _GeminiClassState createState() => _GeminiClassState();
}

class _GeminiClassState extends State<GeminiClass> {
  final TextEditingController _controller = TextEditingController();
  String? _storyOutput;
  bool _isLoading = false;

  // List of predefined questions
  final List<String> _predefinedQuestions = [
    "Apa yang menyebabkan kebakaran hutan?",
    "Bagaimana cara mencegah kebakaran?",
    "Apa dampak kebakaran hutan bagi lingkungan?",
    "Langkah apa yang harus diambil jika terjadi kebakaran?",
  ];

  String? _selectedQuestion; // To keep track of selected question

  Future<void> _fetchStory(String prompt) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final value = await gemini.text(prompt);
      setState(() {
        _storyOutput = value?.output;
      });
    } catch (e) {
      print(e);
      setState(() {
        _storyOutput = "Error fetching story";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ODIN CHATBOT',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 63, 74, 93),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Silahkan Tanya mengenai Kebakaran!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 24),
      
            // Dropdown for predefined questions
            DropdownButton<String>(
              value: _selectedQuestion,
              hint: Text('Pilih Pertanyaan'),
              isExpanded: true,
              items: _predefinedQuestions.map((question) {
                return DropdownMenuItem(
                  value: question,
                  child: Text(question),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedQuestion = value;
                  _controller.text = value ?? ''; // Populate the TextField with selected question
                });
              },
            ),
            SizedBox(height: 16),
      
            // Input field
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Silahkan Tanya',
                labelStyle: TextStyle(color: const Color.fromARGB(255, 63, 74, 93)),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
      
            // Generate Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    _fetchStory(_controller.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 54, 50, 141),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Ask Odin",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255)),
                ),
              ),
            ),
            SizedBox(height: 30),
      
            // Display result or loading indicator
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_storyOutput != null)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _storyOutput!,
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                ),
              )
            else
              Center(
                child: Text(
                  "Jawaban ada di sini.",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}