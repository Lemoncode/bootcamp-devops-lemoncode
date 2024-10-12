const w = window.innerWidth;
const { clientWidth, clientHeight } = document.documentElement;
const getPercentX = (x) => Math.round((x / w) * 360);
const app = document.querySelector(".container");

let raf;
let start = {
  x: 0,
  y: 0,
  primary: 190,
};

function lerp(start, end) {
  const dx = end.x - start.x;
  const dy = end.y - start.y;
  const dp = end.primary - start.primary;

  return {
    x: start.x + dx * 0.05,
    y: start.y + dy * 0.05,
    primary: start.primary + dp * 0.05,
  };
}

document.addEventListener("mousemove", (e) => {
  const end = {
    x: (clientWidth / 2 - e.clientX) / clientWidth,
    y: (clientHeight / 2 - e.clientY) / clientHeight,
    primary: getPercentX(e.clientX),
  };

  start = lerp(start, end);
  raf = raf || requestAnimationFrame(update);
});

function update() {
  app.style.setProperty("--x", start.x);
  app.style.setProperty("--y", start.y);
  app.style.setProperty("--primary", start.primary);
  raf = null;
}
