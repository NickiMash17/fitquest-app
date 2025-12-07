import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_spacing.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '1. Information We Collect',
              content: '''
We collect information that you provide directly to us, including:
• Account information (email address, display name)
• Activity data (exercise, meditation, hydration, sleep records)
• Progress and achievement data
• Preferences and settings
              ''',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '2. How We Use Your Information',
              content: '''
We use the information we collect to:
• Provide, maintain, and improve our services
• Track your progress and achievements
• Personalize your experience
• Send you notifications and updates (with your consent)
• Analyze usage patterns to improve the app
              ''',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '3. Data Storage and Security',
              content: '''
Your data is stored securely using Firebase services:
• All data is encrypted in transit
• Authentication is handled securely
• We implement appropriate security measures to protect your information
• You can delete your account and data at any time
              ''',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '4. Third-Party Services',
              content: '''
We use the following third-party services:
• Firebase (authentication, database, analytics)
• These services have their own privacy policies
• We do not sell your personal information to third parties
              ''',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '5. Your Rights',
              content: '''
You have the right to:
• Access your personal data
• Correct inaccurate data
• Delete your account and data
• Opt-out of certain data collection
• Export your data
              ''',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '6. Children\'s Privacy',
              content: '''
Our app is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13.
              ''',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '7. Changes to This Policy',
              content: '''
We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date.
              ''',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '8. Contact Us',
              content: '''
If you have any questions about this Privacy Policy, please contact us at:
Email: privacy@fitquest.app
              ''',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

