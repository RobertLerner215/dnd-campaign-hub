defmodule Mix.Tasks.Deploy do
  use Mix.Task

  require Logger

  @shortdoc "SSH into the server, update code, run tests, and restart the Phoenix server"

  def run([ssh_server, commit_message]) do
    # make sure you have an environment variable DATABASE_URL in the format:
    # ecto://USER:PASSWORD@eg-postgresql.bucknell.edu/DATABASE
    db_url = System.get_env("DATABASE_URL")
    [_, _, _, database] = String.split(db_url, "/")

    Logger.debug("Pushing to remote branch...")
    System.cmd("git", ["add", "."], use_stdio: false)
    System.cmd("git", ["commit", "-m", commit_message], use_stdio: false)
    System.cmd("git", ["push"], use_stdio: false)

    Logger.debug("Deploying to #{ssh_server}...")

    # Chaining commands using `&&` to prevent SSH connection closure
    ssh_command = """
    echo "Loading environment..." && \
    module load elixir erlang > /dev/null || { exit 1; } && \
    cd ~/workspace/csci379 && \
    echo "Resetting any local changes..." && \
    git reset --hard > /dev/null || { exit 1; } && \
    echo "Pulling latest code..." && \
    git pull > /dev/null || { exit 1; } && \
    echo "Stopping running server..." && \
    tmux kill-session -t #{database} >/dev/null || true && \
    echo "Loading dependencies..." && \
    mix deps.get --only prod > /dev/null || { exit 1; } && \
    echo "Compiling code..." && \
    MIX_ENV=prod mix compile > /dev/null || { exit 1; } && \
    echo "Exporting DB URL..." && \
    export DATABASE_URL="#{db_url}" && \
    echo "Removing old digested files..." && \
    MIX_ENV=prod mix phx.digest.clean --all > /dev/null || { exit 1; } && \
    echo "Migrating database..." && \
    MIX_ENV=prod mix ecto.migrate > /dev/null || { exit 1; } && \
    echo "Running seeds..." && \
    MIX_ENV=prod mix run priv/repo/seeds.exs > /dev/null || { exit 1; } && \
    echo "Deploying assets..." && \
    MIX_ENV=prod mix assets.deploy > /dev/null || { exit 1; } && \
    echo "(Re)starting server in tmux..." && \
    tmux new -d -s #{database} \
    "export DATABASE_URL='#{db_url}' && \
    module load elixir erlang >/dev/null && \
    MIX_ENV=prod mix phx.server"
    echo "Deployment successful."
    """

    # Run the SSH command and redirect both stdout and stderr to /dev/null
    System.cmd("ssh", [ssh_server, "-t", "-o", "RemoteCommand=" <> ssh_command], use_stdio: false)
  end

  def run(_) do
    Logger.error("Usage: mix deploy <ssh_server> <commit_message>")
  end
end
