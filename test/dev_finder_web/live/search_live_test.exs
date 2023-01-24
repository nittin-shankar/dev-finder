defmodule DevFinderWeb.SearchLiveTest do
  use DevFinderWeb.ConnCase

  import Mox
  import Phoenix.LiveViewTest
  import DevFinder.Fixtures.Github

  alias DevFinder.GithubClientMock

  describe "Index" do
    test "shows the profile information of Octocat on the first load", %{conn: conn} do
      encoded_success_response_fixture() # This function by default gives octocat fixture
      |> github_client_success_octocat_mock()

      decoded_octocat_fixture = encoded_success_response_fixture() |> elem(1) |> Jason.decode!()

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
      assert html =~ decoded_octocat_fixture["created_at"] |> joining_date_message()

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

    test "shows the profile information of searched user going through form submission", %{conn: conn} do
      encoded_success_response_fixture()
      |> github_client_success_octocat_mock()

      encoded_random_user_fixture = encoded_success_response_fixture(%{"name" => "Some User", "login" => "some-user"})

      encoded_random_user_fixture
      |> github_client_random_user_mock()


      decoded_random_user_fixture = encoded_random_user_fixture |> elem(1) |> Jason.decode!()


      {:ok, index_live, _html} = live(conn, ~p"/")

      query = "some-user"

      html =
        index_live
        |> form("#search-form", username: %{"query" => query})
        |> render_submit()


      assert_patched(index_live, ~p"/?q=#{query}")

      assert html =~ decoded_random_user_fixture["login"]
      assert html =~ decoded_random_user_fixture["name"]
    end

    test "shows the profile information of user by params", %{conn: conn} do
      encoded_random_user_fixture = encoded_success_response_fixture(%{"name" => "Some User", "login" => "some-user"})

      encoded_random_user_fixture
      |> github_client_random_user_mock(2)


      decoded_random_user_fixture = encoded_random_user_fixture |> elem(1) |> Jason.decode!()

      query = "some-user"
      {:ok, _index_live, html} = live(conn, ~p"/?q=#{query}")

      assert html =~ decoded_random_user_fixture["login"]
      assert html =~ decoded_random_user_fixture["name"]
    end

    test "Display a message if no user is found", %{conn: conn} do
      expect(GithubClientMock, :get_user, 2, fn _args ->
        {:ok, %Finch.Response{status: 404}}
      end)

      query = "some-non-existing-user"
      {:ok, _index_live, html} = live(conn, ~p"/?q=#{query}")

      assert html =~ "No results"
    end

    test "Display a message if user has not bio", %{conn: conn} do
      encoded_user_without_bio_fixture = encoded_success_response_fixture(%{"bio" => nil})

      encoded_user_without_bio_fixture
      |> github_client_success_octocat_mock()

      {:ok, _index_live, html} = live(conn, ~p"/")

      assert html =~ "This bio is not available"
    end

    test "Display username if name is not available", %{conn: conn} do
      encoded_user_without_name_fixture = encoded_success_response_fixture(%{"name" => nil})

      encoded_user_without_name_fixture
      |> github_client_success_octocat_mock()

      decoded_user_without_name_fixture =
        encoded_user_without_name_fixture
        |> elem(1)
        |> Jason.decode!()

      {:ok, _index_live, html} = live(conn, ~p"/")

      # TODO: Use Floki here for better coverage
      assert html =~ decoded_user_without_name_fixture["login"]
    end

    test "If user info like website, company, location and twitter username is not available, then display placeholder text", %{conn: conn} do
      encoded_user_without_some_file_fixture = encoded_success_response_fixture(%{"website" => nil, "company" => nil, "location" => nil, "twitter_username" => nil})

      encoded_user_without_some_file_fixture
      |> github_client_success_octocat_mock()

      {:ok, _index_live, html} = live(conn, ~p"/")

      # TODO: Use Floki here for better coverage
      assert html =~ "Not available"
    end

    test "Display website, twitter as links to resources", %{conn: conn} do
      encoded_success_response_fixture() # This function by default gives octocat fixture
      |> github_client_success_octocat_mock()

      decoded_response_fixture = encoded_success_response_fixture() |> elem(1) |> Jason.decode!()

      {:ok, index_live, _html} = live(conn, ~p"/")

      # Verifying if blog is a link
      assert index_live |> element("a[href=\"#{decoded_response_fixture["blog"]}\"]", decoded_response_fixture["blog"]) |> has_element?()

      # Verifying if twitter username links to twitter
      assert index_live |> element("a[href=\"https://twitter.com/#{decoded_response_fixture["twitter_username"]}\"]", decoded_response_fixture["twitter_username"]) |> has_element?()
    end

    defp joining_date_message(datetime) do
      {:ok, %DateTime{day: day, month: month, year: year}, _} = DateTime.from_iso8601(datetime)

      "Joined on #{day} #{month_in_words(month)} #{year}"
    end

    defp month_in_words(month) do
      case month do
        1 -> "Jan"
        2 -> "Feb"
        3 -> "Mar"
        4 -> "Apr"
        5 -> "May"
        6 -> "Jun"
        7 -> "Jul"
        8 -> "Aug"
        9 -> "Sep"
        10 -> "Oct"
        11 -> "Nov"
        12 -> "Dec"

      end
    end

    defp github_client_success_octocat_mock({status_code, body}, n \\ 2) do
      expect(GithubClientMock, :get_user, n, fn _args ->
        {:ok, %Finch.Response{status: status_code, body: body}}
      end)
    end

    defp github_client_random_user_mock({status_code, body}, n \\ 1) do
      expect(GithubClientMock, :get_user, n, fn _args ->
        {:ok, %Finch.Response{status: status_code, body: body}}
      end)
    end

  end

end
