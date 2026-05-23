defmodule AppWeb.CharacterLive.Form do
  use AppWeb, :live_view

  alias App.Dnd
  alias App.Dnd.Character

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-screen bg-slate-950 text-white">
        <div class="mx-auto max-w-5xl px-6 py-10">
          <.link
            navigate={return_path(@return_to, @character)}
            class="mb-8 inline-flex rounded-lg border border-slate-700 bg-slate-900 px-4 py-2 text-slate-200 transition duration-200 hover:-translate-y-1 hover:border-red-500 hover:bg-slate-800 hover:text-white"
          >
            ← Back
          </.link>

          <div class="mb-8">
            <h1 class="text-5xl font-bold text-red-500">{@page_title}</h1>
            <p class="mt-2 text-slate-300">
              Build a D&D character sheet with stats, notes, and a character portrait.
            </p>
          </div>

          <div class="rounded-2xl border border-red-800 bg-slate-900 p-6 shadow-xl">
            <.form
              for={@form}
              id="character-form"
              phx-change="validate"
              phx-submit="save"
              class="space-y-8"
            >
              <section>
                <h2 class="mb-4 text-2xl font-bold text-red-400">Character Portrait</h2>

                <div class="grid grid-cols-1 gap-6 md:grid-cols-[220px_1fr]">
                  <div class="flex items-center justify-center rounded-2xl border border-slate-700 bg-slate-800 p-4">
                    <%= if @character.portrait_path do %>
                      <img
                        src={@character.portrait_path}
                        alt={"Portrait for #{@character.name || "character"}"}
                        class="h-44 w-44 rounded-xl object-cover shadow-lg"
                      />
                    <% else %>
                      <div class="flex h-44 w-44 items-center justify-center rounded-xl border border-dashed border-slate-600 text-center text-sm text-slate-400">
                        No portrait yet
                      </div>
                    <% end %>
                  </div>

                  <div class="rounded-2xl border border-dashed border-red-700 bg-slate-950 p-6 transition duration-200 hover:border-red-500 hover:bg-slate-900">
                    <label class="block text-lg font-bold text-red-300">
                      Upload Character Image
                    </label>

                    <p class="mt-2 text-sm text-slate-400">
                      Add a portrait for this character. Accepted formats: jpg, jpeg, png, webp, gif.
                    </p>

                    <div class="mt-4">
                      <.live_file_input
                        upload={@uploads.portrait}
                        class="block w-full cursor-pointer rounded-lg border border-slate-700 bg-slate-800 p-3 text-sm text-slate-200 file:mr-4 file:rounded-lg file:border-0 file:bg-red-600 file:px-4 file:py-2 file:font-bold file:text-white hover:file:bg-red-700"
                      />
                    </div>

                    <%= for entry <- @uploads.portrait.entries do %>
                      <div class="mt-4 rounded-xl border border-slate-700 bg-slate-800 p-4">
                        <div class="flex items-center justify-between">
                          <p class="font-bold text-slate-200">{entry.client_name}</p>
                          <p class="text-sm text-yellow-300">{entry.progress}%</p>
                        </div>

                        <div class="mt-3 h-2 rounded-full bg-slate-700">
                          <div
                            class="h-2 rounded-full bg-red-600"
                            style={"width: #{entry.progress}%"}
                          >
                          </div>
                        </div>
                      </div>
                    <% end %>

                    <%= for err <- upload_errors(@uploads.portrait) do %>
                      <p class="mt-2 text-sm text-red-300">{upload_error_to_string(err)}</p>
                    <% end %>
                  </div>
                </div>
              </section>

              <section>
                <h2 class="mb-4 text-2xl font-bold text-red-400">Basic Info</h2>

                <div class="grid grid-cols-1 gap-4 md:grid-cols-3">
                  <.styled_input form={@form} field={:name} label="Name" type="text" />
                  <.styled_input form={@form} field={:race} label="Race" type="text" />
                  <.styled_input form={@form} field={:class} label="Class" type="text" />
                  <.styled_input form={@form} field={:level} label="Level" type="number" />
                  <.styled_input form={@form} field={:hp} label="HP" type="number" />
                  <.styled_input form={@form} field={:armor_class} label="Armor Class" type="number" />
                </div>
              </section>

              <section>
                <h2 class="mb-4 text-2xl font-bold text-red-400">Ability Scores</h2>

                <div class="grid grid-cols-1 gap-4 md:grid-cols-3">
                  <.styled_input form={@form} field={:strength} label="Strength" type="number" />
                  <.styled_input form={@form} field={:dexterity} label="Dexterity" type="number" />
                  <.styled_input
                    form={@form}
                    field={:constitution}
                    label="Constitution"
                    type="number"
                  />
                  <.styled_input
                    form={@form}
                    field={:intelligence}
                    label="Intelligence"
                    type="number"
                  />
                  <.styled_input form={@form} field={:wisdom} label="Wisdom" type="number" />
                  <.styled_input form={@form} field={:charisma} label="Charisma" type="number" />
                </div>
              </section>

              <section>
                <h2 class="mb-4 text-2xl font-bold text-red-400">Notes</h2>

                <textarea
                  name="character[notes]"
                  class="min-h-32 w-full rounded-lg border border-slate-700 bg-slate-800 px-4 py-3 text-white transition duration-200 focus:border-red-500 focus:outline-none focus:ring-2 focus:ring-red-600"
                ><%= @form[:notes].value %></textarea>
              </section>

              <footer class="flex flex-wrap gap-3">
                <button
                  type="submit"
                  phx-disable-with="Saving..."
                  class="rounded-xl bg-red-600 px-6 py-3 font-bold text-white transition duration-200 hover:-translate-y-1 hover:bg-red-700 hover:shadow-xl hover:shadow-red-950 active:translate-y-0"
                >
                  Save Character
                </button>

                <.link
                  navigate={return_path(@return_to, @character)}
                  class="rounded-xl bg-slate-700 px-6 py-3 font-bold text-white transition duration-200 hover:-translate-y-1 hover:bg-slate-600"
                >
                  Cancel
                </.link>
              </footer>
            </.form>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  attr :form, :any, required: true
  attr :field, :atom, required: true
  attr :label, :string, required: true
  attr :type, :string, default: "text"

  def styled_input(assigns) do
    ~H"""
    <div>
      <label class="mb-1 block text-sm text-slate-300">{@label}</label>
      <input
        type={@type}
        name={"character[#{@field}]"}
        value={@form[@field].value}
        class="w-full rounded-lg border border-slate-700 bg-slate-800 px-4 py-3 text-white transition duration-200 focus:border-red-500 focus:outline-none focus:ring-2 focus:ring-red-600"
      />

      <%= for {msg, _opts} <- @form[@field].errors do %>
        <p class="mt-1 text-sm text-red-300">{msg}</p>
      <% end %>
    </div>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(:return_to, return_to(params["return_to"]))
      |> allow_upload(:portrait,
        accept: ~w(.jpg .jpeg .png .webp .gif),
        max_entries: 1,
        max_file_size: 5_000_000
      )
      |> apply_action(socket.assigns.live_action, params)

    {:ok, socket}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    character = Dnd.get_character!(id)

    socket
    |> assign(:page_title, "Edit Character")
    |> assign(:character, character)
    |> assign(:form, to_form(Dnd.change_character(character)))
  end

  defp apply_action(socket, :new, _params) do
    character = %Character{}

    socket
    |> assign(:page_title, "New Character")
    |> assign(:character, character)
    |> assign(:form, to_form(Dnd.change_character(character)))
  end

  @impl true
  def handle_event("validate", %{"character" => character_params}, socket) do
    changeset = Dnd.change_character(socket.assigns.character, character_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"character" => character_params}, socket) do
    portrait_path = save_uploaded_portrait(socket)
    character_params = put_portrait_path(character_params, portrait_path)

    save_character(socket, socket.assigns.live_action, character_params)
  end

  defp save_character(socket, :edit, character_params) do
    case Dnd.update_character(socket.assigns.character, character_params) do
      {:ok, character} ->
        {:noreply,
         socket
         |> put_flash(:info, "Character updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, character))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_character(socket, :new, character_params) do
    case Dnd.create_character(character_params) do
      {:ok, character} ->
        {:noreply,
         socket
         |> put_flash(:info, "Character created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, character))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_uploaded_portrait(socket) do
    upload_dir = Path.join(["priv", "static", "images", "characters"])
    File.mkdir_p!(upload_dir)

    socket
    |> consume_uploaded_entries(:portrait, fn %{path: path}, entry ->
      extension = Path.extname(entry.client_name)
      filename = "#{Ecto.UUID.generate()}#{extension}"
      destination = Path.join(upload_dir, filename)

      File.cp!(path, destination)

      {:ok, "/images/characters/#{filename}"}
    end)
    |> List.first()
  end

  defp put_portrait_path(params, nil), do: params

  defp put_portrait_path(params, portrait_path),
    do: Map.put(params, "portrait_path", portrait_path)

  defp upload_error_to_string(:too_large),
    do: "File is too large. Please upload an image under 5 MB."

  defp upload_error_to_string(:too_many_files), do: "You can only upload one portrait."

  defp upload_error_to_string(:not_accepted),
    do: "Please upload a jpg, jpeg, png, webp, or gif image."

  defp upload_error_to_string(error), do: "Upload error: #{inspect(error)}"

  defp return_path("index", _character), do: ~p"/dnd/characters"
  defp return_path("show", character), do: ~p"/dnd/characters/#{character.id}"
end
