class PremiumCustomer {
  const PremiumCustomer({
    required this.name,
    required this.email,
    required this.uid,
  });

  static const PremiumCustomer empty = PremiumCustomer(
    name: '',
    email: '',
    uid: '',
  );

  static const String fallbackName = 'Floww member';

  final String name;
  final String email;
  final String uid;

  String get displayName => name.isEmpty ? fallbackName : name;
}
