defmodule AppWeb.PageController do
  use AppWeb, :controller

  @courses [
    # -------- FALL 2025 --------
    %{semester: "fall_2025", number: "CSCI 311", title: "Algorithm Design & Analysis"},
    %{semester: "fall_2025", number: "BIOL 122", title: "Biology for Non-majors"},
    %{semester: "fall_2025", number: "EAST 251", title: "Buddhism"},
    %{semester: "fall_2025", number: "CSCI 475", title: "Senior Design I"},

    # -------- SPRING 2026 --------
    %{semester: "spring_2026", number: "SLIF 001", title: "Athletic Time Block All"},
    %{semester: "spring_2026", number: "CSCI 379", title: "Full Stack Web Development"},
    %{semester: "spring_2026", number: "CSCI 476", title: "Senior Design II"},
    %{semester: "spring_2026", number: "GEOG 240", title: "Sustaining Nature"}
  ]

  @valid_semesters @courses |> Enum.map(& &1.semester) |> Enum.uniq()

  # Home page
  def home(conn, _params) do
    render(conn, :home)
  end

  # /courses
  def courses(conn, params) when map_size(params) == 0 do
    render(conn, :courses, courses: @courses, semester: nil)
  end

  # /courses/:slug
  def courses(conn, %{"slug" => slug}) when slug in @valid_semesters do
    filtered =
      Enum.filter(@courses, fn c ->
        c.semester == slug
      end)

    render(conn, :courses, courses: filtered, semester: slug)
  end
end
