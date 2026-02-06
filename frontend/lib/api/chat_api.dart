import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatApi {
  static const String baseUrl =
      "https://lemuel-cuneal-sierra.ngrok-free.dev";

  /// Sends a message and returns the response as a stream of text chunks.
  /// NOTE: This assumes your backend has a streaming endpoint at `/chat-stream`.
  static Stream<String> sendMessage(String message) async* {
    final client = http.Client();
    final uri = Uri.parse(
      // IMPORTANT: The endpoint is changed to /chat-stream
      // Your backend needs to support this.
      "$baseUrl/chat-stream?prompt=${Uri.encodeComponent(message)}",
    );

    final request = http.Request('POST', uri);

    try {
      final response = await client.send(request);

      if (response.statusCode != 200) {
        final body = await response.stream.bytesToString();
        throw Exception("Server error: ${response.statusCode} $body");
      }

      // Yields the response body chunks as they arrive.
      await for (final chunk in response.stream.transform(utf8.decoder)) {
        yield chunk;
      }
    } finally {
      client.close();
    }
  }
}
