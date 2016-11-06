defmodule Listeed.EnlistController do
  use Listeed.Web, :controller

  def show(conn, %{"camera" => camera_exid, "date" => date_unix, "hour" => hour}) do
    total = hour(camera_exid, date_unix, hour)
    render(conn, "show.json", image_count: total)
  end

  def yesterday(conn, %{"camera" => camera_exid}) do
    %{day: tday, month: tmonth, year: tyear} = Calendar.Date.today_utc
    %{day: yday, month: ymonth, year: yyear} = Calendar.Date.from_erl!({tyear, tmonth, tday}) |> Calendar.Date.prev_day!

    date_unix =
      {{yyear, ymonth, yday}, {0, 0, 0}}
      |> Calendar.DateTime.from_erl!("Etc/UTC")
      |> Calendar.DateTime.Format.unix

    data = Enum.map 0..23, fn per_hour ->
      %{
          hour:  per_hour,
          count: hour(camera_exid, date_unix, per_hour)
       }
    end

    render(conn, "yesterday.json", %{camera_exid: camera_exid, enlist: data})
  end

  def do_it_smart([hour, count]) do
    %{
      hour: hour,
      image_count: count
    }
  end

  def get_camera_list() do
    request_from_seaweedfs("#{System.get_env["FILER"]}", "Subdirectories", "Name")
  end

  def hour(camera_exid, date_unix, hour) do
    url_base = "#{System.get_env["FILER"]}/#{camera_exid}/snapshots/recordings"
    hour_datetime = date_unix |> Calendar.DateTime.Parse.unix! |> Calendar.Strftime.strftime!("%Y/%m/%d/#{String.rjust("#{hour}", 2, ?0)}")
    request_from_seaweedfs("#{url_base}/#{hour_datetime}/?limit=3600", "Files", "name")
    |> start_count
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

  defp start_count([]), do: 0
  defp start_count(files) do
    files
    |> Enum.reject(fn(files) -> files == [] end)
    |> Enum.reject(fn(file_name) -> file_name == "metadata.json" end)
    |> Enum.filter(fn(item) -> item end)
    |> Enum.count
  end
end
