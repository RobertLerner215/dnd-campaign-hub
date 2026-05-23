defmodule AppWeb.Layouts do
  use AppWeb, :html

  embed_templates "layouts/*"

  attr :flash, :map, required: true
  attr :current_scope, :any, default: nil
  attr :locale, :string, default: "en"
  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="min-h-screen bg-[#020f35] text-white">
      {render_slot(@inner_block)}
    </div>
    """
  end
end
