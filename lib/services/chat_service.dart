import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatService {
  final String _apiKey = dotenv.env['DEEPSEEK_API_KEY']!;
  final String _url = "https://api.deepseek.com/v1/chat/completions";

  /// Streamed response — used for the Chatbot
  Stream<String> sendMessageStream(String message) async* {
    final requestBody = jsonEncode({
      "model": "deepseek-chat",
      "stream": true,
      "messages": [
        {
          "role": "system",
          "content": "You are Kizie, a helpful and caring healthcare assistant."
        },
        {
          "role": "user",
          "content": message
        }
      ],
    });

    final request = http.Request("POST", Uri.parse(_url));
    request.headers.addAll({
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    });
    request.body = requestBody;

    final response = await request.send();

    if (response.statusCode == 200) {
      final utf8Stream = response.stream.transform(utf8.decoder);
      await for (var chunk in utf8Stream) {
        final lines = chunk
            .split('\n')
            .where((line) => line.trim().isNotEmpty && line.startsWith('data: '))
            .toList();

        for (var line in lines) {
          final jsonStr = line.replaceFirst('data: ', '');
          if (jsonStr.trim() == '[DONE]') continue;

          try {
            final data = json.decode(jsonStr);
            final content = data['choices'][0]['delta']?['content'];
            if (content != null) yield content;
          } catch (e) {
            yield "[Error parsing stream chunk]";
          }
        }
      }
    } else {
      yield "Error: ${response.statusCode}";
    }
  }

  /// Instant full response — used for the Report Analyzer
  Future<String> sendMessage(String userInput, {bool isReport = false}) async {
    final body = jsonEncode({
      "model": "deepseek-chat",
      "messages": [
        {
          "role": "system",
          "content": isReport
              ? "You are a helpful medical assistant. Read the medical report carefully and give a brief, clear, and interesting explanation for the patient to understand easily."
              : "You are Kizie, a helpful and caring healthcare assistant."
        },
        {
          "role": "user",
          "content": userInput
        }
      ]
    });

    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      return "An error occurred: $e";
    }
  }
}