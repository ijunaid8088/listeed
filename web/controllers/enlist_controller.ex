defmodule Listeed.EnlistController do
  use Listeed.Web, :controller

  def show(conn, %{"camera" => camera_exid, "date" => date_unix, "hour" => hour}) do
    {:ok, agent} = Agent.start_link fn -> [] end
    hour = hour(camera_exid, date_unix, hour, agent)

    count =
    Agent.get(agent, fn list -> list end)
    |> Enum.filter(fn(item) -> item end)
    |> Enum.count

    render(conn, "show.json", image_count: count)
  end

  def hour(camera_exid, date_unix, hour, agent) do
    url_base = "#{System.get_env["FILER"]}/#{camera_exid}/snapshots/recordings"
    IO.inspect url_base
    hour_datetime = date_unix |> Calendar.DateTime.Parse.unix! |> Calendar.Strftime.strftime!("%Y/%m/%d/#{String.rjust("#{hour}", 2, ?0)}")
    IO.inspect hour_datetime

    request_from_seaweedfs("#{url_base}/#{hour_datetime}/?limit=3600", "Files", "name")
    |> start_count(agent)
  end

  def request_from_seaweedfs(url, type, attribute) do
    with {:ok, response} <- HTTPoison.get(url, [], []),
         %HTTPoison.Response{status_code: 200, body: body} <- response,
         {:ok, data} <- Poison.decode(body),
         true <- is_list(data[type]) do
      Enum.map(data[type], fn(item) -> item[attribute] end)
    else
      _ -> []
    end
  end

  defp start_count([], agent), do: Agent.update(agent, fn list -> ["" | list] end)
  defp start_count(files, agent) do
    files
    |> Enum.reject(fn(files) -> files == [] end)
    |> Enum.reject(fn(file_name) -> file_name == "metadata.json" end)
    |> Enum.each(fn(_file_name) ->
      Agent.update(agent, fn list -> ["true" | list] end)
      IO.inspect agent
    end)
  end
end
