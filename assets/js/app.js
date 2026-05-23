// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"

// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { hooks as colocatedHooks } from "phoenix-colocated/app"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"

// ------------------------
// 🔥 CUSTOM HOOKS
// ------------------------

let Hooks = {}

// ✅ AUTOSCROLL
Hooks.AutoScroll = {
  updated() {
    this.el.scrollTop = this.el.scrollHeight
  }
}

// ✅ FOCUS INPUT AFTER SEND
Hooks.FocusInput = {
  mounted() {
    this.handleEvent("focus-input", () => {
      let input = document.getElementById("chat_message")
      if (input) {
        input.focus()
      }
    })
  }
}

// 🔥 LOGOUT HOOK (NEW)
Hooks.LogoutButton = {
  mounted() {
    this.handleEvent("logout", () => {
      let btn = document.getElementById("logout-button")
      if (btn) btn.click()
    })
  }
}

// ------------------------
// SOCKET SETUP
// ------------------------

const csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content")

let liveSocketPath =
  process.env.NODE_ENV === "production" ? "/csci379f/live" : "/live"

// 🔥 MERGE HOOKS (YOU ALREADY DID THIS RIGHT)
const liveSocket = new LiveSocket(liveSocketPath, Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: { ...colocatedHooks, ...Hooks },
})

// ------------------------
// TOPBAR
// ------------------------

topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", () => topbar.show(300))
window.addEventListener("phx:page-loading-stop", () => topbar.hide())

liveSocket.connect()
window.liveSocket = liveSocket

// ------------------------
// DARK MODE LOGIC
// ------------------------

function applyTheme() {
  if (
    localStorage.theme === "dark" ||
    (!localStorage.theme &&
      window.matchMedia("(prefers-color-scheme: dark)").matches)
  ) {
    document.documentElement.classList.add("dark")
  } else {
    document.documentElement.classList.remove("dark")
  }
}

window.toggleTheme = function () {
  if (document.documentElement.classList.contains("dark")) {
    localStorage.theme = "light"
  } else {
    localStorage.theme = "dark"
  }
  applyTheme()
}

// Apply immediately
applyTheme()
