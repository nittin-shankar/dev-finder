defmodule DevFinder do
  @moduledoc """
  DevFinder keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  require Logger

  def get_user(username) do
    response = github_client().get_user(username)

    case response do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        user =
          body
          |> Jason.decode!()
          |> build_user()

        {:ok, user}

      {:ok, %Finch.Response{status: 404}} ->
        {:error, "no results"}

      {:ok, %Finch.Response{body: body}} ->
        message =
          body
          |> Jason.decode!()
          |> Map.get("message")

        {:error, message}

      {:error, error} ->
        Logger.error(error)
        {:error, "error"}

    end
  end

  defp build_user(body) do
    %DevFinder.User{
      avatar_url: body["avatar_url"],
      name: body["name"],
      username: body["login"],
      joined_at: body["created_at"],
      bio: body["bio"],
      repos: body["public_repos"],
      followers: body["followers"],
      following: body["following"],
      location: body["location"],
      twitter_username: body["twitter_username"],
      blog: body["blog"],
      company: body["company"]
    }
  end


  defp github_client() do
    Application.get_env(:dev_finder, :github_client)
  end
end
