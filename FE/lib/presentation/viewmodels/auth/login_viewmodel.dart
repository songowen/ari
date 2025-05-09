import 'package:ari/domain/entities/token.dart';
import 'package:ari/domain/usecases/auth/auth_usecase.dart';
import 'package:ari/domain/usecases/user/user_usecase.dart';
import 'package:ari/providers/auth/auth_providers.dart';
import 'package:ari/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

// 로그인 상태 관리 클래스
class LoginState {
  final String email;
  final String password;
  final bool isLoading;
  final String? errorMessage;

  LoginState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.errorMessage,
  });

  LoginState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// 로그인 뷰모델
class LoginViewModel extends StateNotifier<LoginState> {
  final Ref ref;
  final LoginUseCase loginUseCase;
  final SaveTokensUseCase saveTokensUseCase;
  final AuthStateNotifier authStateNotifier;
  final GetUserProfileUseCase getUserProfileUseCase;

  LoginViewModel({
    required this.ref,
    required this.loginUseCase,
    required this.saveTokensUseCase,
    required this.getUserProfileUseCase,
    required this.authStateNotifier,
  }) : super(LoginState());

  void setEmail(String value) {
    state = state.copyWith(email: value);
  }

  void setPassword(String value) {
    state = state.copyWith(password: value);
  }

  bool validateInputs() {
    if (state.email.isEmpty || state.password.isEmpty) {
      state = state.copyWith(errorMessage: '이메일과 비밀번호를 입력해주세요');
      return false;
    }
    return true;
  }

  Future<bool> login() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      // 로그인 시도
      final success = await authStateNotifier.login(state.email, state.password);
      
      if (success) {
        // 로그인 성공 시 사용자 정보 갱신
        await authStateNotifier.refreshAuthState(); 
        await ref.read(userProvider.notifier).refreshUserInfo();
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        // 로그인 실패
        state = state.copyWith(
          isLoading: false,
          errorMessage: '이메일 또는 비밀번호가 올바르지 않습니다.'
        );
        return false;
      }
    } catch (e) {
      // 오류 발생
      state = state.copyWith(
        isLoading: false,
        errorMessage: '로그인 중 오류가 발생했습니다: ${e.toString()}'
      );
      return false;
    }
  }

  // 소셜 로그인 시작 (구글)
  Future<GoogleSignInAccount?> startGoogleLogin() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      
      // 로그인이 성공했을 때만 GoogleSignInAccount 객체 반환
      if (googleUser != null) {
        return googleUser;
      } else {
        // 사용자가 로그인을 취소한 경우
        state = state.copyWith(
          isLoading: false, 
          errorMessage: '구글 로그인이 취소되었습니다.'
        );
        return null;
      }
    } catch (e) {
      // 오류 발생 시
      state = state.copyWith(
        isLoading: false,
        errorMessage: '구글 로그인 중 오류가 발생했습니다: ${e.toString()}'
      );
      return null;
    } finally {
      // 로딩 상태 해제
      if (state.isLoading) {
        state = state.copyWith(isLoading: false);
      }
    }
  }
  
  // 리다이렉트 처리
  Future<bool> handleSocialLoginCallback(Token token) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 백엔드가 제공한 토큰 처리
      await saveTokensUseCase(token);
      
      // 사용자 정보 갱신
      await authStateNotifier.refreshAuthState();
      await ref.read(userProvider.notifier).refreshUserInfo();
      
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '소셜 로그인 처리 중 오류가 발생했습니다: ${e.toString()}',
      );
      return false;
    }
  }
}