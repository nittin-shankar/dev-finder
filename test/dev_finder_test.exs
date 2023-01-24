defmodule DevFinder.DevFinderTest do
  use ExUnit.Case

  import Mox
  import ExUnit.CaptureLog
  import DevFinder.Fixtures.Github

  alias DevFinder.GithubClientMock

  setup :verify_on_exit!



  describe "get_user/1" do
    test "success: returns the user struct when given a valid github username" do
      # Mock
      encoded_success_response_fixture()
      |> github_client_success_mock()

      response_fixture_decoded = encoded_success_response_fixture() |> elem(1) |> Jason.decode!()

      # Actual testing happens here
      assert {:ok, %DevFinder.User{} = user} = DevFinder.get_user("octocat")

      assert user.avatar_url == response_fixture_decoded["avatar_url"]
      assert user.name == response_fixture_decoded["name"]
      assert user.username == response_fixture_decoded["login"]
      assert user.joined_at == response_fixture_decoded["created_at"]
      assert user.bio == response_fixture_decoded["bio"]
      assert user.repos == response_fixture_decoded["public_repos"]
      assert user.followers == response_fixture_decoded["followers"]
      assert user.following == response_fixture_decoded["following"]
      assert user.location == response_fixture_decoded["location"]
      assert user.twitter_username == response_fixture_decoded["twitter_username"]
      assert user.blog == response_fixture_decoded["blog"]
      assert user.company == response_fixture_decoded["company"]
    end

    test "failure: returns an error tuple when given an invalid github username" do
      github_client_no_user_found_mock()

      assert match? {:error, "no results"}, DevFinder.get_user("not-octocat")
    end

    test "failure: returns an error tuple when the client does not send user and status code is not 200" do

      # Mocking an authentication error, we can also mock a rate limit error here instead if we want
      encoded_authentication_error_response_fixture()
      |> github_client_authentication_error_mock()

      authentication_error_response_fixture_decoded =
        encoded_authentication_error_response_fixture()
        |> elem(1)
        |> Jason.decode!()

      message = authentication_error_response_fixture_decoded |> Map.get("message")

      assert match? {:error, ^message}, DevFinder.get_user("octocat")
    end

    test "failure: returns an error tuple and logs to the console when there's something wrong with the finch client" do

      expect(GithubClientMock, :get_user, fn _args ->
        {:error, "Some message to be logged"}
      end)

      log =
        capture_log(fn ->
          assert match? {:error, "error"}, DevFinder.get_user("octocat")
        end)

      assert log =~ "Some message to be logged"
    end

    # All mocks are defined below
    defp github_client_success_mock({status_code, body}) do
      expect(GithubClientMock, :get_user, fn _args ->

        {:ok, %Finch.Response{status: status_code, body: body}}
      end)
    end

    defp github_client_no_user_found_mock() do
      expect(GithubClientMock, :get_user, fn _args ->
        {:ok, %Finch.Response{status: 404}} # Github sends a HTTP response with 404 status code for invalid usernames
      end)
    end

    defp github_client_authentication_error_mock({status_code, body}) do
      expect(GithubClientMock, :get_user, fn _args ->
        {:ok, %Finch.Response{status: status_code, body: body}}
      end)
    end


  end
end
