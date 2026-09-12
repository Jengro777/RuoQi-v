/// 多语言。
class Language {
  const Language({
    required this.code,
    required this.code2,
    required this.code3,
    required this.nativeName,
    required this.sort,
    this.isBase = false,
    this.enabled = true,
  });

  final String code;
  final String code2;
  final String code3;
  final String nativeName;
  final int sort;
  final bool isBase;
  final bool enabled;
}

const languages = [
  Language(code: 'zh_CN', code2: 'zh', code3: 'zho', nativeName: '简体中文-中国大陆', sort: 1, isBase: true),
  Language(code: 'en_US', code2: 'en', code3: 'eng', nativeName: 'English(US)', sort: 2),
  Language(code: 'fr_FR', code2: 'fr', code3: 'fra', nativeName: 'Français', sort: 3),
  Language(code: 'pt-PT', code2: 'pt', code3: 'por', nativeName: 'português', sort: 4),
  Language(code: 'ru-RU', code2: 'ru', code3: 'rus', nativeName: 'русский (Россия)', sort: 5),
  Language(code: 'VN-VI', code2: 'vi', code3: 'vie', nativeName: 'Tiếng Việt', sort: 6, enabled: false),
];
