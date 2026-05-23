defmodule AppWeb.MessageHTML do
  use AppWeb, :html

  # This is what makes <.input>, <.button>, <.table>, etc work in .heex templates
  import AppWeb.CoreComponents

  embed_templates "message_html/*"
end
