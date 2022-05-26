// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).
import "../css/app.css"

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

const observerHandler = (inViewMap, pushAnchor) => (entries) => {
  // Remove items that are no longer in view
  entries
    .filter(({ isIntersecting }) => !isIntersecting)
    .forEach(
      ({ target }) => inViewMap.delete(target.getAttribute("id"))
    );

  // Add items that are now in the view
  entries
    .filter(({ isIntersecting }) => isIntersecting)
    .forEach(
      ({ target }) => inViewMap.set(target.getAttribute("id"), target.offsetTop + target.clientHeight)
    );

  // Find the highest up element (measure from the bottom of the element)
  const topAnchor = Array.from(inViewMap).reduceRight((acc, anchor) => {
    if (!acc || anchor[1] < acc[1]) {
      return anchor;
    } else {
      return acc
    }
  });

  pushAnchor(topAnchor[0])
};

const Hooks = {}
Hooks.IntersectionObserver = {
  mounted() {
    this.handleEvent("scrollTo", ({ anchorId }) => {
      document.getElementById(anchorId).scrollIntoView();
    })

    const inViewMap = new Map();
    const pushAnchor = (anchorId) => (this.pushEvent("updateAnchor", { anchorId }))

    const observer = new IntersectionObserver(observerHandler(inViewMap, pushAnchor));
    this.el.querySelectorAll("*[id]").forEach(elem => observer.observe(elem));

    this.el.inView = inViewMap;
    this.el.observer = observer;
  },
  updated() {
    if (this.el.observer) {
      // When live view patches the DOM, we can no longer rely on the old observer.
      this.el.observer.disconnect();
      this.el.scrollIntoView();
    }

    const inViewMap = new Map();
    const pushAnchor = (anchorId) => (this.pushEvent("updateAnchor", { anchorId }))

    const observer = new IntersectionObserver(observerHandler(inViewMap, pushAnchor), { root: null });
    this.el.querySelectorAll("*[id]").forEach(elem => observer.observe(elem));

    this.el.inView = inViewMap;
    this.el.observer = observer;
  }
}


let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, { hooks: Hooks, params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
