import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/utils/responsive_utils.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final String privacyPolicyUrl =
      'https://echo-memory-one.vercel.app/privacy-policy.html';

  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize responsive utils
    ResponsiveUtils.init(context);

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
          child: OrientationBuilder(
            builder: (context, orientation) {
              return orientation == Orientation.portrait
                  ? _buildPortraitLayout(context)
                  : _buildLandscapeLayout(context);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    return Column(
      children: [
        _buildAppBar(context),
        Expanded(child: _buildContentContainer(context)),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return Column(
      children: [
        _buildAppBar(context),
        Expanded(
          child: Row(
            children: [
              Expanded(flex: 6, child: _buildContentContainer(context)),
              Expanded(
                flex: 4,
                child: Center(
                  child:
                      Container(
                        padding: ResponsiveUtils.padding(
                          vertical: 2,
                          horizontal: 2,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.privacy_tip,
                              size: ResponsiveUtils.fontSize(80),
                              color: Colors.white.withOpacity(0.8),
                            ),
                            SizedBox(height: ResponsiveUtils.heightPercent(2)),
                            Text(
                              'Your Privacy Matters',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.fontSize(24),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 400.ms).scale(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: ResponsiveUtils.padding(vertical: 2, horizontal: 2),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: ResponsiveUtils.fontSize(28),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: ResponsiveUtils.widthPercent(2)),
          Text(
            'Privacy Policy',
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveUtils.fontSize(24),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentContainer(BuildContext context) {
    return Container(
      margin: ResponsiveUtils.padding(vertical: 2, horizontal: 2),
      padding: ResponsiveUtils.padding(vertical: 2.5, horizontal: 2.5),
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
              fontSize: ResponsiveUtils.fontSize(24),
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ).animate().fadeIn().slideY(begin: 0.2, end: 0),
          SizedBox(height: ResponsiveUtils.heightPercent(0.8)),
          Text(
            'Last Updated: March 10, 2025',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(14),
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: ResponsiveUtils.heightPercent(2)),

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

          SizedBox(height: ResponsiveUtils.heightPercent(2)),

          Center(
            child: ElevatedButton(
              onPressed: () async {
                if (await canLaunchUrl(Uri.parse(privacyPolicyUrl))) {
                  await launchUrl(
                    Uri.parse(privacyPolicyUrl),
                    mode: LaunchMode.externalApplication,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: ResponsiveUtils.padding(horizontal: 3, vertical: 1.2),
                backgroundColor: Colors.blue[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'View Full Privacy Policy',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(16),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SizedBox(height: ResponsiveUtils.heightPercent(2)),

          Text(
            'If you have any questions about our Privacy Policy, please contact us at: privacy@echomemory.com',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(14),
              color: Colors.grey[700],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: ResponsiveUtils.padding(bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(18),
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          SizedBox(height: ResponsiveUtils.heightPercent(0.8)),
          Text(
            content,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(15),
              height: 1.5,
            ),
          ),
        ],
      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
    );
  }
}

// The privacy policy button for reuse in other screens
Widget buildPrivacyPolicyButton(BuildContext context) {
  ResponsiveUtils.init(context);

  return ListTile(
    leading: Icon(
      Icons.privacy_tip,
      color: Colors.blue[700],
      size: ResponsiveUtils.fontSize(24),
    ),
    title: Text(
      'Privacy Policy',
      style: TextStyle(fontSize: ResponsiveUtils.fontSize(16)),
    ),
    trailing: Icon(Icons.arrow_forward_ios, size: ResponsiveUtils.fontSize(16)),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
      );
    },
  );
}
