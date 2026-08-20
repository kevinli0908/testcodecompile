import 'package:flutter/material.dart';

class QuickStartGuidePage extends StatefulWidget {
  const QuickStartGuidePage({super.key});

  @override
  State<QuickStartGuidePage> createState() => _QuickStartGuidePageState();
}

class _QuickStartGuidePageState extends State<QuickStartGuidePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 8;

  final List<String> _imageList = [
    'assets/images/Slide1.PNG',
    'assets/images/Slide2.PNG',
    'assets/images/Slide3.PNG',
    'assets/images/Slide4.PNG',
    'assets/images/Slide5.PNG',
    'assets/images/Slide6.PNG',
    'assets/images/Slide7.PNG',
    'assets/images/Slide8.PNG',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // PageView
          PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: _imageList.map((imagePath) {
              return _buildPage(imagePath);
            }).toList(),
          ),

          // 底部指示器
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_totalPages, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),

          // Skip 按钮
/*          Positioned(
            top: 60,
            right: 20,
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),
          ),*/


/*          Positioned(
            bottom: 80,
            right: 24,
            child: ElevatedButton(
              onPressed: () {
                if (_currentPage < _totalPages - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  Navigator.pushReplacementNamed(context, '/home');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                _currentPage < _totalPages - 1 ? 'Next' : 'Start',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),*/
        ],
      ),
    );
  }

  Widget _buildPage(String imagePath) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图片
          Expanded(
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 80,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Image Load Fail',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
/*          const SizedBox(height: 16),
          Text(
            '${_currentPage + 1} / $_totalPages',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),*/
        ],
      ),
    );
  }
}