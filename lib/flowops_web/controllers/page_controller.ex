defmodule FlowopsWeb.PageController do
  use FlowopsWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
