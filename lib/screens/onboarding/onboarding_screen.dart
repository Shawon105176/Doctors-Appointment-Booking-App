import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctor_appointments/screens/auth/login_screen.dart';
import 'package:doctor_appointments/utils/theme.dart';
import 'package:doctor_appointments/services/preferences_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
    final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Find Trusted Doctors',
      description: 'Connect with certified healthcare professionals in your area and book appointments easily.',
      icon: Icons.search,
      color: const Color(0xFF667eea), // Use direct color for testing
    ),
    OnboardingData(
      title: 'Easy Appointment Booking',
      description: 'Schedule appointments at your convenience with our simple and intuitive booking system.',
      icon: Icons.calendar_today,
      color: const Color(0xFF4FD1C7), // Use direct color for testing
    ),
    OnboardingData(
      title: 'Manage Your Health',
      description: 'Keep track of your appointments, medical history, and get personalized health tips.',
      icon: Icons.health_and_safety,
      color: const Color(0xFF38A169), // Use direct color for testing
    ),
  ];
  @override
  Widget build(BuildContext context) {
    print('DEBUG: OnboardingScreen build called');
    print('DEBUG: Pages count: ${_pages.length}');
    print('DEBUG: Current page: $_currentPage');
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF7FAFC),
              Color(0xFFEDF2F7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _skipToLogin,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),
              
              // Bottom Section
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Page Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildPageIndicators(),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _currentPage == _pages.length - 1
                            ? _completeOnboarding
                            : _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _pages[_currentPage].color,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1
                              ? 'Get Started'
                              : 'Next',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    
                    if (_currentPage < _pages.length - 1) ...[
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _skipToLogin,
                        child: const Text(
                          'Skip for now',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildPage(OnboardingData data) {
    print('DEBUG: Building page for: ${data.title}');
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with Animation
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: data.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: data.color.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    data.icon,
                    size: 60,
                    color: data.color,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 48),
          
          // Title
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Description
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Text(
                  data.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageIndicators() {
    return List.generate(_pages.length, (index) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: _currentPage == index ? 24 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: _currentPage == index
              ? _pages[_currentPage].color
              : Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    });
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _skipToLogin() {
    _completeOnboarding();
  }

  void _completeOnboarding() async {
    final prefsService = Get.find<PreferencesService>();
    await prefsService.setFirstTime(false);
    Get.off(() => const LoginScreen());
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
