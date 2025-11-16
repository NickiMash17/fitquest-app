# Contributing to FitQuest

Thank you for considering contributing to FitQuest! This document outlines the process and guidelines.

## 🌟 Ways to Contribute

- 🐛 Report bugs
- 💡 Suggest new features
- 📝 Improve documentation
- 🔧 Submit bug fixes
- ✨ Add new features

## 🚀 Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/NickiMash17/fitquest-app.git`
3. Create a branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Commit: `git commit -m "feat: add amazing feature"`
6. Push: `git push origin feature/your-feature-name`
7. Open a Pull Request

## 📋 Development Setup

1. Ensure you have Flutter 3.16.0 or higher installed
2. Run `flutter pub get` to install dependencies
3. Set up Firebase configuration
4. Run `flutter analyze` to check for issues
5. Run `flutter test` to ensure tests pass

## 💻 Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `dart format .` before committing
- Ensure `flutter analyze` passes with no errors
- Write meaningful commit messages following [Conventional Commits](https://www.conventionalcommits.org/)

### Commit Message Format
<type>(<scope>): <subject>
<body>
<footer>
````
Types:

feat: New feature
fix: Bug fix
docs: Documentation changes
style: Code style changes (formatting)
refactor: Code refactoring
test: Adding or updating tests
chore: Maintenance tasks

Example:
feat(auth): add email verification flow

Implement email verification after user registration
Send verification email using Firebase Auth
Add verification status check on login

Closes #123
🧪 Testing Requirements

Write unit tests for new business logic
Add widget tests for new UI components
Ensure all tests pass before submitting PR
Aim for 80%+ code coverage on new code

📝 Pull Request Process

Update README.md with details of changes if needed
Update CHANGELOG.md following the format
Ensure all tests pass
Request review from maintainers
Address review feedback promptly
Squash commits before merging (if requested)

🐛 Bug Reports
When reporting bugs, please include:

Device and OS version
App version
Steps to reproduce
Expected behavior
Actual behavior
Screenshots (if applicable)
Error messages or logs

💡 Feature Requests
When suggesting features, please include:

Clear description of the feature
Use cases and benefits
Potential implementation approach
Mockups or examples (if applicable)

📧 Questions?
Feel free to open an issue with the "question" label or reach out to the maintainers.
📄 Code of Conduct

Be respectful and inclusive
Provide constructive feedback
Focus on the issue, not the person
Help create a positive environment

Thank you for contributing to FitQuest! 🌱✨

