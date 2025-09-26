# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.6.2] - 2025-09-26

### Added

- New `mix tower_slack.install` task.

## [0.6.1] - 2025-05-03

### Dependencies

- Don't force dependency on `jason` package if Elixir's native `JSON` module is available

## [0.6.0] - 2025-02-19

### Added

- Includes `Tower.Event.metadata` value in the message report.

### Changed

- Slack message format updates to better resemble logger errors and messages format.
- Updates `tower` dependency from `{:tower, "~> 0.7.1"}` to `{:tower, "~> 0.7.1 or ~> 0.8.0"}`.

## [0.5.3] - 2024-11-19

### Fixed

- Properly format reported throw value

### Changed

- Updates `tower` dependency from `{:tower, "~> 0.6.0"}` to `{:tower, "~> 0.7.1"}`.

## [0.5.2] - 2024-10-24

### Fixed

- Properly report common `:gen_server` abnormal exits

## [0.5.1] - 2024-10-17

### Added

- [EXPERIMENTAL] Prevent high volume events to spam Slack

## [0.5.0] - 2024-10-07

### Added

- Can include less verbose `TowerSlack` as reporter instead of `TowerSlack.Reporter`.

### Changed

- No longer necessary to call `Tower.attach()` in your application `start`. It is done
automatically.

- Updates `tower` dependency from `{:tower, "~> 0.5.0"}` to `{:tower, "~> 0.6.0"}`.

## [0.4.0] - 2024-08-22

### Changed

- Updated namespace to avoid clashing with `Tower`:
  - Changed reporter name from `Tower.Slack.Reporter` to `TowerSlack.Reporter`.

## [0.3.0] - 2024-08-20

### Added

- Bandit support via `tower` update
- Oban support via `tower` update

### Changed

- Updates dependency to `{:tower, "~> 0.5.0"}`.

## [0.2.0] - 2024-08-16

### Changed

- Updates dependency to `{:tower, "~> 0.4.0"}`.

[0.6.2]: https://github.com/mimiquate/tower_slack/compare/v0.6.1...v0.6.2/
[0.6.1]: https://github.com/mimiquate/tower_slack/compare/v0.6.0...v0.6.1/
[0.6.0]: https://github.com/mimiquate/tower_slack/compare/v0.5.3...v0.6.0/
[0.5.3]: https://github.com/mimiquate/tower_slack/compare/v0.5.2...v0.5.3/
[0.5.2]: https://github.com/mimiquate/tower_slack/compare/v0.5.1...v0.5.2/
[0.5.1]: https://github.com/mimiquate/tower_slack/compare/v0.5.0...v0.5.1/
[0.5.0]: https://github.com/mimiquate/tower_slack/compare/v0.4.0...v0.5.0/
[0.4.0]: https://github.com/mimiquate/tower_slack/compare/v0.3.0...v0.4.0/
[0.3.0]: https://github.com/mimiquate/tower_slack/compare/v0.2.0...v0.3.0/
[0.2.0]: https://github.com/mimiquate/tower_slack/compare/v0.1.0...v0.2.0/
