import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:healthor/services/chat_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
import 'dart:async';

class ReportAnalysisScreen extends StatefulWidget {
  const ReportAnalysisScreen({super.key});

  @override
  State<ReportAnalysisScreen> createState() => _ReportAnalysisScreenState();
}

class _ReportAnalysisScreenState extends State<ReportAnalysisScreen> {
  final TextEditingController _controller = TextEditingController();
  final ChatService _chatService = ChatService();

  String _result = '';
  bool _isLoading = false;
  Stream<String>? _responseStream;
  StreamSubscription<String>? _streamSubscription;

  void _analyzeReport(String reportText) async {
    if (reportText.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _result = '';
    });

    _streamSubscription?.cancel(); // cancel previous stream if any

    final buffer = StringBuffer();
    _responseStream = _chatService.sendMessageStream(
      "Analyze this medical report and explain it clearly and briefly like a smart AI healthcare assistant:\n\n$reportText",
    );

    _streamSubscription = _responseStream!.listen((chunk) {
      setState(() {
        buffer.write(chunk);
        _result = buffer.toString();
      });
    }, onDone: () {
      setState(() {
        _isLoading = false;
      });
    }, onError: (e) {
      setState(() {
        _isLoading = false;
        _result = 'Error analyzing report.';
      });
    });
  }

  Future<void> _pickPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final pdfText = await ReadPdfText.getPDFtext(path);
      _controller.text = pdfText;
      _analyzeReport(pdfText);
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Report Analysis',
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF007BFF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Upload or paste your medical report to get a summary!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _pickPDF,
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload PDF"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'Or paste the medical report here...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _analyzeReport(_controller.text),
              child: const Text("Analyze"),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(),
                  )
                : Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _result,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
