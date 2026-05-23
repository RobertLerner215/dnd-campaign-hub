defmodule AppWeb.UI.Card do
  use Phoenix.Component

  attr :title, :string, required: true
  attr :body, :string, required: true

  def card(assigns) do
    ~H"""
    <div class="max-w-sm p-6 bg-white border border-gray-200 rounded-lg shadow
                dark:bg-gray-800 dark:border-gray-700 transition-colors duration-300">
      <h5 class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
        {@title}
      </h5>

      <p class="text-gray-700 dark:text-gray-400">
        {@body}
      </p>
    </div>
    """
  end
end
