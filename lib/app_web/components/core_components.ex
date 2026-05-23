defmodule AppWeb.CoreComponents do
  use Phoenix.Component
  use Gettext, backend: AppWeb.Gettext

  alias Phoenix.LiveView.JS

  @moduledoc """
  Core UI components for the app.
  """

  # ---------------------------------------------------------------------------
  # Basic helpers
  # ---------------------------------------------------------------------------

  attr :id, :string, default: nil
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def container(assigns) do
    ~H"""
    <div id={@id} class={["mx-auto max-w-6xl px-6", @class]}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Flash
  # ---------------------------------------------------------------------------

  attr :id, :string, default: "flash"
  attr :flash, :map, default: %{}
  attr :kind, :atom, values: [:info, :error]
  attr :title, :string, default: nil
  attr :class, :string, default: nil

  slot :inner_block

  def flash(assigns) do
    ~H"""
    <div
      :if={msg = Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      role="alert"
      class={[
        "fixed top-4 right-4 z-50 w-full max-w-sm rounded-lg p-4 shadow-lg",
        flash_classes(@kind),
        @class
      ]}
      phx-click={JS.hide(to: "##{@id}")}
    >
      <p :if={@title} class="mb-1 text-sm font-semibold">{@title}</p>
      <p class="text-sm leading-5">{msg}</p>
      <div :if={@inner_block != []} class="mt-2">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  defp flash_classes(:info), do: "bg-blue-50 text-blue-800 ring-1 ring-blue-200"
  defp flash_classes(:error), do: "bg-red-50 text-red-800 ring-1 ring-red-200"

  # ---------------------------------------------------------------------------
  # Icon
  # ---------------------------------------------------------------------------

  attr :name, :string, required: true
  attr :class, :string, default: nil

  def icon(assigns) do
    ~H"""
    <span class={@class} aria-hidden="true"></span>
    """
  end

  # ---------------------------------------------------------------------------
  # Header
  # ---------------------------------------------------------------------------

  attr :class, :string, default: nil
  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <div class={["mb-6", @class]}>
      <div class="flex items-center justify-between gap-4">
        <h1 class="text-2xl font-semibold">
          {render_slot(@inner_block)}
        </h1>

        <div :if={@actions != []} class="flex gap-2">
          {render_slot(@actions)}
        </div>
      </div>

      <div :if={@subtitle != []} class="mt-2 text-sm text-slate-300">
        {render_slot(@subtitle)}
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Simple form
  # ---------------------------------------------------------------------------

  attr :for, :any, required: true
  attr :as, :any, default: nil
  attr :id, :string, default: nil
  attr :class, :string, default: nil
  attr :action, :string, default: nil
  attr :method, :string, default: nil
  attr :phx_change, :string, default: nil
  attr :phx_submit, :string, default: nil
  attr :phx_trigger_action, :boolean, default: false

  slot :inner_block, required: true
  slot :actions

  def simple_form(assigns) do
    ~H"""
    <.form
      :let={f}
      for={@for}
      as={@as}
      id={@id}
      class={@class}
      action={@action}
      method={@method}
      phx-change={@phx_change}
      phx-submit={@phx_submit}
      phx-trigger-action={@phx_trigger_action}
    >
      {render_slot(@inner_block, f)}

      <div :if={@actions != []} class="mt-4">
        {render_slot(@actions)}
      </div>
    </.form>
    """
  end

  # ---------------------------------------------------------------------------
  # Input
  # ---------------------------------------------------------------------------

  attr :field, :any, required: true
  attr :type, :string, default: "text"
  attr :label, :string, default: nil
  attr :class, :string, default: nil

  attr :rest, :global, include: ~w(
      accept autocomplete capture cols disabled form list max maxlength min minlength
      multiple pattern placeholder readonly required rows size step value name phx-mounted
    )

  def input(assigns) do
    id = Map.get(assigns.field, :id) || Map.get(assigns.field, "id")
    name = Map.get(assigns.field, :name) || Map.get(assigns.field, "name")
    value = Map.get(assigns.field, :value) || Map.get(assigns.field, "value")
    errors = Map.get(assigns.field, :errors) || []

    assigns =
      assigns
      |> assign(:id, id)
      |> assign(:name, name)
      |> assign(:value, value)
      |> assign(:errors, errors)

    ~H"""
    <div class={["mb-4", @class]}>
      <label :if={@label} for={@id} class="mb-2 block text-sm font-medium text-white">
        {@label}
      </label>

      <input
        id={@id}
        name={@name}
        type={@type}
        value={@value}
        class="block w-full rounded-xl border border-slate-600 bg-slate-200 px-4 py-3 text-black focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500"
        {@rest}
      />

      <p :for={msg <- @errors} class="mt-1 text-sm text-red-400">
        {translate_error(msg)}
      </p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Table
  # ---------------------------------------------------------------------------

  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_click, :any, default: nil

  slot :col do
    attr :label, :string, required: true
  end

  slot :action

  def table(assigns) do
    ~H"""
    <div class="overflow-x-auto">
      <table id={@id} class="min-w-full border-collapse">
        <thead>
          <tr>
            <%= for col <- @col do %>
              <th class="border-b p-3 text-left font-semibold">{col.label}</th>
            <% end %>
            <th :if={@action != []} class="border-b p-3 text-left font-semibold">Actions</th>
          </tr>
        </thead>
        <tbody>
          <%= for row <- @rows do %>
            <tr class="border-b">
              <%= for col <- @col do %>
                <td class="p-3 align-top">{render_slot(col, row)}</td>
              <% end %>

              <td :if={@action != []} class="whitespace-nowrap p-3 align-top">
                <%= for act <- @action do %>
                  {render_slot(act, row)}
                <% end %>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # List
  # ---------------------------------------------------------------------------

  slot :item do
    attr :title, :string, required: true
  end

  def list(assigns) do
    ~H"""
    <dl class="divide-y">
      <%= for it <- @item do %>
        <div class="grid grid-cols-3 gap-4 py-3">
          <dt class="font-semibold">{it.title}</dt>
          <dd class="col-span-2">{render_slot(it)}</dd>
        </div>
      <% end %>
    </dl>
    """
  end

  # ---------------------------------------------------------------------------
  # Error translation
  # ---------------------------------------------------------------------------

  def translate_error({msg, opts}) do
    if count = opts[:count] do
      Gettext.dngettext(AppWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(AppWeb.Gettext, "errors", msg, opts)
    end
  end
end
