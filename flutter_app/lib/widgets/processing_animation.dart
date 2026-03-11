// Processing Animation Widget - Engaging loading animations during try-on
import 'dart:math';
import 'package:flutter/material.dart';

/// Processing steps shown during try-on
enum ProcessingStep {
  analyzing,      // "Analyzing your style..."
  segmenting,     // "Preparing the garment..."
  creating,       // "Creating your look..."
  finishing,      // "Adding final touches..."
  completed,      // "Your look is ready!"
}

/// Beautiful animated loading widget for the try-on processing screen
class TryOnProcessingAnimation extends StatefulWidget {
  final ProcessingStep currentStep;
  final VoidCallback? onComplete;
  
  const TryOnProcessingAnimation({
    super.key,
    this.currentStep = ProcessingStep.analyzing,
    this.onComplete,
  });
  
  @override
  State<TryOnProcessingAnimation> createState() => _TryOnProcessingAnimationState();
}

class _TryOnProcessingAnimationState extends State<TryOnProcessingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Pulse animation for the icon
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Rotation animation for the outer ring
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );
    
    // Progress animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _progressController.dispose();
    super.dispose();
  }
  
  String get _stepTitle {
    switch (widget.currentStep) {
      case ProcessingStep.analyzing:
        return 'Analyzing your style...';
      case ProcessingStep.segmenting:
        return 'Preparing the garment...';
      case ProcessingStep.creating:
        return 'Creating your look...';
      case ProcessingStep.finishing:
        return 'Adding final touches...';
      case ProcessingStep.completed:
        return 'Your look is ready!';
    }
  }
  
  String get _stepEmoji {
    switch (widget.currentStep) {
      case ProcessingStep.analyzing:
        return '👁️';
      case ProcessingStep.segmenting:
        return '✂️';
      case ProcessingStep.creating:
        return '✨';
      case ProcessingStep.finishing:
        return '🎨';
      case ProcessingStep.completed:
        return '🎉';
    }
  }
  
  double get _stepProgress {
    switch (widget.currentStep) {
      case ProcessingStep.analyzing:
        return 0.2;
      case ProcessingStep.segmenting:
        return 0.4;
      case ProcessingStep.creating:
        return 0.7;
      case ProcessingStep.finishing:
        return 0.9;
      case ProcessingStep.completed:
        return 1.0;
    }
  }
  
  List<String> get _funFacts => [
    '💡 Virtual try-on uses AI to visualize clothes on you',
    '👗 We process over 500 data points to create your look',
    '🎯 Our AI ensures accurate color and fit representation',
    '✨ Each try-on is uniquely personalized to you',
    '🌍 You can try clothes from anywhere in the world',
    '🛍️ Find similar items online with one tap',
  ];
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main animation
          _buildMainAnimation(),
          const SizedBox(height: 48),
          
          // Progress indicator
          _buildProgressSection(),
          const SizedBox(height: 32),
          
          // Status text
          _buildStatusText(),
          const SizedBox(height: 48),
          
          // Fun fact
          _buildFunFact(),
        ],
      ),
    );
  }
  
  Widget _buildMainAnimation() {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer rotating ring
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        Colors.purple.withOpacity(0.3),
                        Colors.blue.withOpacity(0.5),
                        Colors.cyan.withOpacity(0.3),
                        Colors.purple.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Inner pulsing circle
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.blue.withOpacity(0.3),
                        Colors.purple.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Center icon
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1A1A2E),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _stepEmoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressSection() {
    return Column(
      children: [
        // Progress bar
        Container(
          width: 280,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                width: 280 * _stepProgress,
                height: 6,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.purple, Colors.blue, Colors.cyan],
                  ),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyan.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Step indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: ProcessingStep.values.take(4).map((step) {
            final isCompleted = step.index < widget.currentStep.index;
            final isCurrent = step == widget.currentStep;
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? Colors.cyan
                    : isCurrent
                        ? Colors.purple
                        : Colors.white.withOpacity(0.3),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.6),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildStatusText() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        _stepTitle,
        key: ValueKey(widget.currentStep),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  Widget _buildFunFact() {
    final random = Random();
    final fact = _funFacts[random.nextInt(_funFacts.length)];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Text(
        fact,
        style: TextStyle(
          fontSize: 14,
          color: Colors.white.withOpacity(0.7),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Helper widget for animation builder (Flutter 3.x compatible)
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  
  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
  }) : super(listenable: animation);
  
  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}
