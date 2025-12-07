import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_spacing.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service',
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
              title: '1. Acceptance of Terms',
              content: '''
By downloading, installing, or using FitQuest, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the app.
              ''',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '2. Description of Service',
              content: '''
FitQuest is a wellness and fitness tracking application that allows users to:
• Log fitness activities and wellness habits
• Track progress and earn achievements
• Set and monitor goals
• Participate in community features
              ''',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '3. User Accounts',
              content: '''
• You are responsible for maintaining the confidentiality of your account
• You are responsible for all activities that occur under your account
• You must be at least 13 years old to use this service
• You agree to provide accurate and complete information
              ''',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '4. User Conduct',
              content: '''
You agree not to:
• Use the service for any illegal purpose
• Attempt to gain unauthorized access to the service
• Interfere with or disrupt the service
• Create false or misleading information
• Harass, abuse, or harm other users
              ''',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '5. Intellectual Property',
              content: '''
• All content and features of FitQuest are owned by us or our licensors
• You may not copy, modify, or distribute any part of the service
• You retain ownership of any content you create within the app
              ''',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '6. Disclaimer of Warranties',
              content: '''
The service is provided "as is" without warranties of any kind. We do not guarantee that:
• The service will be uninterrupted or error-free
• The results obtained from using the service will be accurate or reliable
• Any defects will be corrected
              ''',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '7. Limitation of Liability',
              content: '''
To the maximum extent permitted by law, we shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of the service.
              ''',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '8. Termination',
              content: '''
We may terminate or suspend your account and access to the service immediately, without prior notice, for any breach of these Terms of Service.
              ''',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '9. Changes to Terms',
              content: '''
We reserve the right to modify these terms at any time. Your continued use of the service after changes constitutes acceptance of the new terms.
              ''',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '10. Contact Information',
              content: '''
If you have any questions about these Terms of Service, please contact us at:
Email: support@fitquest.app
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

