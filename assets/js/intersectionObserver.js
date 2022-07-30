// Scope is difficult.
let scrollingTo = null;
let scrollingToTimer = null;

const observerHandler = (inViewMap, currentAnchor, pushAnchor) => (entries) => {
  // Remove items that are no longer in view
  entries
    .filter(({ isIntersecting }) => !isIntersecting)
    .forEach(({ target }) => inViewMap.delete(target.getAttribute("id")));

  // Add items that are now in the view
  entries
    .filter(({ isIntersecting }) => isIntersecting)
    .forEach(({ target }) =>
      inViewMap.set(
        target.getAttribute("id"),
        target.offsetTop + target.clientHeight
      )
    );

  // Find the highest up element (measure from the bottom of the element)
  const anchorList = Array.from(inViewMap)
  const defaultAnchor = anchorList.pop()
  const topAnchor = anchorList.reduce((acc, anchor) => {
    if (
      anchor[1] < acc[1] ||
      (anchor[1] == acc[1] && anchor[0] < acc[0])
    ) {
      return anchor;
    } else {
      return acc;
    }
  }, defaultAnchor);

  if (topAnchor[0] != currentAnchor) {
    currentAnchor = topAnchor[0];
    !scrollingTo && pushAnchor(topAnchor[0]);
  }
  if (topAnchor[0] == scrollingTo) {
    scrollingTo = null;
  }
};

function debounce(func, timeout = 300) {
  let timer;
  let value;

  const fire = () => {
    if (value) {
      func.apply(this, value);
      value = null;
      timer = setTimeout(fire, timeout);
    } else {
      timer = null;
    }
  };

  return (...args) => {
    value = args;
    if (!timer) {
      timer = setTimeout(fire);
    }
  };
}

const intersectionObserver = {
  mounted() {
    this.handleEvent("scrollTo", ({ anchorId }) => {
      scrollingTo = anchorId;
      document.getElementById(anchorId)?.scrollIntoView({ behavior: "smooth" });
      clearTimeout(scrollingToTimer);
      scrollingToTimer =
        anchorId &&
        setTimeout(() => {
          scrollingTo = null;
        }, 2000);
    });

    this.observe();
  },
  updated() {
    if (this.el.observer) {
      // When live view patches the DOM, we can no longer rely on the old observer.
      this.el.observer.disconnect();
      this.el.scrollIntoView();
    }

    this.observe();
  },
  observe() {
    this.currentAnchor = "";
    this.inView = new Map();

    const pushAnchor = debounce((anchorId) =>
      this.pushEvent("updateAnchor", { anchorId })
    );

    const observer = new IntersectionObserver(
      observerHandler(this.inView, this.currentAnchor, pushAnchor)
    );
    this.el.querySelectorAll("*[id]").forEach((elem) => observer.observe(elem));

    this.el.observer = observer;
  },
};

module.exports = intersectionObserver;
