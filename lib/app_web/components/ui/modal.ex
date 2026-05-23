defmodule AppWeb.Components.UI.Modal do
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  attr :id, :string, default: "modal"
  attr :class, :string, default: nil

  attr :backdrop, :string,
    default: "dynamic",
    values: ~w(dynamic static)

  attr :heading, :string, required: true

  attr :small, :boolean, default: false

  slot :inner_block, required: true

  def modal(assigns) do
    assigns =
      assign(assigns,
        size_class: if(assigns.small, do: "max-w-md", else: "max-w-2xl")
      )

    ~H"""
    <div
      id={@id}
      aria-hidden="true"
      class={[
        "hidden fixed inset-0 z-50 flex items-center justify-center p-4 overflow-y-auto",
        @class
      ]}
    >
      <!-- Backdrop -->
      <div
        class="fixed inset-0 bg-gray-900/50 dark:bg-gray-900/80"
        phx-click={@backdrop == "dynamic" && close_modal(@id)}
      >
      </div>
      
    <!-- Modal Content -->
      <div class={"relative z-10 w-full #{@size_class} max-h-full"}>
        <div class="relative bg-white rounded-lg shadow dark:bg-gray-700">
          
    <!-- Header -->
          <div class="flex items-start justify-between p-4 border-b rounded-t dark:border-gray-600">
            <h3 class="text-xl font-semibold text-gray-900 dark:text-white">
              {@heading}
            </h3>

            <button
              type="button"
              aria-label="Close modal"
              phx-click={close_modal(@id)}
              class="text-gray-400 bg-transparent hover:bg-gray-200 hover:text-gray-900 rounded-lg text-sm w-8 h-8 ms-auto inline-flex justify-center items-center dark:hover:bg-gray-600 dark:hover:text-white"
            >
              <svg class="w-3 h-3" fill="none" viewBox="0 0 14 14">
                <path
                  stroke="currentColor"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="m1 1 12 12M13 1 1 13"
                />
              </svg>
            </button>
          </div>
          
    <!-- Body -->
          <div class="p-6 space-y-6 text-gray-700 dark:text-gray-300">
            {render_slot(@inner_block)}
          </div>
        </div>
      </div>
    </div>
    """
  end

  def open_modal(id) do
    %JS{}
    |> JS.remove_class("hidden", to: "##{id}")
    |> JS.set_attribute({"aria-hidden", "false"}, to: "##{id}")
  end

  def close_modal(id) do
    %JS{}
    |> JS.add_class("hidden", to: "##{id}")
    |> JS.set_attribute({"aria-hidden", "true"}, to: "##{id}")
  end
end
