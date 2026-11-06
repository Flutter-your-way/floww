class AppSounds {
  AppSounds._();

  static const String _soundsBase = 'assets/sounds';
  static const String extension = 'wav';

  static const String chime = 'floww_chime';
  static const String ripple = 'floww_ripple';
  static const String pulse = 'floww_pulse';
  static const String bell = 'floww_bell';

  static String assetOf(String name) => '$_soundsBase/$name.$extension';

  static String fileOf(String name) => '$name.$extension';
}
