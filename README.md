# TowerSlack

[![ci](https://github.com/mimiquate/tower_slack/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/mimiquate/tower_slack/actions?query=branch%3Amain)
[![Hex.pm](https://img.shields.io/hexpm/v/tower_slack.svg)](https://hex.pm/packages/tower_slack)
[![Documentation](https://img.shields.io/badge/Documentation-purple.svg)](https://hexdocs.pm/tower_slack)

Error tracking and reporting to Slack.

A simple [post-to-Slack](https://api.slack.com/messaging/webhooks) reporter for [Tower](https://github.com/mimiquate/tower) error handler.

## Installation

The package can be installed by adding `tower_slack` to your list of dependencies in `mix.exs`:

```elixir
# mix.exs

def deps do
  [
    {:tower_slack, "~> 0.5.1"}
  ]
end
```

## Usage

Register the reporter with Tower.

```elixir
# config/config.exs

config(
  :tower,
  :reporters,
  [
    # along any other possible reporters
    TowerSlack
  ]
)
```

And make any additional configurations specific to this reporter.

```elixir
# config/runtime.exs

config :tower_slack,
  otp_app: :your_app,
  webhook_url: System.get_env("TOWER_SLACK_WEBHOOK_URL"),
  environment: System.get_env("DEPLOYMENT_ENV", to_string(config_env()))
```

Instructions to create the Slack Webhook URL in https://api.slack.com/messaging/webhooks.

## License

Copyright 2024 Mimiquate

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
