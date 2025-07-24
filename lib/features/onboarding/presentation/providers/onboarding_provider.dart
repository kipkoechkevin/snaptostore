import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/business_type_model.dart';

// Onboarding State
class OnboardingState {
final int currentPage;
final BusinessTypeModel? selectedBusinessType;
final bool isCompleted;
final bool isLoading;

const OnboardingState({
  this.currentPage = 0,
  this.selectedBusinessType,
  this.isCompleted = false,
  this.isLoading = false,
});

OnboardingState copyWith({
  int? currentPage,
  BusinessTypeModel? selectedBusinessType,
  bool? isCompleted,
  bool? isLoading,
}) {
  return OnboardingState(
    currentPage: currentPage ?? this.currentPage,
    selectedBusinessType: selectedBusinessType ?? this.selectedBusinessType,
    isCompleted: isCompleted ?? this.isCompleted,
    isLoading: isLoading ?? this.isLoading,
  );
}
}

// Onboarding Notifier
class OnboardingNotifier extends StateNotifier<OnboardingState> {
OnboardingNotifier() : super(const OnboardingState()) {
  _checkOnboardingStatus();
}

Future<void> _checkOnboardingStatus() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final isCompleted = prefs.getBool('onboarding_completed') ?? false;
    final businessTypeId = prefs.getString('selected_business_type');
    
    BusinessTypeModel? selectedBusiness;
    if (businessTypeId != null) {
      selectedBusiness = BusinessTypeModel.allBusinessTypes
          .where((type) => type.id == businessTypeId)
          .firstOrNull;
    }

    state = state.copyWith(
      isCompleted: isCompleted,
      selectedBusinessType: selectedBusiness,
    );
  } catch (e) {
    // Handle error
  }
}

void nextPage() {
  if (state.currentPage < 2) {
    state = state.copyWith(currentPage: state.currentPage + 1);
  }
}

void previousPage() {
  if (state.currentPage > 0) {
    state = state.copyWith(currentPage: state.currentPage - 1);
  }
}

void selectBusinessType(BusinessTypeModel businessType) {
  state = state.copyWith(selectedBusinessType: businessType);
}

Future<void> completeOnboarding() async {
  state = state.copyWith(isLoading: true);
  
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    
    if (state.selectedBusinessType != null) {
      await prefs.setString('selected_business_type', state.selectedBusinessType!.id);
    }

    state = state.copyWith(
      isCompleted: true,
      isLoading: false,
    );
  } catch (e) {
    state = state.copyWith(isLoading: false);
  }
}

void resetOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('onboarding_completed');
  await prefs.remove('selected_business_type');
  
  state = const OnboardingState();
}
}

// Providers
final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
return OnboardingNotifier();
});

final selectedBusinessTypeProvider = Provider<BusinessTypeModel?>((ref) {
return ref.watch(onboardingProvider).selectedBusinessType;
});
