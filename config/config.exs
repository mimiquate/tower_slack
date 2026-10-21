import Config

# tower_web is an optional dependency; its pruner needs a repo at startup,
# which tower_slack doesn't have.
config :tower_web, pruner: false
