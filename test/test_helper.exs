Mox.defmock(DevFinder.GithubClientMock, for: DevFinder.GithubClientBehaviour)

Application.put_env(:dev_finder, :github_client, DevFinder.GithubClientMock)

ExUnit.start()
