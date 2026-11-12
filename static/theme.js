// Light / dark / system toggle for the corner button.
// Cycles System -> Light -> Dark. The saved choice lives in localStorage under
// "theme" and is mirrored onto <html data-theme>. The head script in base.html
// applies it before first paint; this file only drives the button.
(function () {
  var KEY = "theme";
  var MODES = ["system", "light", "dark"];
  var root = document.documentElement;
  var button = document.querySelector(".theme-toggle");
  if (!button) return;

  function nextMode(mode) {
    return MODES[(MODES.indexOf(mode) + 1) % MODES.length];
  }

  function readSaved() {
    try {
      var saved = localStorage.getItem(KEY);
      return MODES.indexOf(saved) === -1 ? "system" : saved;
    } catch (e) {
      return "system";
    }
  }

  function save(mode) {
    try {
      localStorage.setItem(KEY, mode);
    } catch (e) {
      // Storage blocked: the choice still applies for this page view.
    }
  }

  function render(mode) {
    if (mode === "system") {
      root.removeAttribute("data-theme");
    } else {
      root.setAttribute("data-theme", mode);
    }
    var label = "Switch to " + nextMode(mode) + " theme";
    button.dataset.mode = mode;
    button.setAttribute("aria-label", label);
    button.title = label;
  }

  var current = readSaved();
  render(current);
  button.hidden = false; // only show the control once it can work

  button.addEventListener("click", function () {
    current = nextMode(current);
    save(current);
    render(current);
  });
})();
