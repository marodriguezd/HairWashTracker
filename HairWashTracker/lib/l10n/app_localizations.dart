import 'package:flutter/widgets.dart';

/// Supported UI languages: the five most widely spoken European languages
/// (English, Spanish, German, French, Italian) plus Simplified Chinese.
///
/// Central catalogue for every user-visible string in the app. English is
/// the canonical base and the deterministic fallback: any missing key in
/// another language resolves to English, never to a blank string.
enum AppLanguage {
  english('en', 'English'),
  spanish('es', 'Español'),
  german('de', 'Deutsch'),
  french('fr', 'Français'),
  italian('it', 'Italiano'),
  chinese('zh', '中文（简体）');

  final String code;
  final String nativeName;

  const AppLanguage(this.code, this.nativeName);

  Locale get locale => Locale(code);

  static const List<AppLanguage> supported = AppLanguage.values;

}

class AppLocalizations {
  AppLocalizations._();

  static const List<String> supportedCodes = ['en', 'es', 'de', 'fr', 'it', 'zh'];

  /// Maps a raw locale language code (e.g. from the OS) to a supported
  /// app language. Regional variants fall back to their base language;
  /// Traditional Chinese script variants fall back to English rather than
  /// receiving Simplified text; anything unknown resolves to English.
  static String systemDefaultCode([String? languageCode, String? scriptCode, String? countryCode]) {
    final lang = (languageCode ?? '').toLowerCase();
    switch (lang) {
      case 'en':
      case 'es':
      case 'de':
      case 'fr':
      case 'it':
        return lang;
      case 'zh':
        final script = (scriptCode ?? '').toLowerCase();
        final country = (countryCode ?? '').toUpperCase();
        if (script == 'hant' || country == 'TW' || country == 'HK' || country == 'MO') {
          return 'en';
        }
        return 'zh';
      default:
        return 'en';
    }
  }

  static bool isSupported(String? code) =>
      code != null && supportedCodes.contains(code.trim());

  /// Looks up [key] for [code], falling back to English and finally to the
  /// key itself.
  static String stringFor(String code, String key) {
    final normalized = supportedCodes.contains(code) ? code : 'en';
    return _byCode[normalized]?[key] ?? _en[key] ?? key;
  }

  static Set<String> get keys => _en.keys.toSet();

  /// Keys defined for [code]. Comparing this against [keys] is what makes a
  /// missing translation detectable: [stringFor] would otherwise mask it by
  /// falling back to English.
  static Set<String> keysFor(String code) => (_byCode[code] ?? _en).keys.toSet();

  static const Map<String, String> _en = {
    'appTitle': 'Hair Wash Tracker',
    'navCalendar': 'Calendar',
    'navStats': 'Stats',
    'navSettings': 'Settings',
    'pageStatistics': 'Statistics',
    'tooltipDataMgmt': 'Data management',
    'dataImport': 'Import backup (JSON or CSV)',
    'dataExport': 'Export backup (JSON)',
    'msgImported': 'Data imported successfully',
    'msgExported': 'Data exported successfully',
    'msgCleared': 'All data has been cleared',
    'dataTitle': 'Data Management',
    'dataExportDesc': 'Save the full routine history as a versioned JSON file',
    'dataImportDesc': 'Restore from a JSON backup; CSV backups from older versions also work',
    'dataClearAll': 'Clear all data',
    'dataClearConfirm': 'Clear data',
    'dataClearDesc': 'Permanently erase all logged washes on device',
    'dataClearTitle': 'Clear all data?',
    'dataClearMsg':
        'This action will permanently erase all logged hair washes. It cannot be undone.',
    'dlgDelete': 'Delete',
    'dlgCancel': 'Cancel',
    'setAppearance': 'Appearance',
    'setAccent': 'Accent color',
    'setAccentSystem': 'System',
    'setAccentSystemDesc':
        'Follows your wallpaper on Android 12+. Falls back to the selected preset otherwise.',
    'presetWarmCoral': 'Warm Coral',
    'presetLavender': 'Lavender',
    'presetSage': 'Sage',
    'presetOcean': 'Ocean',
    'themeLight': 'Light',
    'themeDark': 'Dark',
    'themeAuto': 'Auto',
    'setLanguage': 'Language',
    'setLanguageDesc': 'Interface language, or follow the system.',
    'setLangAuto': 'Automatic (System)',
    'statsNextWash': 'Next Recommended Wash',
    'statsKeepLogging': 'Keep logging washes',
    'confLow': 'Low confidence',
    'confMedium': 'Medium confidence',
    'confHigh': 'High confidence',
    'statsCalcDesc':
        'Calculated from your EWMA routine model and recent washing cadence',
    'statsCadence': 'Routine cadence',
    'statsInterval': 'Interval',
    'statsEwma': 'EWMA cadence',
    'statsTrend': 'Trend',
    'statsRecentPace': 'Recent pace',
    'statsAverage': 'Average',
    'statsMedian': 'Median',
    'trendUp': 'Increasing',
    'trendDown': 'Decreasing',
    'trendFlat': 'Stable',
    'statsVolume': 'Volume overview',
    'statsAllTime': 'All time',
    'statsThisWeek': 'This week',
    'statsThisMonth': 'This month',
    'monthTitle': 'Washes This Month',
    'emptyNoWashes': 'No Washes Yet',
    'emptyNoWashesMsg':
        'Start tracking your hair wash routine to see your progress here.',
    'emptyAddFirst': 'Add First Wash',
  };

  static const Map<String, String> _es = {
    'appTitle': 'Hair Wash Tracker',
    'navCalendar': 'Calendario',
    'navStats': 'Estadísticas',
    'navSettings': 'Ajustes',
    'pageStatistics': 'Estadísticas',
    'tooltipDataMgmt': 'Gestión de datos',
    'dataImport': 'Importar copia (JSON o CSV)',
    'dataExport': 'Exportar copia (JSON)',
    'msgImported': 'Datos importados correctamente',
    'msgExported': 'Datos exportados correctamente',
    'msgCleared': 'Todos los datos se han borrado',
    'dataTitle': 'Gestión de datos',
    'dataExportDesc': 'Guarda todo el historial como archivo JSON con versión',
    'dataImportDesc': 'Restaura desde una copia JSON; también sirven los CSV de versiones anteriores',
    'dataClearAll': 'Borrar todos los datos',
    'dataClearConfirm': 'Borrar datos',
    'dataClearDesc': 'Borra permanentemente todos los lavados del dispositivo',
    'dataClearTitle': '¿Borrar todos los datos?',
    'dataClearMsg':
        'Esta acción borrará permanentemente todos los lavados registrados. No se puede deshacer.',
    'dlgDelete': 'Eliminar',
    'dlgCancel': 'Cancelar',
    'setAppearance': 'Apariencia',
    'setAccent': 'Color de acento',
    'setAccentSystem': 'Sistema',
    'setAccentSystemDesc':
        'Sigue tu fondo de pantalla en Android 12+. Si no, usa el preset elegido.',
    'presetWarmCoral': 'Coral cálido',
    'presetLavender': 'Lavanda',
    'presetSage': 'Salvia',
    'presetOcean': 'Océano',
    'themeLight': 'Claro',
    'themeDark': 'Oscuro',
    'themeAuto': 'Auto',
    'setLanguage': 'Idioma',
    'setLanguageDesc': 'Idioma de la interfaz, o seguir el sistema.',
    'setLangAuto': 'Automático (Sistema)',
    'statsNextWash': 'Próximo lavado recomendado',
    'statsKeepLogging': 'Sigue registrando lavados',
    'confLow': 'Confianza baja',
    'confMedium': 'Confianza media',
    'confHigh': 'Confianza alta',
    'statsCalcDesc': 'Calculado con tu modelo de rutina EWMA y tu ritmo reciente',
    'statsCadence': 'Ritmo de rutina',
    'statsInterval': 'Intervalo',
    'statsEwma': 'Cadencia EWMA',
    'statsTrend': 'Tendencia',
    'statsRecentPace': 'Ritmo reciente',
    'statsAverage': 'Media',
    'statsMedian': 'Mediana',
    'trendUp': 'En aumento',
    'trendDown': 'En descenso',
    'trendFlat': 'Estable',
    'statsVolume': 'Resumen de volumen',
    'statsAllTime': 'Siempre',
    'statsThisWeek': 'Esta semana',
    'statsThisMonth': 'Este mes',
    'monthTitle': 'Lavados este mes',
    'emptyNoWashes': 'Aún sin lavados',
    'emptyNoWashesMsg':
        'Empieza a registrar tus lavados para ver tu progreso aquí.',
    'emptyAddFirst': 'Añadir primer lavado',
  };

  static const Map<String, String> _de = {
    'appTitle': 'Hair Wash Tracker',
    'navCalendar': 'Kalender',
    'navStats': 'Statistiken',
    'navSettings': 'Einstellungen',
    'pageStatistics': 'Statistiken',
    'tooltipDataMgmt': 'Datenverwaltung',
    'dataImport': 'Sicherung importieren (JSON oder CSV)',
    'dataExport': 'Sicherung exportieren (JSON)',
    'msgImported': 'Daten erfolgreich importiert',
    'msgExported': 'Daten erfolgreich exportiert',
    'msgCleared': 'Alle Daten wurden gelöscht',
    'dataTitle': 'Datenverwaltung',
    'dataExportDesc': 'Den gesamten Verlauf als versionierte JSON-Datei speichern',
    'dataImportDesc': 'Aus einer JSON-Sicherung wiederherstellen; CSV aus älteren Versionen funktioniert auch',
    'dataClearAll': 'Alle Daten löschen',
    'dataClearConfirm': 'Daten löschen',
    'dataClearDesc': 'Alle protokollierten Wäschen endgültig löschen',
    'dataClearTitle': 'Alle Daten löschen?',
    'dataClearMsg':
        'Diese Aktion löscht alle protokollierten Haarwäschen endgültig. Sie kann nicht rückgängig gemacht werden.',
    'dlgDelete': 'Löschen',
    'dlgCancel': 'Abbrechen',
    'setAppearance': 'Darstellung',
    'setAccent': 'Akzentfarbe',
    'setAccentSystem': 'System',
    'setAccentSystemDesc':
        'Folgt dem Hintergrund ab Android 12. Sonst gilt die gewählte Vorgabe.',
    'presetWarmCoral': 'Warmes Korall',
    'presetLavender': 'Lavendel',
    'presetSage': 'Salbei',
    'presetOcean': 'Ozean',
    'themeLight': 'Hell',
    'themeDark': 'Dunkel',
    'themeAuto': 'Auto',
    'setLanguage': 'Sprache',
    'setLanguageDesc': 'Sprache der Oberfläche oder System folgen.',
    'setLangAuto': 'Automatisch (System)',
    'statsNextWash': 'Nächste empfohlene Wäsche',
    'statsKeepLogging': 'Weiter protokollieren',
    'confLow': 'Geringe Sicherheit',
    'confMedium': 'Mittlere Sicherheit',
    'confHigh': 'Hohe Sicherheit',
    'statsCalcDesc': 'Aus deinem EWMA-Modell und deinem Waschrhythmus berechnet',
    'statsCadence': 'Waschrhythmus',
    'statsInterval': 'Intervall',
    'statsEwma': 'EWMA-Rhythmus',
    'statsTrend': 'Trend',
    'statsRecentPace': 'Aktuelles Tempo',
    'statsAverage': 'Durchschnitt',
    'statsMedian': 'Median',
    'trendUp': 'Steigend',
    'trendDown': 'Fallend',
    'trendFlat': 'Stabil',
    'statsVolume': 'Mengenübersicht',
    'statsAllTime': 'Gesamt',
    'statsThisWeek': 'Diese Woche',
    'statsThisMonth': 'Dieser Monat',
    'monthTitle': 'Wäschen diesen Monat',
    'emptyNoWashes': 'Noch keine Wäschen',
    'emptyNoWashesMsg':
        'Protokolliere deine Haarwäschen, um deinen Fortschritt hier zu sehen.',
    'emptyAddFirst': 'Erste Wäsche eintragen',
  };

  static const Map<String, String> _fr = {
    'appTitle': 'Hair Wash Tracker',
    'navCalendar': 'Calendrier',
    'navStats': 'Statistiques',
    'navSettings': 'Paramètres',
    'pageStatistics': 'Statistiques',
    'tooltipDataMgmt': 'Gestion des données',
    'dataImport': 'Importer une sauvegarde (JSON ou CSV)',
    'dataExport': 'Exporter la sauvegarde (JSON)',
    'msgImported': 'Données importées avec succès',
    'msgExported': 'Données exportées avec succès',
    'msgCleared': 'Toutes les données ont été effacées',
    'dataTitle': 'Gestion des données',
    'dataExportDesc': 'Enregistre tout l’historique dans un fichier JSON versionné',
    'dataImportDesc': 'Restaurer depuis une sauvegarde JSON ; les CSV des versions précédentes fonctionnent aussi',
    'dataClearAll': 'Tout effacer',
    'dataClearConfirm': 'Effacer les données',
    'dataClearDesc': 'Effacer définitivement tous les lavages enregistrés',
    'dataClearTitle': 'Tout effacer ?',
    'dataClearMsg':
        'Cette action effacera définitivement toutes les dates enregistrées. Elle est irréversible.',
    'dlgDelete': 'Supprimer',
    'dlgCancel': 'Annuler',
    'setAppearance': 'Apparence',
    'setAccent': 'Couleur d’accent',
    'setAccentSystem': 'Système',
    'setAccentSystemDesc':
        'Suit votre fond d’écran sur Android 12+. Sinon, utilise le préréglage choisi.',
    'presetWarmCoral': 'Corail chaud',
    'presetLavender': 'Lavande',
    'presetSage': 'Sauge',
    'presetOcean': 'Océan',
    'themeLight': 'Clair',
    'themeDark': 'Sombre',
    'themeAuto': 'Auto',
    'setLanguage': 'Langue',
    'setLanguageDesc': 'Langue de l’interface, ou suivre le système.',
    'setLangAuto': 'Automatique (Système)',
    'statsNextWash': 'Prochain lavage recommandé',
    'statsKeepLogging': 'Continuez à enregistrer',
    'confLow': 'Confiance faible',
    'confMedium': 'Confiance moyenne',
    'confHigh': 'Confiance élevée',
    'statsCalcDesc': 'Calculé à partir de votre modèle EWMA et de votre rythme récent',
    'statsCadence': 'Rythme habituel',
    'statsInterval': 'Intervalle',
    'statsEwma': 'Cadence EWMA',
    'statsTrend': 'Tendance',
    'statsRecentPace': 'Rythme récent',
    'statsAverage': 'Moyenne',
    'statsMedian': 'Médiane',
    'trendUp': 'En hausse',
    'trendDown': 'En baisse',
    'trendFlat': 'Stable',
    'statsVolume': 'Aperçu du volume',
    'statsAllTime': 'Total',
    'statsThisWeek': 'Cette semaine',
    'statsThisMonth': 'Ce mois-ci',
    'monthTitle': 'Lavages ce mois-ci',
    'emptyNoWashes': 'Aucun lavage pour l’instant',
    'emptyNoWashesMsg':
        'Commencez à suivre vos lavages pour voir vos progrès ici.',
    'emptyAddFirst': 'Ajouter le premier lavage',
  };

  static const Map<String, String> _it = {
    'appTitle': 'Hair Wash Tracker',
    'navCalendar': 'Calendario',
    'navStats': 'Statistiche',
    'navSettings': 'Impostazioni',
    'pageStatistics': 'Statistiche',
    'tooltipDataMgmt': 'Gestione dati',
    'dataImport': 'Importa backup (JSON o CSV)',
    'dataExport': 'Esporta backup (JSON)',
    'msgImported': 'Dati importati correttamente',
    'msgExported': 'Dati esportati correttamente',
    'msgCleared': 'Tutti i dati sono stati cancellati',
    'dataTitle': 'Gestione dati',
    'dataExportDesc': 'Salva tutto lo storico come file JSON con versione',
    'dataImportDesc': 'Ripristina da un backup JSON; funzionano anche i CSV delle versioni precedenti',
    'dataClearAll': 'Cancella tutti i dati',
    'dataClearConfirm': 'Cancella dati',
    'dataClearDesc': 'Cancella definitivamente tutti i lavaggi registrati',
    'dataClearTitle': 'Cancellare tutti i dati?',
    'dataClearMsg':
        'Questa azione cancellerà definitivamente tutti i lavaggi registrati. Non può essere annullata.',
    'dlgDelete': 'Elimina',
    'dlgCancel': 'Annulla',
    'setAppearance': 'Aspetto',
    'setAccent': 'Colore accento',
    'setAccentSystem': 'Sistema',
    'setAccentSystemDesc':
        'Segue lo sfondo su Android 12+. Altrimenti usa il preset scelto.',
    'presetWarmCoral': 'Corallo caldo',
    'presetLavender': 'Lavanda',
    'presetSage': 'Salvia',
    'presetOcean': 'Oceano',
    'themeLight': 'Chiaro',
    'themeDark': 'Scuro',
    'themeAuto': 'Auto',
    'setLanguage': 'Lingua',
    'setLanguageDesc': 'Lingua dell’interfaccia, oppure segui il sistema.',
    'setLangAuto': 'Automatico (Sistema)',
    'statsNextWash': 'Prossimo lavaggio consigliato',
    'statsKeepLogging': 'Continua a registrare',
    'confLow': 'Confidenza bassa',
    'confMedium': 'Confidenza media',
    'confHigh': 'Confidenza alta',
    'statsCalcDesc': 'Calcolato dal tuo modello EWMA e dal ritmo recente',
    'statsCadence': 'Ritmo abituale',
    'statsInterval': 'Intervallo',
    'statsEwma': 'Cadenza EWMA',
    'statsTrend': 'Tendenza',
    'statsRecentPace': 'Ritmo recente',
    'statsAverage': 'Media',
    'statsMedian': 'Mediana',
    'trendUp': 'In aumento',
    'trendDown': 'In diminuzione',
    'trendFlat': 'Stabile',
    'statsVolume': 'Panoramica volumi',
    'statsAllTime': 'Sempre',
    'statsThisWeek': 'Questa settimana',
    'statsThisMonth': 'Questo mese',
    'monthTitle': 'Lavaggi questo mese',
    'emptyNoWashes': 'Nessun lavaggio ancora',
    'emptyNoWashesMsg':
        'Inizia a registrare i lavaggi per vedere i tuoi progressi qui.',
    'emptyAddFirst': 'Aggiungi il primo lavaggio',
  };

  static const Map<String, String> _zh = {
    'appTitle': 'Hair Wash Tracker',
    'navCalendar': '日历',
    'navStats': '统计',
    'navSettings': '设置',
    'pageStatistics': '统计',
    'tooltipDataMgmt': '数据管理',
    'dataImport': '导入备份（JSON 或 CSV）',
    'dataExport': '导出备份（JSON）',
    'msgImported': '数据导入成功',
    'msgExported': '数据导出成功',
    'msgCleared': '所有数据已清除',
    'dataTitle': '数据管理',
    'dataExportDesc': '将全部记录保存为带版本号的 JSON 文件',
    'dataImportDesc': '从 JSON 备份恢复；旧版本的 CSV 备份同样可用',
    'dataClearAll': '清除所有数据',
    'dataClearConfirm': '清除数据',
    'dataClearDesc': '永久删除设备上所有已记录的洗发',
    'dataClearTitle': '清除所有数据？',
    'dataClearMsg': '此操作将永久删除所有已记录的洗发数据，且无法撤销。',
    'dlgDelete': '删除',
    'dlgCancel': '取消',
    'setAppearance': '外观',
    'setAccent': '强调色',
    'setAccentSystem': '跟随系统',
    'setAccentSystemDesc': '在 Android 12+ 上跟随壁纸，否则使用所选预设。',
    'presetWarmCoral': '暖珊瑚色',
    'presetLavender': '薰衣草紫',
    'presetSage': '鼠尾草绿',
    'presetOcean': '海洋蓝',
    'themeLight': '浅色',
    'themeDark': '深色',
    'themeAuto': '自动',
    'setLanguage': '语言',
    'setLanguageDesc': '界面语言，或跟随系统。',
    'setLangAuto': '自动（跟随系统）',
    'statsNextWash': '下次建议洗发',
    'statsKeepLogging': '继续记录洗发',
    'confLow': '置信度低',
    'confMedium': '置信度中',
    'confHigh': '置信度高',
    'statsCalcDesc': '根据你的 EWMA 模型和近期洗发节奏计算',
    'statsCadence': '洗发节奏',
    'statsInterval': '间隔',
    'statsEwma': 'EWMA 节奏',
    'statsTrend': '趋势',
    'statsRecentPace': '近期频率',
    'statsAverage': '平均',
    'statsMedian': '中位数',
    'trendUp': '上升',
    'trendDown': '下降',
    'trendFlat': '稳定',
    'statsVolume': '总量概览',
    'statsAllTime': '累计',
    'statsThisWeek': '本周',
    'statsThisMonth': '本月',
    'monthTitle': '本月洗发次数',
    'emptyNoWashes': '还没有洗发记录',
    'emptyNoWashesMsg': '开始记录洗发，进度将显示在这里。',
    'emptyAddFirst': '添加首次记录',
  };

  static const Map<String, Map<String, String>> _byCode = {
    'en': _en,
    'es': _es,
    'de': _de,
    'fr': _fr,
    'it': _it,
    'zh': _zh,
  };
}
