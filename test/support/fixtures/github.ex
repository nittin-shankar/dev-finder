defmodule DevFinder.Fixtures.Github do

  @doc """
  Sends the encoded fixture for Octocat by default
  """
  def encoded_success_response_fixture(attrs \\ %{}) do
    default_attrs = %{
      "avatar_url" => "https://avatars.githubusercontent.com/u/583231?v=4",
      "name" => "The Octocat",
      "login" => "octocat",
      "created_at" => "2011-01-25T18:44:36Z",
      "bio" => "Some bio that is notable of putting here",
      "public_repos" => 8,
      "followers" => 8094,
      "following" => 9,
      "location" => "San Francisco",
      "twitter_username" => "SomeTwitterUsername",
      "blog" => "https://github.blog",
      "company" => "@github"

    }

    response = attrs
    |> Enum.into(default_attrs)
    |> Jason.encode!()

    {200, response}
  end

  def encoded_authentication_error_response_fixture() do
    response = %{
      "message" => "Some kind of authentication error"
    }

    {401, Jason.encode!(response)}
  end
end
