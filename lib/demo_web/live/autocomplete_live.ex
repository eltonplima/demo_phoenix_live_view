defmodule DemoWeb.AutocompleteLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
      <form phx-change="suggest" phx-submit="search">
        <input type="text" name="q" value="<%= @query %>" list="matches" placeholder="Search..." <%= if @loading, do: "readonly"%>/>
        <datalist id="matches">
          <%= for match <- @matches do %>
            <option value="<%= match %>"><%= match %></option>
          <% end %>
        </datalist>
        <%= if is_list(@result) do %>
          <ul>
            <%= for match <- @result do %>
              <li><%= match %></li>
            <% end %>
          </ul>
        <% else %>
          <pre><%= @result %></pre>
        <% end %>
      </form>
    """
  end

  def mount(_params, _session, socket) do
    new_socket = assign(socket, :query, "")
    |> assign(:loading, false)
    |> assign(:matches, [])
    |> assign(:result, [])
    {:ok, new_socket}
  end

  def handle_event("suggest", %{"q" => query}, socket) when byte_size(query) <= 100 do
    {:ok, words} = search(query)
    {:noreply, assign(socket, matches: words)}
  end

  def handle_event("search", %{"q" => query}, socket) when byte_size(query) <= 100 do
    send(self(), {:search, query})

    {
      :noreply,
      assign(socket,
        query: query,
        result: "Searching...",
        loading: true,
        matches: []
      )
    }
  end

  def handle_info({:search, query}, socket) do
    {:ok, words} = search(query)
    {:noreply, assign(socket, result: words)}
  end

  defp search(query) do
    {words, _exit_status} = System.cmd("grep", ["^#{query}.*", "-m", "5", "/usr/share/dict/words"])
    words = String.split(words, "\n", trim: true)
    {:ok, words}
  end
end
