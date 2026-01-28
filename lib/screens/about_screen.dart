import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'What is Kundali?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                'Kundali, also known as a birth chart or horoscope, is a map of the celestial bodies at the exact moment of your birth. It shows the positions of planets, stars, and other astrological elements.',
              ),
              const SizedBox(height: 24),
              const Text(
                'The 12 Houses',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _buildHouseInfo(),
              const SizedBox(height: 24),
              const Text(
                'Planets in Vedic Astrology',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _buildPlanetInfo(),
              const SizedBox(height: 24),
              const Text(
                'About This App',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                'This app generates accurate North Indian style Kundali charts based on Vedic astrology principles. Simply enter your birth details to create your personalized cosmic blueprint.',
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
    );
  }

  Widget _buildInfoCard(String text) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          height: 1.6,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildHouseInfo() {
    final houses = [
      {'num': '1', 'name': 'Self & Personality', 'icon': Icons.person},
      {'num': '2', 'name': 'Wealth & Family', 'icon': Icons.account_balance_wallet},
      {'num': '3', 'name': 'Siblings & Communication', 'icon': Icons.chat},
      {'num': '4', 'name': 'Home & Mother', 'icon': Icons.home},
      {'num': '5', 'name': 'Children & Creativity', 'icon': Icons.child_care},
      {'num': '6', 'name': 'Health & Service', 'icon': Icons.favorite},
      {'num': '7', 'name': 'Partnership & Marriage', 'icon': Icons.favorite_border},
      {'num': '8', 'name': 'Transformation', 'icon': Icons.transform},
      {'num': '9', 'name': 'Philosophy & Higher Learning', 'icon': Icons.school},
      {'num': '10', 'name': 'Career & Reputation', 'icon': Icons.work},
      {'num': '11', 'name': 'Friends & Aspirations', 'icon': Icons.people},
      {'num': '12', 'name': 'Spirituality & Subconscious', 'icon': Icons.self_improvement},
    ];

    return Column(
      children: houses.map((house) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                house['icon'] as IconData,
                color: Colors.grey.shade700,
                size: 20,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'House ${house['num']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      house['name'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlanetInfo() {
    final planets = [
      {'name': 'Sun (Su)', 'meaning': 'Soul, ego, vitality'},
      {'name': 'Moon (Mo)', 'meaning': 'Mind, emotions, mother'},
      {'name': 'Mars (Ma)', 'meaning': 'Energy, courage, action'},
      {'name': 'Mercury (Me)', 'meaning': 'Intellect, communication'},
      {'name': 'Jupiter (Ju)', 'meaning': 'Wisdom, expansion, guru'},
      {'name': 'Venus (Ve)', 'meaning': 'Love, beauty, luxury'},
      {'name': 'Saturn (Sa)', 'meaning': 'Discipline, karma, lessons'},
      {'name': 'Rahu (Ra)', 'meaning': 'Desires, illusions'},
      {'name': 'Ketu (Ke)', 'meaning': 'Spirituality, detachment'},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: planets.map((planet) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                planet['name'] as String,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                planet['meaning'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
