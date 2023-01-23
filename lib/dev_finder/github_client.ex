defmodule DevFinder.GithubClient do
  @moduledoc """
  The Github client which calls the API
  """

  @behaviour DevFinder.GithubClientBehaviour

  @api_url "https://api.github.com"

  @doc """

  """
  def get_user(username) do
    username
    |> build_request(:get_user)
    |> Finch.request(DevFinder.Finch)
  end

  defp build_request(username, :get_user) do
    url = @api_url <> "/users/#{username}"

    access_token = Application.get_env(:dev_finder, :github_access_token)
    authorization_headers = [{"Authorization", "Bearer #{access_token}"}]

    Finch.build(
      :get,
      url,
      authorization_headers
    )
  end

end
