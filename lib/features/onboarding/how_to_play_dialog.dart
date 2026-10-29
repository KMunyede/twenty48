import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../settings/providers/theme_provider.dart';

class HowToPlayDialog extends StatefulWidget {
  const HowToPlayDialog({super.key});

  @override
  State<HowToPlayDialog> createState() => _HowToPlayDialogState();
}

class _HowToPlayDialogState extends State<HowToPlayDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_PageData> _pages = [
    _PageData(
      title: 'Swipe to slide',
      description:
          'Swipe in any direction to slide tiles. When two tiles with the same number touch, they merge into one!',
      icon: Icons.swipe,
    ),
    _PageData(
      title: 'Keep going',
      description:
          'Merge tiles to hit milestones (512, 1024, 2048 and beyond) and earn titles. There is no final win. The game ends when no moves are left.',
      icon: Icons.emoji_events,
    ),
    _PageData(
      title: 'Helpers',
      description:
          'Use Undo to reverse moves, Swap to exchange tile positions, try Timed mode for a speed race, or solve the Daily puzzle.',
      icon: Icons.extension,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      backgroundColor: theme.backgroundColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390, maxHeight: 380),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                    final page = _pages[index];
                    return Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              page.icon,
                              size: 40,
                              color: const Color(0xFFE65100),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              page.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: theme.textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              page.description,
                              style: TextStyle(
                                color: theme.textColor.withValues(alpha: 0.8),
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (index) {
                  final isSelected = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isSelected ? 12 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE65100)
                          : theme.textColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE65100),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1 ? 'Got it' : 'Next',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageData {
  final String title;
  final String description;
  final IconData icon;

  const _PageData({
    required this.title,
    required this.description,
    required this.icon,
  });
}
