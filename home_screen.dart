import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:spacescope/main_scaffold.dart';

const Color spaceBlack = Color(0xFF020408);
const Color softGold = Color(0xFFD4AF6A);
const Color glassWhite = Color(0xFFFFFFFF);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;

  Timer? _timer;

  int _currentPage = 0;

  final List<String> _facts = [
    "NASA’s EPIC camera captures real-time images of Earth from a satellite positioned in deep space.",

    "The light from some stars takes millions of years to reach our eyes.",

    "Asteroids are leftovers from the formation of our solar system 4.6 billion years ago.",

    "One day on Venus is actually longer than one year on Earth.",

    "Neutron stars are so dense that a teaspoon of them would weigh a billion tons.",
  ];

  late final List<String> _loopedFacts;

  @override
  void initState() {
    super.initState();

    _loopedFacts = [..._facts, _facts.first];

    _pageController = PageController();

    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      _currentPage++;

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,

          duration: const Duration(milliseconds: 1200),

          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _onPageChanged(int index) {
    if (index == _loopedFacts.length - 1) {
      Future.microtask(() {
        _pageController.jumpToPage(0);

        setState(() => _currentPage = 0);
      });
    } else {
      setState(() => _currentPage = index);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();

    _pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: spaceBlack,

      body: Stack(
        fit: StackFit.expand,

        children: [
          /* ---------------- BACKGROUND IMAGE ---------------- */
          Image.asset(
            'assets/images/background.jpg',

            fit: BoxFit.cover,

            filterQuality: FilterQuality.high,
          ),

          /* ---------------- DARK OVERLAY ---------------- */
          Container(color: Colors.black.withOpacity(0.45)),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),

                child: Column(
                  children: [
                    const SizedBox(height: 100),

                    /* --- LOGO --- */
                    Image.asset(
                      'assets/images/spacescope_logo.png',

                      width: screen.width * 0.85,

                      filterQuality: FilterQuality.high,
                    ),

                    const Spacer(),

                    /* --- AUTO-LOOPING FACT CARDS --- */
                    SizedBox(
                      height: 220,

                      child: PageView.builder(
                        controller: _pageController,

                        physics: const NeverScrollableScrollPhysics(),

                        itemCount: _loopedFacts.length,

                        onPageChanged: _onPageChanged,

                        itemBuilder: (_, index) {
                          return _buildFactCard(
                            _loopedFacts[index],

                            screen.width * 0.9,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 15),

                    /* --- INDICATORS --- */
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: List.generate(
                        _facts.length,

                        (i) => _buildIndicator(i),
                      ),
                    ),

                    const Spacer(),
                    _buildStartButton(context, screen.width * 0.8),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactCard(String fact, double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),

        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),

          child: Container(
            width: width,

            padding: const EdgeInsets.all(24),

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),

              borderRadius: BorderRadius.circular(28),

              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Row(
                  children: const [
                    Icon(Icons.auto_awesome_rounded, color: softGold, size: 20),

                    SizedBox(width: 10),

                    Text(
                      'Did you know?',

                      style: TextStyle(
                        fontSize: 19,

                        fontWeight: FontWeight.w600,

                        color: softGold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Text(
                  fact,

                  style: TextStyle(
                    fontSize: 16.5,

                    height: 1.6,

                    color: Colors.white.withOpacity(0.95),

                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /* ----------------------------------------------------------
     PAGE INDICATOR
  ---------------------------------------------------------- */

  Widget _buildIndicator(int index) {
    final isActive = _currentPage == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),

      margin: const EdgeInsets.symmetric(horizontal: 4),

      height: 4,

      width: isActive ? 24 : 8,

      decoration: BoxDecoration(
        color: isActive ? softGold : glassWhite.withOpacity(0.2),

        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /* ----------------------------------------------------------
     START BUTTON
  ---------------------------------------------------------- */

  Widget _buildStartButton(BuildContext context, double width) {
    return SizedBox(
      width: width,

      height: 58,

      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,

            MaterialPageRoute(builder: (_) => const MainScaffold()),
          );
        },

        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black.withOpacity(0.4),

          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),

            side: BorderSide(color: softGold.withOpacity(0.5)),
          ),
        ),

        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Text(
              'Get Started',

              style: TextStyle(
                fontSize: 16,

                fontWeight: FontWeight.bold,

                color: softGold,

                letterSpacing: 1.5,
              ),
            ),

            SizedBox(width: 12),

            Icon(Icons.arrow_forward_rounded, color: softGold, size: 20),
          ],
        ),
      ),
    );
  }
}
