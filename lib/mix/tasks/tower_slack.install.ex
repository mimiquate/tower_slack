if Code.ensure_loaded?(Igniter) && Code.ensure_loaded?(Tower.Igniter) do
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

    import Tower.Igniter

    @impl Igniter.Mix.Task
    def info(_argv, _composing_task) do
      %Igniter.Mix.Task.Info{
        group: :tower,
        adds_deps: [],
        installs: [],
        example: @example,
        only: nil,
        positional: [],
        composes: [],
        schema: [],
        defaults: [],
        aliases: [],
        required: []
      }
    end

    @impl Igniter.Mix.Task
    def igniter(igniter) do
      app_name = Igniter.Project.Application.app_name(igniter)

      igniter
      |> add_reporter_to_config(TowerSlack)
      |> Igniter.Project.Config.configure(
        "runtime.exs",
        :tower_slack,
        [:otp_app],
        app_name
      )
      |> Igniter.Project.Config.configure(
        "runtime.exs",
        :tower_slack,
        [:webhook_url],
        {:code, Sourceror.parse_string!("System.get_env(\"TOWER_SLACK_WEBHOOK_URL\")")}
      )
      |> Igniter.Project.Config.configure(
        "runtime.exs",
        :tower_slack,
        [:environment],
        {:code,
         Sourceror.parse_string!("System.get_env(\"DEPLOYMENT_ENV\", to_string(config_env()))")}
      )
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
      The task 'tower_slack.install' requires igniter. Please install igniter and try again.

      For more information, see: https://hexdocs.pm/igniter/readme.html#installation
      """)

      exit({:shutdown, 1})
    end
  end
end
