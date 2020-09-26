defmodule Http.Server do
  @moduledoc false
  use Plug.Router
  use Plug.ErrorHandler

  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug(:dispatch)

  def child_spec(_arg) do
    port = Application.fetch_env!(:benchmark, :main_port)
    IO.puts("Account HTTP server listening to: port #{port}")

    Plug.Adapters.Cowboy.child_spec(
      scheme: :http,
      options: [port: port],
      plug: __MODULE__
    )
  end

  defp generate_http_response(response) do
    case response do
      {:ok, response, message} ->
        {200,
         %{
           success: true,
           data: response,
           message: message
         }}

      {:denied, response, message} ->
        {
          403,
          %{
            success: false,
            data: response,
            message: message
          }
        }
    end
  end

  defp parse_body_to_atom(entry_body) do
    entry_body
    |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
  end

  defp send_http_response({status, result_body}, conn) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(status, Poison.encode!(result_body))
  end

  post("deposit") do
    %{account_id: account_id, amount: amount} = parse_body_to_atom(conn.body_params)

    Account.Cache.server_process(account_id)
    |> Account.Server.deposit(amount)
    |> generate_http_response()
    |> send_http_response(conn)
  end

  post("withdraw") do
    %{account_id: account_id, amount: amount} = parse_body_to_atom(conn.body_params)

    Account.Cache.server_process(account_id)
    |> Account.Server.withdraw(amount)
    |> generate_http_response()
    |> send_http_response(conn)
  end

  post("simulate-busy") do
    %{account_id: account_id, counter: counter} = parse_body_to_atom(conn.body_params)

    Account.Cache.server_process(account_id)
    |> Account.Server.simulate_busy(counter)
    |> generate_http_response()
    |> send_http_response(conn)
  end

  post("simulate-error") do
    %{account_id: account_id, message: message} = parse_body_to_atom(conn.body_params)

    Account.Cache.server_process(account_id)
    |> Account.Server.simulate_error(message)
    |> generate_http_response()
    |> send_http_response(conn)
  end
end
