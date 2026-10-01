import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:floww/config/constants/app_api.dart';
import 'package:floww/config/entities/onboarding_details_entity.dart';
import 'package:floww/config/services/app_api_client.dart';

import '../models/onboarding_analysis.dart';

class OnboardingException implements Exception {
  OnboardingException(this.message);

  final String message;

  @override
  String toString() => message;
}

class OnboardingService {
  OnboardingService({AppApiClient? apiClient})
    : _apiClient = apiClient ?? AppApiClient();

  final AppApiClient _apiClient;

  FirebaseAuth get _auth => FirebaseAuth.instance;

  Map<String, dynamic> _detailsOf(Map<String, dynamic> answers) {
    final now = DateTime.now();
    return OnboardingDetailsEntity.fromAnswers(
      uid: _auth.currentUser!.uid,
      answers: answers,
      startedAt: now,
      completedAt: now,
      updatedAt: now,
    ).toJson();
  }

  Future<OnboardingAnalysis> analyzeOnboardingAnswers(
    Map<String, dynamic> answers,
  ) async {
    try {
      final data = await _apiClient.post(
        AppApi.analyzeOnboarding,
        body: {'details': _detailsOf(answers)},
        timeout: AppApi.aiResponseTimeout,
      );
      return OnboardingAnalysis.fromJson(data);
    } on AppApiException catch (e) {
      throw OnboardingException(e.message);
    } catch (e, stackTrace) {
      debugPrint('analyzeOnboardingAnswers failed: $e\n$stackTrace');
      throw OnboardingException(
        'WAVE could not analyze your profile. Please try again.',
      );
    }
  }

  Future<void> submitOnboardingAnswers(Map<String, dynamic> answers) async {
    try {
      await _apiClient.post(
        AppApi.submitOnboarding,
        body: {'details': _detailsOf(answers)},
      );
    } catch (e, stackTrace) {
      debugPrint('submitOnboardingAnswers failed: $e\n$stackTrace');
      throw OnboardingException(
        'Could not save your answers. Please try again.',
      );
    }
  }

  Future<void> markWearablesStepDone(bool connected) async {
    try {
      await _apiClient.post(
        AppApi.completeOnboarding,
        body: {'wearablesConnected': connected},
      );
    } catch (e, stackTrace) {
      debugPrint('markWearablesStepDone failed: $e\n$stackTrace');
      throw OnboardingException('Something went wrong. Please try again.');
    }
  }
}
