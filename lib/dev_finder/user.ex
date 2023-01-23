defmodule DevFinder.User do
  @moduledoc """
  The user struct
  """

  defstruct [
      :avatar_url,
      :name,
      :username,
      :joined_at,
      :bio,
      :repos,
      :followers,
      :following,
      :location,
      :twitter_username,
      :blog,
      :company
    ]


end
