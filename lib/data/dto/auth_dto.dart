/// Authentication Data Transfer Objects for Echo Memory
/// Models for login, registration, and user data

import 'package:equatable/equatable.dart';

/// User DTO from API
class UserDTO extends Equatable {
  final String id;
  final String displayName;
  final String authProvider;
  final bool isGuest;
  final String? email;
  final String? avatarUrl;

  const UserDTO({
    required this.id,
    required this.displayName,
    required this.authProvider,
    required this.isGuest,
    this.email,
    this.avatarUrl,
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: json['id'] ?? '',
      displayName: json['displayName'] ?? 'Player',
      authProvider: json['authProvider'] ?? 'GUEST',
      isGuest: json['isGuest'] ?? true,
      email: json['email'],
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'authProvider': authProvider,
        'isGuest': isGuest,
        'email': email,
        'avatarUrl': avatarUrl,
      };

  @override
  List<Object?> get props => [id, displayName, authProvider, isGuest, email, avatarUrl];
}

/// Login response DTO
class LoginResponseDTO extends Equatable {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final UserDTO user;

  const LoginResponseDTO({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  factory LoginResponseDTO.fromJson(Map<String, dynamic> json) {
    return LoginResponseDTO(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      expiresIn: json['expiresIn'] ?? 900,
      user: UserDTO.fromJson(json['user'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresIn, user];
}

/// Guest login request
class GuestLoginRequest {
  final String displayName;

  const GuestLoginRequest({required this.displayName});

  Map<String, dynamic> toJson() => {'displayName': displayName};
}

/// Google login request
class GoogleLoginRequest {
  final String idToken;
  final String? displayName;

  const GoogleLoginRequest({required this.idToken, this.displayName});

  Map<String, dynamic> toJson() => {
        'idToken': idToken,
        if (displayName != null) 'displayName': displayName,
      };
}

/// Email registration request
class EmailRegisterRequest {
  final String email;
  final String password;
  final String displayName;

  const EmailRegisterRequest({
    required this.email,
    required this.password,
    required this.displayName,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'displayName': displayName,
      };
}

/// Email login request
class EmailLoginRequest {
  final String email;
  final String password;

  const EmailLoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

/// Link account request
class LinkAccountRequest {
  final String linkType; // 'google' or 'email'
  final String? googleIdToken;
  final String? email;
  final String? password;

  const LinkAccountRequest({
    required this.linkType,
    this.googleIdToken,
    this.email,
    this.password,
  });

  Map<String, dynamic> toJson() {
    if (linkType == 'google') {
      return {
        'linkType': linkType,
        'googleIdToken': googleIdToken,
      };
    } else {
      return {
        'linkType': linkType,
        'email': email,
        'password': password,
      };
    }
  }
}

/// Refresh token request
class RefreshTokenRequest {
  final String refreshToken;

  const RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}
