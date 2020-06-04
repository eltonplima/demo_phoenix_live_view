defmodule DemoWeb.ClockLive do
  use Phoenix.LiveView
  import Calendar.Strftime

  def render(assigns) do
    ~L"""
      <div>
        <h2> <%= strftime!(@date, "%r") %> </h2>
      </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :tick)
    {:ok, put_date(socket)}
  end

  defp put_date(socket) do
    assign(socket, date: :calendar.local_time())
  end

  def handle_info(:tick, socket) do
    {:noreply, put_date(socket)}
  end
end
