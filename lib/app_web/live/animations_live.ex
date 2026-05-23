defmodule AppWeb.AnimationsLive do
  use AppWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-slate-50 text-slate-900 dark:bg-slate-950 dark:text-white px-6 py-10">
      <div class="mx-auto max-w-6xl space-y-10">
        <div>
          <h1 class="text-4xl font-bold mb-2">Animations</h1>

          <p class="text-slate-600 dark:text-slate-300">
            3 animations and one custom animation.
          </p>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
          <!-- Animation 1 -->
          <section class="rounded-2xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 p-6 shadow-sm">
            <h2 class="text-2xl font-semibold mb-2">Pulse Dots</h2>

            <p class="text-sm text-slate-600 dark:text-slate-300 mb-4">
              Inspired by common loading dot examples.
            </p>

            <div class="flex justify-center items-center min-h-[180px]">
              <div class="pulse-dots">
                <span></span>
                <span></span>
                <span></span>
              </div>
            </div>

            <p class="text-sm mt-4">
              Reference:
              <a
                href="https://cssloaders.github.io/"
                target="_blank"
                class="text-blue-600 dark:text-blue-400 underline"
              >
                CSS Loaders
              </a>
            </p>
          </section>
          
    <!-- Animation 2 -->
          <section class="rounded-2xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 p-6 shadow-sm">
            <h2 class="text-2xl font-semibold mb-2">Spinning Ring</h2>

            <p class="text-sm text-slate-600 dark:text-slate-300 mb-4">
              A simple CSS ring spinner.
            </p>

            <div class="flex justify-center items-center min-h-[180px]">
              <div class="ring-loader"></div>
            </div>

            <p class="text-sm mt-4">
              Reference:
              <a
                href="https://uiverse.io/loaders"
                target="_blank"
                class="text-blue-600 dark:text-blue-400 underline"
              >
                UIverse Loaders
              </a>
            </p>
          </section>
          
    <!-- Animation 3 -->
          <section class="rounded-2xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 p-6 shadow-sm">
            <h2 class="text-2xl font-semibold mb-2">Bouncing Squares</h2>

            <p class="text-sm text-slate-600 dark:text-slate-300 mb-4">
              A staggered block animation.
            </p>

            <div class="flex justify-center items-center min-h-[180px]">
              <div class="square-loader">
                <span></span>
                <span></span>
                <span></span>
                <span></span>
              </div>
            </div>

            <p class="text-sm mt-4">
              Reference:
              <a
                href="https://loading.io/css/"
                target="_blank"
                class="text-blue-600 dark:text-blue-400 underline"
              >
                loading.io CSS
              </a>
            </p>
          </section>
          
    <!-- Custom Animation -->
          <section class="rounded-2xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 p-6 shadow-sm">
            <h2 class="text-2xl font-semibold mb-2">Cat Orbit Loader</h2>

            <p class="text-sm text-slate-600 dark:text-slate-300 mb-4">
              My custom infinite loader with orbiting cats.
            </p>

            <div class="flex justify-center items-center min-h-[180px]">
              <div class="orbit-loader">
                <div class="orbit-center">🐾</div>

                <div class="orbit-ring orbit-ring-1">
                  <span>🐱</span>
                </div>

                <div class="orbit-ring orbit-ring-2">
                  <span>😺</span>
                </div>
              </div>
            </div>
          </section>
        </div>
      </div>
    </div>

    <!-- Replicated Professor Animation -->
    <section class="rounded-2xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 p-6 shadow-sm">
      <h2 class="text-2xl font-semibold mb-2">Replicated Bar Animation</h2>

      <p class="text-sm text-slate-600 dark:text-slate-300 mb-6">
        Eight bars with delayed height changes and green-to-white color progression.
      </p>

      <div class="flex justify-center items-end min-h-[220px]">
        <div class="audio-bars">
          <div class="bar"></div>
          <div class="bar"></div>
          <div class="bar"></div>
          <div class="bar"></div>
          <div class="bar"></div>
          <div class="bar"></div>
          <div class="bar"></div>
          <div class="bar"></div>
        </div>
      </div>
    </section>
    """
  end
end
