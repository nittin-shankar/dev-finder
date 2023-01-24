defmodule DevFinderWeb.SearchLive do
  use DevFinderWeb, :live_view

  alias DevFinder.User

  @default_username "octocat"

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"q" => search_query}, _url, socket) do
    user = DevFinder.get_user(search_query)

    socket = assign(socket, :search_query, search_query) |> assign_user(user)

    {:noreply, socket}
  end

  @impl true
  def handle_params(_params, _session, socket) do
    user = DevFinder.get_user(@default_username)

    socket = assign(socket, :search_query, nil) |> assign_user(user)

    {:noreply, socket}
  end

  @impl true
  def handle_event("search", %{"username" => %{"query" => query}}, socket) do
    {:noreply, push_patch(socket, to: ~p"/?q=#{query}")}
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

  defp assign_user(socket, {:ok, %User{} = user}), do: assign(socket, :user, user)

  defp assign_user(socket, {:error, "no results"}), do: assign(socket, :user, nil)

  defp assign_user(socket, {:error, _}), do: put_flash(socket, :error, "Something went wrong. Please try again")

end
