// lib/features/auth/data/models/tokens_model.dart
class TokensModel {
  final String accessToken;
  final String refreshToken;
  final DateTime? accessExp; // optional: if your backend returns an ISO date

  const TokensModel({
    required this.accessToken,
    required this.refreshToken,
    this.accessExp,
  });

  factory TokensModel.fromJson(Map<String, dynamic> j) {
    // Supports flat tokens JSON ({accessToken, refreshToken, accessExp})
    // If you ever pass nested tokens ({tokens:{...}}), unwrap before calling this.
    return TokensModel(
      accessToken: j['accessToken'] as String,
      refreshToken: j['refreshToken'] as String,
      accessExp: j['accessExp'] != null
          ? DateTime.tryParse(j['accessExp'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        if (accessExp != null) 'accessExp': accessExp!.toIso8601String(),
      };
}
