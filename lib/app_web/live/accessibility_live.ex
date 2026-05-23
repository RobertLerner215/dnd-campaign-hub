defmodule AppWeb.AccessibilityLive do
  use AppWeb, :live_view

  alias Makeup.Lexers.ElixirLexer
  alias Makeup.Formatters.HTML.HTMLFormatter

  @impl true
  def mount(_params, _session, socket) do
    markdown =
      "priv/accessibility.md"
      |> File.read!()
      |> highlight_code_blocks()
      |> Earmark.as_html!()

    {:ok,
     socket
     |> assign(:page_title, "Accessibility")
     |> assign(:content, markdown)}
  end

  defp highlight_code_blocks(markdown) do
    Regex.replace(
      ~r/```(heex|elixir|html)?\s+([\s\S]*?)```/,
      markdown,
      fn _, _lang, code ->
        html =
          Makeup.highlight_inner_html(
            code,
            lexer: ElixirLexer,
            formatter: HTMLFormatter
          )

        "<pre><code class=\"highlight\">#{html}</code></pre>"
      end
    )
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-5xl mx-auto px-8 py-10 text-white">
        <div class="bg-slate-900 rounded-2xl shadow-xl p-10 leading-8">
          <article class="
            space-y-6
            [&_h1]:text-5xl
            [&_h1]:font-bold
            [&_h1]:mb-8

            [&_h2]:text-3xl
            [&_h2]:font-semibold
            [&_h2]:mt-10
            [&_h2]:mb-4

            [&_h3]:text-2xl
            [&_h3]:font-semibold
            [&_h3]:mt-6
            [&_h3]:mb-3

            [&_p]:text-lg
            [&_p]:leading-8

            [&_hr]:border-slate-700
            [&_hr]:my-8

            [&_pre]:bg-[#1e1e1e]
            [&_pre]:rounded-xl
            [&_pre]:p-5
            [&_pre]:overflow-x-auto
            [&_pre]:my-5
            [&_pre]:border
            [&_pre]:border-slate-700

            [&_code]:font-mono
            [&_code]:text-sm
          ">
            {Phoenix.HTML.raw(@content)}
          </article>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
