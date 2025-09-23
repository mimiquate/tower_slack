if Code.ensure_loaded?(Igniter) and
     Code.ensure_loaded?(Tower.Igniter) and
     function_exported?(Tower.Igniter, :runtime_configure_reporter, 3) do
  defmodule Mix.Tasks.TowerSlack.Install do
    @example "mix igniter.install tower_slack"

    @shortdoc "Installs TowerSlack. Invoke with `mix igniter.install tower_slack`"
    @moduledoc """
    #{@shortdoc}

    ## Example

    ```bash
    #{@example}
    ```
    """

    use Igniter.Mix.Task

    @impl Igniter.Mix.Task
    def info(_argv, _composing_task) do
      %Igniter.Mix.Task.Info{group: :tower, example: @example}
    end

    @impl Igniter.Mix.Task
    def igniter(igniter) do
      igniter
      |> Tower.Igniter.reporters_list_append(TowerSlack)
      |> Tower.Igniter.runtime_configure_reporter(
        :tower_slack,
        otp_app: Igniter.Project.Application.app_name(igniter),
        webhook_url: code_value(~s[System.get_env("TOWER_SLACK_WEBHOOK_URL")]),
        environment: code_value(~s[System.get_env("DEPLOYMENT_ENV", to_string(config_env()))])
      )
    end

    defp code_value(value) do
      {:code, Sourceror.parse_string!(value)}
    end
  end
else
  defmodule Mix.Tasks.TowerSlack.Install do
    @example "mix igniter.install tower_slack"

    @shortdoc "Installs TowerSlack. Invoke with `mix igniter.install tower_slack`"

    @moduledoc """
    #{@shortdoc}

    ## Example

    ```bash
    #{@example}
    ```
    """

    use Mix.Task

    @impl Mix.Task
    def run(_argv) do
      Mix.shell().error("""
      The task 'tower_slack.install' requires igniter and tower >= 0.8.4. Please verify that those conditions are met in your project.

      For more information, see: https://hexdocs.pm/igniter/readme.html#installation
      """)

      exit({:shutdown, 1})
    end
  end
end
