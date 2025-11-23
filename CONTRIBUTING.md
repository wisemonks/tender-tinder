# Contributing to Tender Tinder

First off, thank you for considering contributing to Tender Tinder! 🔥

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for everyone.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include:

- **Clear title** - Descriptive summary of the issue
- **Steps to reproduce** - Detailed steps to reproduce the behavior
- **Expected behavior** - What you expected to happen
- **Actual behavior** - What actually happened
- **Environment** - Ruby version, Rails version, OS, etc.
- **Screenshots** - If applicable

### Suggesting Features

Feature suggestions are welcome! Please:

- Use a clear and descriptive title
- Provide a detailed description of the proposed feature
- Explain why this feature would be useful
- Include mockups or examples if applicable

### Pull Requests

1. **Fork the repository** and create your branch from `main`
   ```bash
   git checkout -b feature/amazing-feature
   ```

2. **Set up your development environment**
   ```bash
   bundle install
   rails db:create db:migrate
   ```

3. **Make your changes**
   - Write clean, readable code
   - Follow Ruby and Rails conventions
   - Add tests for new features
   - Update documentation as needed

4. **Test your changes**
   ```bash
   rails test
   rubocop
   ```

5. **Commit your changes**
   ```bash
   git commit -m "Add amazing feature"
   ```

   Use clear commit messages:
   - `feat: Add email notification preferences`
   - `fix: Resolve scraping timeout issue`
   - `docs: Update deployment instructions`
   - `refactor: Improve search performance`

6. **Push to your fork**
   ```bash
   git push origin feature/amazing-feature
   ```

7. **Open a Pull Request**
   - Provide a clear title and description
   - Reference any related issues
   - Include screenshots for UI changes

## Development Guidelines

### Code Style

- Follow the [Ruby Style Guide](https://rubystyle.guide/)
- Use RuboCop for linting: `rubocop`
- Keep methods small and focused
- Write descriptive variable names

### Testing

- Write tests for new features
- Ensure all tests pass before submitting PR
- Aim for meaningful test coverage

### Commit Messages

- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit first line to 72 characters
- Reference issues and pull requests after the first line

### Documentation

- Update README.md for significant changes
- Add inline comments for complex logic
- Update configuration examples if needed

## Project Structure

```
app/
├── controllers/     # HTTP request handlers
├── models/          # Data models and business logic
├── services/        # Service objects (scraping, search)
├── jobs/            # Background job definitions
├── mailers/         # Email templates and logic
└── views/           # UI templates

config/
├── deploy.yml       # Kamal deployment config
└── recurring.yml    # Scheduled jobs config

db/
├── migrate/         # Database migrations
└── schema.rb        # Current database schema
```

## Getting Help

- Check the [README.md](README.md) for setup instructions
- Review existing [issues](../../issues)
- Ask questions in [discussions](../../discussions)

## Recognition

Contributors will be recognized in:
- The project's README
- Release notes for significant contributions

Thank you for contributing to Tender Tinder! 🚀
