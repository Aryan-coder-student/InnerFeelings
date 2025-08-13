import 'package:flutter/foundation.dart';

class OnboardingService extends ChangeNotifier {
  String? _primaryGoal;
  int? _emotionalWellbeingRating;
  String? _wellbeingReason;
  List<String> _selectedEmotions = [];
  List<String> _selectedLifeAreas = [];
  bool _isOnboardingComplete = false;

  // Getters
  String? get primaryGoal => _primaryGoal;
  int? get emotionalWellbeingRating => _emotionalWellbeingRating;
  String? get wellbeingReason => _wellbeingReason;
  List<String> get selectedEmotions => _selectedEmotions;
  List<String> get selectedLifeAreas => _selectedLifeAreas;
  bool get isOnboardingComplete => _isOnboardingComplete;

  // Setters
  void setPrimaryGoal(String goal) {
    _primaryGoal = goal;
    notifyListeners();
  }

  void setEmotionalWellbeingRating(int rating) {
    _emotionalWellbeingRating = rating;
    notifyListeners();
  }

  void setWellbeingReason(String reason) {
    _wellbeingReason = reason;
    notifyListeners();
  }

  void setSelectedEmotions(List<String> emotions) {
    _selectedEmotions = emotions;
    notifyListeners();
  }

  void setSelectedLifeAreas(List<String> lifeAreas) {
    _selectedLifeAreas = lifeAreas;
    notifyListeners();
  }

  void completeOnboarding() {
    _isOnboardingComplete = true;
    notifyListeners();
  }

  void resetOnboarding() {
    _primaryGoal = null;
    _emotionalWellbeingRating = null;
    _wellbeingReason = null;
    _selectedEmotions = [];
    _selectedLifeAreas = [];
    _isOnboardingComplete = false;
    notifyListeners();
  }

  // Get all onboarding data as a map
  Map<String, dynamic> getOnboardingData() {
    return {
      'primaryGoal': _primaryGoal,
      'emotionalWellbeingRating': _emotionalWellbeingRating,
      'wellbeingReason': _wellbeingReason,
      'selectedEmotions': _selectedEmotions,
      'selectedLifeAreas': _selectedLifeAreas,
      'isOnboardingComplete': _isOnboardingComplete,
    };
  }

  // Set all onboarding data from a map
  void setOnboardingData(Map<String, dynamic> data) {
    _primaryGoal = data['primaryGoal'];
    _emotionalWellbeingRating = data['emotionalWellbeingRating'];
    _wellbeingReason = data['wellbeingReason'];
    _selectedEmotions = List<String>.from(data['selectedEmotions'] ?? []);
    _selectedLifeAreas = List<String>.from(data['selectedLifeAreas'] ?? []);
    _isOnboardingComplete = data['isOnboardingComplete'] ?? false;
    notifyListeners();
  }
}
