import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:final_project/core/widgets/popups/snakbars.dart';
import 'package:final_project/core/widgets/screens/loading_screen.dart';
import 'package:final_project/features/auth/data/auth_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  final forgetPasswordemailController = TextEditingController();
  final forgetPasswordFormKey = GlobalKey<FormState>();
  final authRepo = AuthRepo();
  final authUser = FirebaseAuth.instance.currentUser;
  sendPasswordResetEmail(BuildContext context) async {
    try {
      emit(ForgetPasswordLoading());
      FullscreenLoader.openLoadingDialog('Check Your Email', context);
      if (!forgetPasswordFormKey.currentState!.validate()) {
        await Future.delayed(const Duration(seconds: 4));
        debugPrint('Form is not valid');
        return;
      }
      await authRepo.sendPasswordResetEmail(
        email: forgetPasswordemailController.text.trim(),
      );
      await Future.delayed(const Duration(seconds: 4));
      emit(ForgetPasswordSuccess());
    } catch (e) {
      emit(ForgetPasswordFailed(e.toString()));
    }
  }

  // Login
  final loginFormKey = GlobalKey<FormState>();
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final loginPasswordVisible = true;
  Future<void> loginWithEmailAndPassword(context) async {
    try {
      if (!loginFormKey.currentState!.validate()) return;
      emit(LoginLoading());
      FullscreenLoader.openLoadingDialog("Logging In", context);
      final userCredential = await authRepo.loginWithEmailAndPassword(
        email: loginEmailController.text.trim(),
        password: loginPasswordController.text.trim(),
      );
      debugPrint("User Credential$userCredential");
      await Future.delayed(const Duration(seconds: 4));
      emit(LoginSuccess());
    } catch (e) {
      emit(LoginFailed(e.toString()));
    }
  }

  // Register
  final registerFormKey = GlobalKey<FormState>();
  final registerNameController = TextEditingController();
  final registerEmailController = TextEditingController();
  final registerPasswordController = TextEditingController();
  final registerConfirmPasswordController = TextEditingController();
  final registerPasswordVisible = true;
  final registerConfirmPasswordVisible = true;
  Future<void> registerWithEmailAndPassword(context) async {
    try {
      if (!registerFormKey.currentState!.validate()) return;
      emit(RegisterLoading());
      FullscreenLoader.openLoadingDialog("Creating Account", context);
      final userCredential = await authRepo.registerWithEmailAndPassword(
        email: registerEmailController.text.trim(),
        password: registerPasswordController.text.trim(),
      );
      debugPrint("User Credential$userCredential");
      emit(RegisterSuccess());
      await Future.delayed(const Duration(seconds: 4));
    } catch (e) {
      emit(RegisterFailed(e.toString()));
    }
  }

  Future<void> setTimerForAutoRedirect() async {
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;

      if (user?.emailVerified ?? false) {
        timer.cancel();
        emit(EmailVerficationSuccess());
      }
    });
  }

  Future<void> sendEmailVerfication() async {
    try {
      emit(EmailVerficationLoading());
      await authRepo.sendEmailVerification();
      setTimerForAutoRedirect();
    } catch (e) {
      emit(EmailVerficationFailed(e.toString()));
    }
  }

  Future<void> googleSignIn(BuildContext context) async {
    try {
      final userCredential = await authRepo.googleSignIn();
      if (context.mounted) {
        CustomSnakbars.successSnackBar(
          context,
          title: "Login Successful",
          message: "Welcome ${userCredential.user?.displayName ?? 'User'}",
        );
      }
      // Show Success SnackBar

      emit(GoogleSignInSuccess());
    } catch (e) {
      debugPrint("Google Sign In Error: $e");
      if (context.mounted) {
        CustomSnakbars.errorSnackBar(
          context,
          title: "Login Failed",
          message: e.toString(),
        );
      }

      emit(GoogleSignInFailed(e.toString()));
    }
  }
}
