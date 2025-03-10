import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final String privacyPolicyUrl =
      'https://echo-memory-one.vercel.app/privacy-policy.html';

  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[300]!, Colors.purple[300]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Privacy Policy',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ListView(
                    children: [
                      Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                      SizedBox(height: 8),
                      Text(
                        'Last Updated: March 10, 2025',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: 20),

                      _buildSection(
                        'Introduction',
                        'Thank you for choosing Echo Memory. This Privacy Policy explains how we collect, use, and protect your information when you use our app.',
                      ),

                      _buildSection(
                        'Information We Collect',
                        'We collect minimal personal information:\n\n'
                            '• Game Progress Data: We store your game progress, scores, achievements, and settings locally on your device.\n\n'
                            '• Device Information: We may collect basic device information to improve app performance.',
                      ),

                      _buildSection(
                        'How We Use Your Information',
                        'We use the information to:\n\n'
                            '• Provide and maintain the game\n'
                            '• Save your game progress and settings\n'
                            '• Track achievements and high scores\n'
                            '• Improve the game based on user interaction\n'
                            '• Address technical issues',
                      ),

                      _buildSection(
                        'Data Storage',
                        'Echo Memory stores your game data locally on your device using standard storage mechanisms. This includes:\n\n'
                            '• Game progress\n'
                            '• High scores\n'
                            '• Difficulty settings\n'
                            '• Achievement data\n'
                            '• Daily challenge results',
                      ),

                      SizedBox(height: 20),

                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (await canLaunchUrl(
                              Uri.parse(privacyPolicyUrl),
                            )) {
                              await launchUrl(
                                Uri.parse(privacyPolicyUrl),
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            backgroundColor: Colors.blue[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'View Full Privacy Policy',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      Text(
                        'If you have any questions about our Privacy Policy, please contact us at: privacy@echomemory.com',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          SizedBox(height: 8),
          Text(content, style: TextStyle(fontSize: 15, height: 1.5)),
        ],
      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
    );
  }
}

// Add this button to your settings or about screen
Widget _buildPrivacyPolicyButton(BuildContext context) {
  return ListTile(
    leading: Icon(Icons.privacy_tip, color: Colors.blue[700]),
    title: Text('Privacy Policy'),
    trailing: Icon(Icons.arrow_forward_ios, size: 16),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
      );
    },
  );
}
