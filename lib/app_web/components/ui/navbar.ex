defmodule AppWeb.Components.UI.Navbar do
  use Phoenix.Component
  use AppWeb, :verified_routes
  use Gettext, backend: AppWeb.Gettext

  attr :locale, :string, default: "en"

  def navbar(assigns) do
    ~H"""
    <nav class="bg-slate-800 border-b border-slate-600 px-6 py-4 flex justify-between items-center">
      <div class="flex items-center gap-3 text-blue-400 font-bold text-lg">
        <svg
          class="w-12 h-12 shrink-0"
          viewBox="0 0 100 100"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
          aria-hidden="true"
        >
          <!-- outer badge -->
          <rect
            x="8"
            y="8"
            width="84"
            height="84"
            rx="20"
            stroke="currentColor"
            stroke-width="4"
          />
          
    <!-- center panel -->
          <rect
            x="24"
            y="28"
            width="52"
            height="34"
            rx="8"
            stroke="currentColor"
            stroke-width="3"
          />
          
    <!-- RL -->
          <text
            x="50"
            y="50"
            text-anchor="middle"
            fill="currentColor"
            font-size="20"
            font-weight="700"
            font-family="Arial, sans-serif"
          >
            RL
          </text>
          
    <!-- laptop base -->
          <line
            x1="28"
            y1="66"
            x2="72"
            y2="66"
            stroke="currentColor"
            stroke-width="3"
            stroke-linecap="round"
          />
          
    <!-- D20 icon -->
          <polygon
            points="50,14 58,20 55,30 45,30 42,20"
            stroke="currentColor"
            stroke-width="2.5"
            fill="none"
          />
          <line x1="50" y1="14" x2="45" y2="30" stroke="currentColor" stroke-width="2" />
          <line x1="50" y1="14" x2="55" y2="30" stroke="currentColor" stroke-width="2" />
          <line x1="42" y1="20" x2="58" y2="20" stroke="currentColor" stroke-width="2" />
          
    <!-- laptop icon -->
          <rect
            x="18"
            y="72"
            width="18"
            height="10"
            rx="2"
            stroke="currentColor"
            stroke-width="2.5"
          />
          <line
            x1="14"
            y1="84"
            x2="40"
            y2="84"
            stroke="currentColor"
            stroke-width="2.5"
            stroke-linecap="round"
          />
          
    <!-- shot put / discus icon -->
          <circle
            cx="76"
            cy="77"
            r="5"
            stroke="currentColor"
            stroke-width="2.5"
          />
          <path
            d="M66 86 Q76 72 88 82"
            stroke="currentColor"
            stroke-width="2.5"
            stroke-linecap="round"
          />
        </svg>

        <span>{gettext("Robert Lerner")}</span>
      </div>

      <div class="space-x-6 flex items-center">
        <.link href={~p"/"} class="text-blue-300 hover:underline">
          {gettext("Home")}
        </.link>

        <.link href={~p"/courses"} class="text-blue-300 hover:underline">
          {gettext("Courses")}
        </.link>

        <.link href={~p"/live/planets"} class="text-blue-300 hover:underline">
          {gettext("Planets")}
        </.link>

        <.link href={~p"/topics"} class="text-blue-300 hover:underline">
          {gettext("Topics")}
        </.link>

        <.link href={~p"/pages"} class="text-blue-300 hover:underline">
          {gettext("Pages")}
        </.link>

        <.link href={~p"/messages"} class="text-blue-300 hover:underline">
          {gettext("Messages")}
        </.link>

        <.link href={~p"/items"} class="text-blue-300 hover:underline">
          {gettext("Items")}
        </.link>

        <.link href={~p"/chat"} class="text-blue-300 hover:underline">
          {gettext("Chat")}
        </.link>

        <.link href={~p"/facemash"} class="text-blue-300 hover:underline">
          {gettext("Pokemon Mash")}
        </.link>

        <.link href={~p"/accessibility"} class="text-blue-300 hover:underline">
          {gettext("Accessibility")}
        </.link>

        <.link href={~p"/animations"} class="text-blue-300 hover:underline">
          {gettext("Animations")}
        </.link>

        <.link href={~p"/gallery"} class="text-blue-300 hover:underline">
          {gettext("Gallery")}
        </.link>

        <.link href={~p"/rock-paper-scissors"} class="text-blue-300 hover:underline">
          {gettext("RPS")}
        </.link>

        <.link href={~p"/minesweeper"} class="text-blue-300 hover:underline">
          {gettext("Minesweeper")}
        </.link>

        <.link navigate={~p"/charts"} class="text-blue-300 hover:underline">
          {gettext("Charts")}
        </.link>

        <.link href={~p"/dnd"} class="text-red-400 font-bold hover:underline">
          {gettext("D&D")}
        </.link>

        <AppWeb.Components.UI.Button.language_toggle locale={@locale} />

        <.link
          id="logout-button"
          href={~p"/users/log-out"}
          method="delete"
          phx-hook="LogoutButton"
          class="text-red-400 hover:underline ml-4"
        >
          {gettext("Logout")}
        </.link>
      </div>
    </nav>
    """
  end
end
