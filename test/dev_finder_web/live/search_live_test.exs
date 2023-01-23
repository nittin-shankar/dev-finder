defmodule DevFinderWeb.SearchLiveTest do
  use DevFinderWeb.ConnCase

  import Mox
  import Phoenix.LiveViewTest
  import DevFinder.Fixtures

  alias DevFinder.GithubClientMock

  describe "Index" do

    test "shows the profile information of Octocat on the first load", %{conn: conn} do

      encoded_octocat_fixture = response_fixture()
      # Mock
      expect(GithubClientMock, :get_user, 2, fn args ->
        # The reason I gave the expect function the argument of 2 is because liveview calls mount two times
        assert args == "octocat"
        {:ok, %Finch.Response{status: 200, body: encoded_octocat_fixture}}
      end)

      decoded_octocat_fixture = encoded_octocat_fixture |> Jason.decode!()


      {:ok, index_live, html} = live(conn, ~p"/")

      # Verifying if the page displays the octocat avatar
      avatar_url = decoded_octocat_fixture["avatar_url"]
      assert has_element?(index_live, "img[src*=\"#{avatar_url}\"]")

      # Verifying if the page contains the name of octocat profile
      assert html =~ decoded_octocat_fixture["name"]

      # Verifying if the page contains the username with an "@" prefix
      assert html =~ decoded_octocat_fixture["login"]

      # Verifying if the page contains the bio of octocat profile
      assert html =~ decoded_octocat_fixture["bio"]

      # Verifying if the page contains the joining information of octocat profile
      assert html =~ decoded_octocat_fixture["created_at"]

      # Verifying if the page contains the repos of octocat profile
      assert html =~ inspect(decoded_octocat_fixture["public_repos"])

      # Verifying if the page contains the followers of octocat profile
      assert html =~ inspect(decoded_octocat_fixture["followers"])

      # Verifying if the page contains the following of octocat profile
      assert html =~ inspect(decoded_octocat_fixture["following"])

      # Verifying if the page contains the location of octocat profile
      assert html =~ decoded_octocat_fixture["location"]

      # Verifying if the page contains the twitter username of octocat profile
      assert html =~ decoded_octocat_fixture["twitter_username"]

      # Verifying if the page contains the blog url of octocat profile
      assert html =~ decoded_octocat_fixture["blog"]

      # Verifying if the page contatins company of octocat profile
      assert html =~ decoded_octocat_fixture["company"]

    end


    test "shows the profile information of searched user", %{conn: conn} do
      expect(GithubClientMock, :get_user, 2, fn args ->
        assert args == "octocat"
        {:ok, %Finch.Response{status: 200, body: response_fixture()}}
      end)

      encoded_random_user_fixture = response_fixture(%{"name" => "Some User"})

      expect(GithubClientMock, :get_user, 1, fn args ->
        assert args == "some-user"
        {:ok, %Finch.Response{status: 200, body: encoded_random_user_fixture}}
      end)

      decoded_random_user_fixture = encoded_random_user_fixture |> Jason.decode!()

      {:ok, index_live, _html} = live(conn, ~p"/")

      query = "some-user"
      index_live |> form("#search-form", username: %{"query" => query}) |> render_submit() =~ decoded_random_user_fixture["name"]

      assert_patched(index_live, ~p"/?q=#{query}")
    end

    test "Display a message if no user is found", %{conn: conn} do
      expect(GithubClientMock, :get_user, 2, fn args ->
        assert args == "octocat"
        {:ok, %Finch.Response{status: 200, body: response_fixture()}}
      end)

      expect(GithubClientMock, :get_user, 1, fn args ->
        assert args == "non-existing-user"

        {:ok, %Finch.Response{status: 404}}
      end)

      {:ok, index_live, _html} = live(conn, ~p"/")

      query = "non-existing-user"
      index_live |> form("#search-form", username: %{"query" => query}) |> render_submit() =~ "No results"
    end

    test "Display a message if user has not bio", %{conn: conn} do
      encoded_response_fixture = response_fixture(%{"bio" => nil})
      expect(GithubClientMock, :get_user, 2, fn args ->
        assert args == "octocat"
        {:ok, %Finch.Response{status: 200, body: encoded_response_fixture}}
      end)

      {:ok, _index_live, html} = live(conn, ~p"/")

      assert html =~ "This bio is not available"
    end

    test "Display username if name is not available", %{conn: conn} do
      encoded_response_fixture = response_fixture(%{"name" => nil})
      expect(GithubClientMock, :get_user, 2, fn args ->
        assert args == "octocat"
        {:ok, %Finch.Response{status: 200, body: encoded_response_fixture}}
      end)
      decoded_response_fixture = encoded_response_fixture |> Jason.decode!()

      {:ok, _index_live, html} = live(conn, ~p"/")

      # TODO: Use Floki here for better coverage
      assert html =~ decoded_response_fixture["login"]
    end

    test "If user info like website, company, location and twitter username is not available, then display placeholder text", %{conn: conn} do
      encoded_response_fixture = response_fixture(%{"website" => nil, "company" => nil, "location" => nil, "twitter_username" => nil})
      expect(GithubClientMock, :get_user, 2, fn args ->
        assert args == "octocat"
        {:ok, %Finch.Response{status: 200, body: encoded_response_fixture}}
      end)

      {:ok, _index_live, html} = live(conn, ~p"/")

      # TODO: Use Floki here for better coverage
      assert html =~ "Not available"
    end

    test "Display website, twitter as links to resources", %{conn: conn} do
      encoded_response_fixture = response_fixture()
      expect(GithubClientMock, :get_user, 2, fn args ->
        assert args == "octocat"
        {:ok, %Finch.Response{status: 200, body: encoded_response_fixture}}
      end)

      decoded_response_fixture = encoded_response_fixture |> Jason.decode!()

      {:ok, index_live, _html} = live(conn, ~p"/")

      # Verifying if blog is a link
      assert index_live |> element("a[href=\"#{decoded_response_fixture["blog"]}\"]", decoded_response_fixture["blog"]) |> has_element?()

      # Verifying if twitter username links to twitter
      assert index_live |> element("a[href=\"https://twitter.com/#{decoded_response_fixture["twitter_username"]}\"]", decoded_response_fixture["twitter_username"]) |> has_element?()
    end
  end

end
