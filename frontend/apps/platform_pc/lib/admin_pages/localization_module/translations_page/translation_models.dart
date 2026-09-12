/// 翻译条目。
class TranslationKey {
  const TranslationKey({
    required this.key,
    required this.zh,
    required this.en,
    required this.translated,
  });

  final String key;
  final String zh;
  final String en;
  final bool translated;
}

const translationKeys = [
  TranslationKey(key: 'EvaluationTime', zh: '评价时间', en: 'EvaluationTime', translated: true),
  TranslationKey(key: 'Tools.MarkedRead', zh: '标为已读', en: 'Mark as read', translated: true),
  TranslationKey(key: 'Settings.Profile', zh: '个人资料', en: 'Profile', translated: true),
  TranslationKey(key: 'Payment.Success', zh: '支付成功', en: 'Payment succeeded', translated: true),
  TranslationKey(key: 'Invite.EmailSubject', zh: '我们邀请您加入 \${Site Name}', en: '', translated: false),
  TranslationKey(key: 'Verify.SmsBody', zh: '', en: '', translated: false),
];
