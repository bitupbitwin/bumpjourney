/// 内置标准孕周数据(只读预置)
class StandardWeekData {
  final int week;
  final String fruitEmoji;
  final String fetusSummary;
  final String bodyChange;
  final List<String> dietGood;
  final List<String> dietBad;
  final List<CheckItem> checks;
  final List<DadTask> dadTasks;

  const StandardWeekData({
    required this.week,
    required this.fruitEmoji,
    required this.fetusSummary,
    required this.bodyChange,
    required this.dietGood,
    required this.dietBad,
    required this.checks,
    required this.dadTasks,
  });
}

class CheckItem {
  final String title;
  final String note;
  const CheckItem(this.title, [this.note = '']);
}

class DadTask {
  final String title;
  final bool defaultDone;
  const DadTask(this.title, [this.defaultDone = false]);
}

/// 用户自定义事件(可写,落 SQLite 表 user_custom_events)
class CustomEvent {
  final int? id;
  final String title;
  final String content;
  final DateTime targetDate;
  final int associatedWeek;
  final int remindDaysBefore; // 0=不提醒
  final bool isCompleted;

  const CustomEvent({
    this.id,
    required this.title,
    this.content = '',
    required this.targetDate,
    required this.associatedWeek,
    this.remindDaysBefore = 0,
    this.isCompleted = false,
  });

  Map<String, Object?> toMap() => {
        if (id != null) 'event_id': id,
        'title': title,
        'content': content,
        'target_date': targetDate.toIso8601String(),
        'associated_week': associatedWeek,
        'remind_days_before': remindDaysBefore,
        'is_completed': isCompleted ? 1 : 0,
      };

  factory CustomEvent.fromMap(Map<String, Object?> m) => CustomEvent(
        id: m['event_id'] as int?,
        title: m['title'] as String,
        content: (m['content'] as String?) ?? '',
        targetDate: DateTime.parse(m['target_date'] as String),
        associatedWeek: m['associated_week'] as int,
        remindDaysBefore: (m['remind_days_before'] as int?) ?? 0,
        isCompleted: (m['is_completed'] as int? ?? 0) == 1,
      );

  CustomEvent copyWith({int? id, bool? isCompleted}) => CustomEvent(
        id: id ?? this.id,
        title: title,
        content: content,
        targetDate: targetDate,
        associatedWeek: associatedWeek,
        remindDaysBefore: remindDaysBefore,
        isCompleted: isCompleted ?? this.isCompleted,
      );
}

/// 知识库条目(可写,落 SQLite 表 user_knowledge_base)
class KnowledgeItem {
  final int? id;
  final String title;
  final String rawContent; // AI 提炼后或原始文本
  final String sourceUrl;
  final List<String> tags;
  final int? pinnedWeek; // 非空则锚定到对应周时间线

  const KnowledgeItem({
    this.id,
    required this.title,
    this.rawContent = '',
    this.sourceUrl = '',
    this.tags = const [],
    this.pinnedWeek,
  });

  Map<String, Object?> toMap() => {
        if (id != null) 'item_id': id,
        'title': title,
        'raw_content': rawContent,
        'source_url': sourceUrl,
        'tags': tags.join(','),
        'pinned_week': pinnedWeek,
      };

  factory KnowledgeItem.fromMap(Map<String, Object?> m) => KnowledgeItem(
        id: m['item_id'] as int?,
        title: m['title'] as String,
        rawContent: (m['raw_content'] as String?) ?? '',
        sourceUrl: (m['source_url'] as String?) ?? '',
        tags: ((m['tags'] as String?) ?? '')
            .split(',')
            .where((e) => e.trim().isNotEmpty)
            .toList(),
        pinnedWeek: m['pinned_week'] as int?,
      );
}
