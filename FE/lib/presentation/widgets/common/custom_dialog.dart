import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CustomDialog extends StatelessWidget {
  final String title; // 다이얼로그 제목
  final String? content; // 다이얼로그 내용
  final Widget? customContent; // 컨텐츠 위젯 (텍스트 대신 복잡한 내용 표시)
  final String confirmText; // 확인 버튼 텍스트 (기본값: '확인')
  final String cancelText; // 취소 버튼 텍스트 (기본값: '취소')
  final Color confirmButtonColor; // 확인 버튼 색상
  final Color cancelButtonColor; // 취소 버튼 색상
  final Color textColor; // 텍스트 색상 (제목, 내용)
  final VoidCallback? onConfirm; // 확인 버튼 클릭 시 콜백 함수
  final VoidCallback? onCancel; // 취소 버튼 클릭 시 콜백 함수

  // 아래 한 줄은 단일 버튼 모드
  final bool singleButtonMode; // true: 확인 버튼만 표시, false: 확인/취소 버튼 모두 표시

  final double buttonSpacing; // 버튼 사이의 간격
  final EdgeInsets contentPadding; // 다이얼로그 내부 패딩
  final double borderRadius; // 다이얼로그 모서리 둥글기 정도

  // 추가된 속성: 그라데이션 설정
  final Gradient? confirmButtonGradient; // 확인 버튼 그라데이션
  final Gradient? cancelButtonGradient; // 취소 버튼 그라데이션

  // 투명도 관련
  final double titleOpacity; // 제목 배경 투명도
  final Color titleBackgroundColor; // 제목 배경 색상
  final double dialogOpacity; // 다이얼로그 배경 투명도
  final Color dialogBackgroundColor; // 다이얼로그 배경 색상
  final double contentOpacity; // 컨텐츠 영역 배경 투명도

  const CustomDialog({
    super.key,
    required this.title,
    this.content,
    this.customContent,
    this.confirmText = '확인',
    this.cancelText = '취소',
    this.confirmButtonColor = AppColors.lightPurple,
    this.cancelButtonColor = const Color.fromRGBO(158, 158, 158, 1),
    this.textColor = Colors.black87,
    this.onConfirm,
    this.onCancel,
    this.singleButtonMode = false,
    this.buttonSpacing = 10.0,
    this.contentPadding = const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
    this.borderRadius = 16.0,
    this.confirmButtonGradient,
    this.cancelButtonGradient,
    this.titleOpacity = 0.65, // 제목 불투명도
    this.titleBackgroundColor = Colors.black,
    this.dialogOpacity = 0.6, // 불투명도
    this.dialogBackgroundColor = Colors.black,
    this.contentOpacity = 0.75, // 내용 불투명도
  }) : assert(
         content != null || customContent != null,
         '내용 또는 컨텐츠 중 하나는 넣어줘야 함',
       );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 30.0,
        vertical: 24.0,
      ),
      child: _buildDialogContent(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: dialogBackgroundColor.withOpacity(dialogOpacity),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 제목 부분
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            decoration: BoxDecoration(
              color: titleBackgroundColor.withOpacity(titleOpacity),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(borderRadius),
                topRight: Radius.circular(borderRadius),
              ),
            ),
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // 내용 부분과 버튼 부분
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(contentOpacity),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(borderRadius),
                bottomRight: Radius.circular(borderRadius),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 내용 부분
                Padding(
                  padding: contentPadding,
                  child:
                      customContent ??
                      Text(
                        content!,
                        style: TextStyle(fontSize: 16, color: textColor),
                        textAlign: TextAlign.center,
                      ),
                ),

                // 버튼 부분
                Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
                  child: Builder(
                    builder:
                        (context) =>
                            singleButtonMode
                                ? _buildSingleButton(context)
                                : _buildTwoButtons(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleButton(BuildContext context) {
    // 그라데이션이 있는 경우
    if (confirmButtonGradient != null) {
      return SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: confirmButtonGradient,
            borderRadius: BorderRadius.circular(borderRadius / 2),
          ),
          child: ElevatedButton(
            onPressed: () {
              if (onConfirm != null) {
                onConfirm!();
              }
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius / 2),
              ),
            ),
            child: Text(
              confirmText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    // 기존 단색 버튼
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (onConfirm != null) {
            onConfirm!();
          }
          Navigator.of(context).pop(true);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: confirmButtonColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius / 2),
          ),
        ),
        child: Text(
          confirmText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTwoButtons(BuildContext context) {
    return Row(
      children: [
        // 취소 버튼
        Expanded(
          child:
              cancelButtonGradient != null
                  ? DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: cancelButtonGradient,
                      borderRadius: BorderRadius.circular(borderRadius / 2),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (onCancel != null) {
                          onCancel!();
                        }
                        Navigator.of(context).pop(false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(borderRadius / 2),
                        ),
                      ),
                      child: Text(
                        cancelText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                  : ElevatedButton(
                    onPressed: () {
                      if (onCancel != null) {
                        onCancel!();
                      }
                      Navigator.of(context).pop(false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cancelButtonColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius / 2),
                      ),
                    ),
                    child: Text(
                      cancelText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
        ),

        SizedBox(width: buttonSpacing),

        // 확인 버튼
        Expanded(
          child:
              confirmButtonGradient != null
                  ? DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: confirmButtonGradient,
                      borderRadius: BorderRadius.circular(borderRadius / 2),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (onConfirm != null) {
                          onConfirm!();
                        }
                        Navigator.of(context).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(borderRadius / 2),
                        ),
                      ),
                      child: Text(
                        confirmText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                  : ElevatedButton(
                    onPressed: () {
                      if (onConfirm != null) {
                        onConfirm!();
                      }
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmButtonColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius / 2),
                      ),
                    ),
                    child: Text(
                      confirmText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
        ),
      ],
    );
  }
}

// 확장 메서드(다이얼로그 쉽게 호출 가능)
// 원본 클래스 수정하지 않아도 기능 확장 가능

extension CustomDialogExtension on BuildContext {
  // 커스텀 다이얼로그
  Future<bool?> showCustomDialog({
    required String title,
    String? content,
    Widget? customContent,
    String confirmText = '확인',
    String cancelText = '취소',
    Color confirmButtonColor = Colors.blue,
    Color cancelButtonColor = Colors.black54,
    Color textColor = Colors.black87,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool singleButtonMode = false,
    Gradient? confirmButtonGradient,
    Gradient? cancelButtonGradient,
    double titleOpacity = 0.65,
    Color titleBackgroundColor = Colors.black,
    double dialogOpacity = 0.6,
    Color dialogBackgroundColor = Colors.black,
    double contentOpacity = 0.75,
    double borderRadius = 16.0,
  }) {
    return showDialog<bool>(
      context: this,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomDialog(
          title: title,
          content: content,
          customContent: customContent,
          confirmText: confirmText,
          cancelText: cancelText,
          confirmButtonColor: confirmButtonColor,
          cancelButtonColor: cancelButtonColor,
          textColor: textColor,
          onConfirm: onConfirm,
          onCancel: onCancel,
          singleButtonMode: singleButtonMode,
          confirmButtonGradient: confirmButtonGradient,
          cancelButtonGradient: cancelButtonGradient,
          titleOpacity: titleOpacity,
          titleBackgroundColor: titleBackgroundColor,
          dialogOpacity: dialogOpacity,
          dialogBackgroundColor: dialogBackgroundColor,
          contentOpacity: contentOpacity,
          borderRadius: borderRadius,
        );
      },
    );
  }

  // 확인만 있는 간단한 다이얼로그
  Future<void> showAlertDialog({
    required String title,
    required String content,
    String confirmText = '확인',
    Color confirmButtonColor = Colors.blue,
    VoidCallback? onConfirm,
    Gradient? confirmButtonGradient,
    double titleOpacity = 0.65,
    Color titleBackgroundColor = Colors.black,
    double dialogOpacity = 0.6,
    Color dialogBackgroundColor = Colors.black,
    double contentOpacity = 0.75,
    double borderRadius = 16.0,
  }) {
    return showDialog<void>(
      context: this,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomDialog(
          title: title,
          content: content,
          confirmText: confirmText,
          confirmButtonColor: confirmButtonColor,
          onConfirm: onConfirm,
          singleButtonMode: true,
          confirmButtonGradient: confirmButtonGradient,
          titleOpacity: titleOpacity,
          titleBackgroundColor: titleBackgroundColor,
          dialogOpacity: dialogOpacity,
          dialogBackgroundColor: dialogBackgroundColor,
          contentOpacity: contentOpacity,
          borderRadius: borderRadius,
        );
      },
    );
  }

  // 확인/취소가 있는 다이얼로그
  Future<bool?> showConfirmDialog({
    required String title,
    required String content,
    String confirmText = '확인',
    String cancelText = '취소',
    Color confirmButtonColor = Colors.blue,
    Color cancelButtonColor = Colors.grey,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Gradient? confirmButtonGradient,
    Gradient? cancelButtonGradient,
    double titleOpacity = 0.65,
    Color titleBackgroundColor = Colors.black,
    double dialogOpacity = 0.6,
    Color dialogBackgroundColor = Colors.black,
    double contentOpacity = 0.75,
    double borderRadius = 16.0,
  }) {
    return showDialog<bool>(
      context: this,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomDialog(
          title: title,
          content: content,
          confirmText: confirmText,
          cancelText: cancelText,
          confirmButtonColor: confirmButtonColor,
          cancelButtonColor: cancelButtonColor,
          onConfirm: onConfirm,
          onCancel: onCancel,
          singleButtonMode: false,
          confirmButtonGradient: confirmButtonGradient,
          cancelButtonGradient: cancelButtonGradient,
          titleOpacity: titleOpacity,
          titleBackgroundColor: titleBackgroundColor,
          dialogOpacity: dialogOpacity,
          dialogBackgroundColor: dialogBackgroundColor,
          contentOpacity: contentOpacity,
          borderRadius: borderRadius,
        );
      },
    );
  }
}
