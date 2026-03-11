# PorchLightSoftwareCommon — Project Context for AI Agents

This is the shared infrastructure repository for Porch Light Software iOS apps.
It uses the Asimov AI Agent Framework.

## Purpose

Shared Fastlane configuration, CI/CD workflows, scripts, and documentation
used by FastTrack, MoodTrack, and SubTrack.

## Available Agents (installed plugins)

- **asimov-core**: Hari (Software Architect), Giskard (Code Reviewer), Gaal (Business Analyst)
- **asimov-flutter**: Elijah (Flutter Developer)

## Asimov Resources

Templates and documentation: `~/.asimov/`
- **Templates:** `~/.asimov/templates/` (A100, D100, D101)
- **Protocols:** `~/.asimov/protocols/`

## Repository Structure

- `fastlane/` — Shared Fastlane configuration (SharedFastfile, publisher.rb)
- `scripts/` — Automation scripts (screenshots, deployment)
- `docs/` — Submission guides and publisher info
- `.github/workflows/` — Reusable GitHub Actions workflows

## How Apps Reference This Repo

Apps must be checked out as siblings under the same parent folder.
In each app's `ios/fastlane/Fastfile`:
```ruby
import "../../../../PorchLightSoftwareCommon/fastlane/SharedFastfile"
```

GitHub Actions CD uses:
```yaml
uses: Porch-Light-Software/PorchLightSoftwareCommon/.github/workflows/flutter-ios-deploy.yml@main
```
