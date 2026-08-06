import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 書類画像からの抽出結果
class DocumentScanResult {
  final String? title;
  final DateTime? dueDate;
  final double? amount;
  final String? notes;

  const DocumentScanResult({this.title, this.dueDate, this.amount, this.notes});
}

/// Claude API（Vision）を使って書類画像から期限・金額・タイトルを抽出する
///
/// Dart 公式 SDK が存在しないため dio で Messages API を直接呼び出す。
class DocumentScanService {
  static const _endpoint = 'https://api.anthropic.com/v1/messages';
  static const _model = 'claude-sonnet-5';

  static const _schema = {
    'type': 'object',
    'properties': {
      'title': {'type': 'string', 'description': '書類のタイトル・件名'},
      'dueDate': {
        'type': ['string', 'null'],
        'description': '期限日（YYYY-MM-DD形式）。読み取れない場合は null',
      },
      'amount': {
        'type': ['number', 'null'],
        'description': '金額（数値のみ、通貨記号なし）。読み取れない場合は null',
      },
      'notes': {'type': 'string', 'description': '書類の内容の簡潔な要約（1-2文）'},
    },
    'required': ['title', 'dueDate', 'amount', 'notes'],
    'additionalProperties': false,
  };

  static Future<DocumentScanResult> extractFromImage(Uint8List imageBytes) async {
    final apiKey = dotenv.env['ANTHROPIC_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('ANTHROPIC_API_KEY が設定されていません');
    }

    final base64Image = base64Encode(imageBytes);
    final dio = Dio();

    final response = await dio.post(
      _endpoint,
      options: Options(
        headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        },
      ),
      data: {
        'model': _model,
        'max_tokens': 1024,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'image',
                'source': {
                  'type': 'base64',
                  'media_type': 'image/jpeg',
                  'data': base64Image,
                },
              },
              {
                'type': 'text',
                'text': 'この書類画像から、タイトル・期限日・金額・要約を抽出してください。'
                    '日本語の書類（請求書、通知書、契約書など）を想定しています。',
              },
            ],
          },
        ],
        'output_config': {
          'format': {
            'type': 'json_schema',
            'schema': _schema,
          },
        },
      },
    );

    final content = response.data['content'] as List;
    final textBlock = content.firstWhere((b) => b['type'] == 'text');
    final json = jsonDecode(textBlock['text'] as String) as Map<String, dynamic>;

    return DocumentScanResult(
      title: json['title'] as String?,
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate'] as String) : null,
      amount: (json['amount'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );
  }
}
