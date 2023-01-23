defmodule DevFinder.Fixtures do

  @doc """
  Sends the encoded fixture for Octocat by default
  """
  def response_fixture(attrs \\ %{}) do
    map = %{
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

    attrs
    |> Enum.into(map)
    |> Jason.encode!()
  end
end
