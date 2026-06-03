import 'dart:async';

/// AI 网页内容结构化提取(杀手级功能)。
///
/// 当前为本地占位实现,演示「粘贴→提炼」的链路与返回结构。
/// 正式接入时:走云端 API(Gemini Flash / DeepSeek),切勿在客户端
/// 硬编码 API Key —— 应经由你自己的轻量后端中转,或作为 Premium 功能。
class AiExtractor {
  /// 返回结构化字段 + 建议锚定周。
  static Future<ExtractResult> extract(String rawText) async {
    await Future.delayed(const Duration(milliseconds: 600)); // 模拟网络

    // —— 占位:简单关键词推断锚定周 ——
    int? week;
    if (rawText.contains('建档') || rawText.contains('NT')) {
      week = 12;
    } else if (rawText.contains('糖耐') || rawText.contains('控糖')) {
      week = 24;
    } else if (rawText.contains('大排畸')) {
      week = 20;
    } else if (rawText.contains('待产包')) {
      week = 32;
    }

    final summary = rawText.length > 60 ? '${rawText.substring(0, 60)}…' : rawText;

    return ExtractResult(
      title: _guessTitle(rawText),
      structured: '【提炼】$summary',
      suggestedWeek: week,
    );

    // —— 正式实现参考(伪代码)——
    // final resp = await http.post(
    //   Uri.parse('https://your-backend.example.com/extract'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode({'text': rawText}),
    // );
    // final json = jsonDecode(resp.body);
    // return ExtractResult.fromJson(json);
  }

  static String _guessTitle(String t) {
    final firstLine = t.split('\n').first.trim();
    if (firstLine.isEmpty) return '导入的内容';
    return firstLine.length > 20 ? '${firstLine.substring(0, 20)}…' : firstLine;
  }
}

class ExtractResult {
  final String title;
  final String structured;
  final int? suggestedWeek;
  const ExtractResult({
    required this.title,
    required this.structured,
    this.suggestedWeek,
  });
}
