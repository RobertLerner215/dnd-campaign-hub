defmodule AppWeb.ChartsLive do
  use AppWeb, :live_view

  @survey_questions [
    %{
      question: "Do you have at least one sibling?",
      labels: ["Yes", "No"],
      data: [10, 3],
      colors: ["#3b82f6", "#ef4444"]
    },
    %{
      question: "Do you prefer coffee or tea?",
      labels: ["Coffee", "Tea", "Neither"],
      data: [7, 4, 2],
      colors: ["#8b5cf6", "#22c55e", "#f97316"]
    },
    %{
      question: "Do you prefer cats or dogs?",
      labels: ["Cats", "Dogs", "Both"],
      data: [5, 6, 2],
      colors: ["#06b6d4", "#f59e0b", "#a855f7"]
    },
    %{
      question: "Do you like working in groups?",
      labels: ["Yes", "No", "Sometimes"],
      data: [6, 2, 5],
      colors: ["#10b981", "#ef4444", "#6366f1"]
    },
    %{
      question: "What is your favorite type of game?",
      labels: ["Action", "Strategy", "Sports", "RPG"],
      data: [4, 3, 2, 4],
      colors: ["#ef4444", "#3b82f6", "#22c55e", "#eab308"]
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    question_index = 0
    questions = @survey_questions
    question = Enum.at(questions, question_index)
    deals = fetch_game_deals()

    socket =
      socket
      |> assign(:questions, questions)
      |> assign(:question_index, question_index)
      |> assign(:question, question)
      |> assign(:survey_config, survey_chart_config(question))
      |> assign(:deals, deals)
      |> assign(:deals_config, deals_chart_config(deals))
      |> assign(:message, nil)

    {:ok, socket}
  end

  @impl true
  def handle_event("random-question", _params, socket) do
    current_index = socket.assigns.question_index
    questions = socket.assigns.questions

    random_index =
      0..(length(questions) - 1)
      |> Enum.reject(fn index -> index == current_index end)
      |> Enum.random()

    question = Enum.at(questions, random_index)

    socket =
      socket
      |> assign(:question_index, random_index)
      |> assign(:question, question)
      |> assign(:survey_config, survey_chart_config(question))
      |> assign(:message, nil)

    {:noreply, socket}
  end

  @impl true
  def handle_event("vote", %{"answer" => answer}, socket) do
    question = socket.assigns.question
    answer_index = Enum.find_index(question.labels, fn label -> label == answer end)

    updated_data =
      question.data
      |> List.update_at(answer_index, fn count -> count + 1 end)

    updated_question = %{question | data: updated_data}

    updated_questions =
      List.replace_at(socket.assigns.questions, socket.assigns.question_index, updated_question)

    socket =
      socket
      |> assign(:questions, updated_questions)
      |> assign(:question, updated_question)
      |> assign(:survey_config, survey_chart_config(updated_question))
      |> assign(:message, "Your answer was added to the chart.")

    {:noreply, socket}
  end

  defp survey_chart_config(question) do
    %{
      type: "bar",
      data: %{
        labels: question.labels,
        datasets: [
          %{
            label: "Student Answers",
            data: question.data,
            backgroundColor: question.colors,
            borderColor: question.colors,
            borderWidth: 1
          }
        ]
      },
      options: %{
        responsive: true,
        maintainAspectRatio: false,
        plugins: %{
          legend: %{
            display: true,
            labels: %{color: "#e5e7eb"}
          },
          title: %{
            display: true,
            text: question.question,
            color: "#e5e7eb"
          }
        },
        scales: %{
          x: %{
            ticks: %{color: "#e5e7eb"},
            grid: %{color: "#334155"}
          },
          y: %{
            beginAtZero: true,
            ticks: %{
              precision: 0,
              color: "#e5e7eb"
            },
            grid: %{color: "#334155"}
          }
        }
      }
    }
    |> Jason.encode!()
  end

  defp fetch_game_deals do
    url = "https://www.cheapshark.com/api/1.0/deals?storeID=1&upperPrice=15&pageSize=8"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
        |> Jason.decode!()
        |> Enum.map(fn game ->
          %{
            title: game["title"],
            sale_price: parse_price(game["salePrice"]),
            normal_price: parse_price(game["normalPrice"])
          }
        end)

      _ ->
        fallback_deals()
    end
  end

  defp parse_price(price) when is_binary(price) do
    case Float.parse(price) do
      {number, _} -> number
      :error -> 0.0
    end
  end

  defp parse_price(_), do: 0.0

  defp fallback_deals do
    [
      %{title: "Game One", sale_price: 3.99, normal_price: 19.99},
      %{title: "Game Two", sale_price: 5.99, normal_price: 24.99},
      %{title: "Game Three", sale_price: 7.99, normal_price: 29.99},
      %{title: "Game Four", sale_price: 9.99, normal_price: 39.99},
      %{title: "Game Five", sale_price: 12.99, normal_price: 49.99}
    ]
  end

  defp deals_chart_config(deals) do
    %{
      type: "line",
      data: %{
        labels: Enum.map(deals, &short_title(&1.title)),
        datasets: [
          %{
            label: "Sale Price",
            data: Enum.map(deals, & &1.sale_price),
            borderColor: "#22c55e",
            backgroundColor: "#22c55e",
            borderWidth: 3,
            tension: 0.3
          },
          %{
            label: "Normal Price",
            data: Enum.map(deals, & &1.normal_price),
            borderColor: "#ef4444",
            backgroundColor: "#ef4444",
            borderWidth: 3,
            tension: 0.3
          }
        ]
      },
      options: %{
        responsive: true,
        maintainAspectRatio: false,
        plugins: %{
          legend: %{
            display: true,
            labels: %{color: "#e5e7eb"}
          },
          title: %{
            display: true,
            text: "CheapShark Steam Deals: Sale Price vs Normal Price",
            color: "#e5e7eb"
          }
        },
        scales: %{
          x: %{
            ticks: %{color: "#e5e7eb"},
            grid: %{color: "#334155"}
          },
          y: %{
            beginAtZero: true,
            ticks: %{color: "#e5e7eb"},
            grid: %{color: "#334155"},
            title: %{
              display: true,
              text: "Price in Dollars",
              color: "#e5e7eb"
            }
          }
        }
      }
    }
    |> Jason.encode!()
  end

  defp short_title(title) when is_binary(title) do
    if String.length(title) > 16 do
      String.slice(title, 0, 16) <> "..."
    else
      title
    end
  end

  defp short_title(_), do: "Game"

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-slate-950 text-slate-100 px-6 py-10">
      <div class="max-w-6xl mx-auto space-y-8">
        <div>
          <h1 class="text-4xl font-bold mb-2">Charts Assignment</h1>
          <p class="text-slate-300">
            This page asks a survey question, stores the answer in LiveView state, updates the bar chart, and shows real game price data from CheapShark.
          </p>
        </div>

        <section class="bg-slate-900 rounded-xl shadow p-6 border border-slate-700">
          <div class="flex flex-col md:flex-row md:items-start md:justify-between gap-4 mb-6">
            <div>
              <h2 class="text-2xl font-bold">Student Survey Question</h2>
              <p class="text-slate-300 mt-1">
                {@question.question}
              </p>
              <p class="text-sm text-slate-400 mt-1">
                Question {@question_index + 1} of {length(@questions)}
              </p>
            </div>

            <button
              phx-click="random-question"
              class="px-4 py-2 rounded-lg bg-blue-600 text-white font-semibold hover:bg-blue-700"
            >
              Random Question
            </button>
          </div>

          <div class="flex flex-wrap gap-3 mb-4">
            <button
              :for={answer <- @question.labels}
              phx-click="vote"
              phx-value-answer={answer}
              class="px-4 py-2 rounded-lg bg-slate-700 text-white font-semibold hover:bg-slate-600 border border-slate-500"
            >
              {answer}
            </button>
          </div>

          <p :if={@message} class="mb-4 text-green-400 font-semibold">
            {@message}
          </p>

          <div class="bg-slate-800 rounded-lg p-4 h-80">
            <canvas
              id="survey-chart"
              phx-hook="Chart"
              data-config={@survey_config}
            >
            </canvas>
          </div>
        </section>

        <section class="bg-slate-900 rounded-xl shadow p-6 border border-slate-700">
          <div class="mb-6">
            <h2 class="text-2xl font-bold">CheapShark API Line Chart</h2>
            <p class="text-slate-300">
              This chart uses HTTPoison to retrieve real JSON data from CheapShark and compares sale prices against normal prices.
            </p>
          </div>

          <div class="bg-slate-800 rounded-lg p-4 h-80">
            <canvas
              id="deals-chart"
              phx-hook="Chart"
              data-config={@deals_config}
            >
            </canvas>
          </div>

          <div class="mt-6 overflow-x-auto">
            <table class="w-full text-left border-collapse">
              <thead>
                <tr class="border-b border-slate-700">
                  <th class="py-2">Game</th>
                  <th class="py-2">Sale Price</th>
                  <th class="py-2">Normal Price</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  :for={deal <- @deals}
                  class="border-b border-slate-800"
                >
                  <td class="py-2">{deal.title}</td>
                  <td class="py-2">${deal.sale_price}</td>
                  <td class="py-2">${deal.normal_price}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>
      </div>
    </div>
    """
  end
end
