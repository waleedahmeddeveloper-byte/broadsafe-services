(function () {
  "use strict";

  function readCookie(name) {
    var match = document.cookie.match(
      new RegExp("(?:^|; )" + name + "=([^;]+)"),
    );
    return match ? decodeURIComponent(match[1]) : "";
  }

  function writeCookie(name, value, days) {
    var expires = "";
    if (typeof days === "number") {
      var date = new Date();
      date.setTime(date.getTime() + days * 24 * 60 * 60 * 1000);
      expires = "; expires=" + date.toUTCString();
    }
    document.cookie =
      name + "=" + encodeURIComponent(value) + expires + "; path=/";
  }

  function getPreferredTheme() {
    var fromCookie = readCookie("theme");
    if (fromCookie === "dark" || fromCookie === "light") {
      return fromCookie;
    }
    try {
      var fromStorage = localStorage.getItem("theme");
      if (fromStorage === "dark" || fromStorage === "light") {
        return fromStorage;
      }
    } catch (e) {
      // Ignore storage access errors.
    }
    return "light";
  }

  function swapLogos(isDark) {
    var lightLogos = document.querySelectorAll(".logo-light");
    var darkLogos = document.querySelectorAll(".logo-dark");

    for (var i = 0; i < lightLogos.length; i += 1) {
      lightLogos[i].style.display = isDark ? "none" : "";
    }
    for (var j = 0; j < darkLogos.length; j += 1) {
      darkLogos[j].style.display = isDark ? "" : "none";
    }
  }

  function updateToggleUI(isDark) {
    var toggle =
      document.getElementById("themeToggle") ||
      document.getElementById("theme-toggle");
    if (!toggle) {
      return;
    }
    toggle.innerHTML = isDark
      ? '<i class="fas fa-sun"></i> Light Mode'
      : '<i class="fas fa-moon"></i> Dark Mode';
    toggle.setAttribute("aria-pressed", isDark ? "true" : "false");
  }

  function applyTheme(theme) {
    var isDark = theme === "dark";
    if (document.body) {
      document.body.classList.toggle("dark-theme", isDark);
    }
    document.documentElement.setAttribute("data-theme", theme);
    document.documentElement.classList.remove("dark-theme-preload");
    swapLogos(isDark);
    updateToggleUI(isDark);

    writeCookie("theme", theme, 30);
    try {
      localStorage.setItem("theme", theme);
    } catch (e) {
      // Ignore storage access errors.
    }
  }

  function ensureToggleButton() {
    var existing =
      document.getElementById("themeToggle") ||
      document.getElementById("theme-toggle");
    if (existing) {
      if (!existing.classList.contains("theme-button")) {
        existing.classList.add("theme-button");
      }
      return existing;
    }

    var toggle = document.createElement("button");
    toggle.id = "themeToggle";
    toggle.className = "theme-button";
    toggle.type = "button";
    toggle.setAttribute("aria-label", "Toggle dark mode");
    document.body.appendChild(toggle);
    return toggle;
  }

  function initMobileNav() {
    var menuBtn = document.querySelector(".mobile-menu-btn");
    var mobileNav = document.querySelector(".mobile-nav");
    var closeBtn = document.querySelector(".mobile-nav-close");

    if (!menuBtn || !mobileNav || window.__mobileNavInitialized) {
      return false;
    }

    window.__mobileNavInitialized = true;

    if (!mobileNav.id) {
      mobileNav.id = "mobile-nav";
    }
    menuBtn.setAttribute("aria-controls", mobileNav.id);
    menuBtn.setAttribute("aria-expanded", "false");
    mobileNav.setAttribute("aria-hidden", "true");

    function setOpenState(open) {
      mobileNav.classList.toggle("is-open", open);
      mobileNav.classList.toggle("active", open);
      document.body.classList.toggle("nav-open", open);
      document.body.style.overflow = open ? "hidden" : "";
      menuBtn.setAttribute("aria-expanded", open ? "true" : "false");
      mobileNav.setAttribute("aria-hidden", open ? "false" : "true");
    }

    function toggleMenu() {
      var isOpen =
        mobileNav.classList.contains("is-open") ||
        mobileNav.classList.contains("active");
      setOpenState(!isOpen);
    }

    function closeMenu() {
      setOpenState(false);
    }

    menuBtn.addEventListener("click", toggleMenu);

    if (closeBtn) {
      closeBtn.addEventListener("click", closeMenu);
    }

    mobileNav.addEventListener("click", function (event) {
      if (event.target.closest("a")) {
        closeMenu();
      }
    });

    document.addEventListener("keydown", function (event) {
      if (event.key === "Escape") {
        closeMenu();
      }
    });

    window.addEventListener("resize", function () {
      if (window.innerWidth > 767) {
        closeMenu();
      }
    });

    return true;
  }

  function initMobileNavWithRetry() {
    if (initMobileNav()) {
      return;
    }

    var attempts = 0;
    var maxAttempts = 20;
    var timer = setInterval(function () {
      attempts += 1;
      if (initMobileNav() || attempts >= maxAttempts) {
        clearInterval(timer);
      }
    }, 100);

    window.addEventListener(
      "load",
      function () {
        initMobileNav();
      },
      { once: true },
    );
  }

  function initFaqAccordions() {
    var faqItems = document.querySelectorAll(".faq-item");
    if (!faqItems.length) {
      return;
    }

    var idCounter = 0;

    function closeItem(item) {
      var question = item.querySelector(".faq-question");
      var answer = item.querySelector(".faq-answer");
      item.classList.remove("active");
      if (answer) {
        answer.classList.remove("active");
        answer.setAttribute("aria-hidden", "true");
      }
      if (question) {
        question.setAttribute("aria-expanded", "false");
      }
    }

    function openItem(item) {
      var question = item.querySelector(".faq-question");
      var answer = item.querySelector(".faq-answer");
      item.classList.add("active");
      if (answer) {
        answer.classList.add("active");
        answer.setAttribute("aria-hidden", "false");
      }
      if (question) {
        question.setAttribute("aria-expanded", "true");
      }
    }

    for (var i = 0; i < faqItems.length; i += 1) {
      var item = faqItems[i];
      var question = item.querySelector(".faq-question");
      var answer = item.querySelector(".faq-answer");

      if (!question || !answer || question.dataset.faqBound === "true") {
        continue;
      }

      idCounter += 1;
      if (!answer.id) {
        answer.id = "faq-answer-" + idCounter;
      }

      question.setAttribute("role", "button");
      question.setAttribute("tabindex", "0");
      question.setAttribute("aria-controls", answer.id);
      question.setAttribute(
        "aria-expanded",
        item.classList.contains("active") ? "true" : "false",
      );
      answer.setAttribute(
        "aria-hidden",
        item.classList.contains("active") ? "false" : "true",
      );
      question.dataset.faqBound = "true";

      question.addEventListener("click", function () {
        var currentItem = this.closest(".faq-item");
        if (!currentItem) {
          return;
        }

        var shouldOpen = !currentItem.classList.contains("active");
        for (var j = 0; j < faqItems.length; j += 1) {
          closeItem(faqItems[j]);
        }
        if (shouldOpen) {
          openItem(currentItem);
        }
      });

      question.addEventListener("keydown", function (event) {
        if (event.key === "Enter" || event.key === " ") {
          event.preventDefault();
          this.click();
        }
      });
    }
  }

  function boot() {
    var preferred = getPreferredTheme();
    applyTheme(preferred);
    initMobileNavWithRetry();
    initFaqAccordions();

    var toggle = ensureToggleButton();
    updateToggleUI(preferred === "dark");

    toggle.addEventListener("click", function () {
      var nextTheme =
        document.body && document.body.classList.contains("dark-theme")
          ? "light"
          : "dark";
      applyTheme(nextTheme);
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
