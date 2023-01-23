defmodule DevFinder.GithubClientBehaviour do
  @moduledoc """
  The behavior for github API
  """

  @callback get_user(username :: String.t()) :: any()
end
