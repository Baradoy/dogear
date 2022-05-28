const observerHandler = (inViewMap, currentAnchor, scrollTo, pushAnchor) => (entries) => {
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
  const topAnchor = Array.from(inViewMap).reduceRight((acc, anchor) => {
    if (
      !acc ||
      anchor[1] < acc[1] ||
      (anchor[1] == acc[1] && anchor[0] < acc[0])
    ) {
      return anchor;
    } else {
      return acc;
    }
  });

  if (topAnchor[0] != currentAnchor) {
    pushAnchor(topAnchor[0]);
    currentAnchor = topAnchor[0];
  }
};

function debounce(func, timeout = 300){
  let timer;
  let value;

  const fire = () => {
    if (value) {
      func.apply(this, value);
      value = null;
      timer = setTimeout(fire, timeout)
    } else {
      timer = null;
    }
  }

  return (...args) => {
    value = args;
    if (!timer) {
      timer = setTimeout(fire)
    }
  };
}


const intersectionObserver = {
  mounted() {
    this.handleEvent("scrollTo", ({ anchorId }) => {
      document.getElementById(anchorId).scrollIntoView();
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
    this.scrollTo = null;

    const pushAnchor = debounce((anchorId) => this.pushEvent("updateAnchor", { anchorId }))

    const observer = new IntersectionObserver(
      observerHandler(this.inView, this.currentAnchor, this.scrollTo, pushAnchor)
    );
    this.el.querySelectorAll("*[id]").forEach((elem) => observer.observe(elem));

    this.el.observer = observer;
  },
};

module.exports = intersectionObserver;
