defmodule AppWeb.GalleryLive do
  use AppWeb, :live_view

  def images,
    do: [
      %{
        id: "throwing",
        title: "Track and Field Throwing",
        large: ~p"/images/gallery/throwing.jpg",
        thumb: ~p"/images/gallery/throwing_thumbnail.jpg"
      },
      %{
        id: "coding",
        title: "Coding and Computer Science",
        large: ~p"/images/gallery/coding.jpg",
        thumb: ~p"/images/gallery/coding_thumbnail.jpg"
      },
      %{
        id: "dnd",
        title: "Dungeons and Dragons",
        large: ~p"/images/gallery/dnd.jpg",
        thumb: ~p"/images/gallery/dnd_thumbnail.jpg"
      }
    ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, images: images(), selected: hd(images()))}
  end

  @impl true
  def handle_event("select-image", %{"id" => id}, socket) do
    image =
      Enum.find(images(), fn img -> img.id == id end)

    {:noreply, assign(socket, selected: image)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-slate-950 text-white px-8 py-10">
      <div class="max-w-6xl mx-auto">
        <h1 class="text-4xl font-bold text-blue-400 mb-2">
          Gallery
        </h1>

        <p class="text-slate-300 mb-8">
          A collection of my interests in athletics, technology, and fantasy gaming.
        </p>
        
    <!-- Featured Image -->
        <div class="mb-10">
          <img
            id={@selected.id}
            src={@selected.large}
            alt={@selected.title}
            class="w-full max-w-4xl h-[500px] mx-auto rounded-xl border-4 border-blue-400 object-contain bg-slate-900 p-3 shadow-lg animate-pulse transition-all duration-700 hover:scale-[1.01]"
          />

          <p class="text-center text-blue-300 mt-3 text-lg font-semibold">
            {@selected.title}
          </p>
        </div>
        
    <!-- Thumbnails -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-5">
          <%= for image <- images() do %>
            <button
              phx-click="select-image"
              phx-value-id={image.id}
              class={[
                "rounded-xl overflow-hidden bg-slate-900 shadow-md border-2 transition-all duration-300 hover:scale-105 hover:-translate-y-1",
                if(@selected.id == image.id,
                  do: "border-blue-400 shadow-blue-500/40",
                  else: "border-slate-700 hover:border-blue-400"
                )
              ]}
            >
              <img
                src={image.thumb}
                alt={image.title}
                class="w-full h-44 object-contain bg-slate-900 p-2"
              />

              <div class="text-sm text-slate-300 py-3 px-3 border-t border-slate-700">
                {image.title}
              </div>
            </button>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
