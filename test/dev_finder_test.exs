defmodule DevFinder.DevFinderTest do
  use ExUnit.Case

  import Mox
  import ExUnit.CaptureLog
  import DevFinder.Fixtures

  alias DevFinder.GithubClientMock


  setup :verify_on_exit!

  describe "get_user/1" do
    test "success: returns the user struct when given a valid github username" do

      response_fixture_encdoded = response_fixture()

      # Mock
      expect(GithubClientMock, :get_user, fn _args ->

        {:ok, %Finch.Response{status: 200, body: response_fixture_encdoded}}
      end)

      response_fixture_decoded = response_fixture() |> Jason.decode!()

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

      # Mock
      expect(GithubClientMock, :get_user, fn _args ->
        {:ok, %Finch.Response{status: 404}} # Github sends a HTTP response with 404 status code for invalid usernames
      end)

      assert match? {:error, "no results"}, DevFinder.get_user("not-octocat")
    end

    test "failure: returns an error tuple when the client does not send user and status code is not 200" do

      # Mocking an authentication error, we can also mock a rate limit error here instead if we want
      expect(GithubClientMock, :get_user, fn _args ->
        body = %{"message" => "Authentication error"} |> Jason.encode!()

        {:ok, %Finch.Response{status: 401, body: body}}
      end)

      assert match? {:error, "Authentication error"}, DevFinder.get_user("octocat")
    end

    test "failure: returns an error tuple and logs to the console when there's something wrong with the client" do

      expect(GithubClientMock, :get_user, fn _args ->
        {:error, "Some message to be logged"}
      end)

      log =
        capture_log(fn ->
          assert match? {:error, "error"}, DevFinder.get_user("octocat")
        end)

      assert log =~ "Some message to be logged"
    end


  end
end
