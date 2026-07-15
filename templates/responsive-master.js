/* ====== RESPONSIVE JAVASCRIPT - BROADSAFE ====== */
/* Copy this into each page's <script> block */

// ====== COOKIE CONSENT FUNCTIONS ======
function setCookie(name, value, days) {
    const expires = new Date(Date.now() + days * 864e5).toUTCString();
    document.cookie = name + '=' + encodeURIComponent(value) + '; expires=' + expires + '; path=/';
}

function getCookie(name) {
    return document.cookie.split('; ').reduce((r, v) => {
        const parts = v.split('=');
        return parts[0] === name ? decodeURIComponent(parts[1]) : r;
    }, '');
}

// ====== THEME TOGGLE FUNCTIONALITY ======
function initThemeToggle() {
    const savedTheme = localStorage.getItem('theme') || 'light';
    document.documentElement.setAttribute('data-theme', savedTheme);
    
    const themeToggle = document.getElementById('theme-toggle');
    if (themeToggle) {
        themeToggle.addEventListener('click', function() {
            const currentTheme = document.documentElement.getAttribute('data-theme');
            const newTheme = currentTheme === 'light' ? 'dark' : 'light';
            document.documentElement.setAttribute('data-theme', newTheme);
            localStorage.setItem('theme', newTheme);
        });
    }
}

// ====== MOBILE MENU FUNCTIONALITY ======
function initMobileMenu() {
    const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
    const mobileNav = document.querySelector('.mobile-nav');
    const mobileNavClose = document.querySelector('.mobile-nav-close');
    const mobileNavLinks = document.querySelectorAll('.mobile-nav a');

    if (mobileMenuBtn && mobileNav) {
        mobileMenuBtn.addEventListener('click', function() {
            mobileNav.classList.add('active');
            document.body.style.overflow = 'hidden';
        });
    }

    if (mobileNavClose && mobileNav) {
        mobileNavClose.addEventListener('click', function() {
            mobileNav.classList.remove('active');
            document.body.style.overflow = '';
        });
    }

    mobileNavLinks.forEach(link => {
        link.addEventListener('click', function() {
            if (mobileNav) {
                mobileNav.classList.remove('active');
                document.body.style.overflow = '';
            }
        });
    });

    // Close on outside click
    document.addEventListener('click', function(e) {
        if (mobileNav && mobileNav.classList.contains('active')) {
            if (!mobileNav.contains(e.target) && !mobileMenuBtn.contains(e.target)) {
                mobileNav.classList.remove('active');
                document.body.style.overflow = '';
            }
        }
    });
}

// ====== HEADER SCROLL EFFECTS (OPTIMIZED) ======
function initHeaderScroll() {
    let lastScrollTop = 0;
    let ticking = false;

    function updateHeader(scrollTop) {
        const header = document.querySelector('header');
        
        if (!header) return;

        if (scrollTop > lastScrollTop && scrollTop > 100) {
            header.style.transform = 'translateY(-100%)';
        } else {
            header.style.transform = 'translateY(0)';
        }

        if (scrollTop > 50) {
            header.style.boxShadow = '0 2px 10px rgba(0,0,0,0.1)';
        } else {
            header.style.boxShadow = 'none';
        }

        lastScrollTop = scrollTop;
        ticking = false;
    }

    window.addEventListener('scroll', function() {
        const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
        
        if (!ticking) {
            window.requestAnimationFrame(function() {
                updateHeader(scrollTop);
            });
            ticking = true;
        }
    }, { passive: true });
}

// ====== RESPONSIVE ENHANCEMENTS ======
function initResponsiveEnhancements() {
    let resizeTimer;
    
    function handleResize() {
        // Set CSS viewport height variable for mobile browsers
        document.documentElement.style.setProperty('--vh', `${window.innerHeight * 0.01}px`);
    }

    window.addEventListener('resize', function() {
        clearTimeout(resizeTimer);
        resizeTimer = setTimeout(handleResize, 250);
    });

    // Initial setup
    handleResize();
}

// ====== TOUCH OPTIMIZATIONS ======
function initTouchOptimizations() {
    // Add touch class to body for CSS targeting
    if ('ontouchstart' in window || navigator.maxTouchPoints > 0) {
        document.body.classList.add('touch-device');
    }

    // Prevent double-tap zoom on buttons
    const buttons = document.querySelectorAll('button, .cta-button, a[role="button"]');
    buttons.forEach(button => {
        button.addEventListener('touchend', function(e) {
            e.preventDefault();
            this.click();
        }, { passive: false });
    });
}

// ====== PREVENT ZOOM ON IOS FORM FOCUS ======
function preventIOSZoom() {
    const inputs = document.querySelectorAll('input, textarea, select');
    inputs.forEach(input => {
        if (parseFloat(window.getComputedStyle(input).fontSize) < 16) {
            input.style.fontSize = '16px';
        }
    });
}

// ====== LAZY LOADING IMAGES ======
function initLazyLoading() {
    if ('IntersectionObserver' in window) {
        const imageObserver = new IntersectionObserver((entries, observer) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const img = entry.target;
                    if (img.dataset.src) {
                        img.src = img.dataset.src;
                        img.removeAttribute('data-src');
                    }
                    observer.unobserve(img);
                }
            });
        });

        document.querySelectorAll('img[data-src]').forEach(img => {
            imageObserver.observe(img);
        });
    }
}

// ====== SMOOTH SCROLL FOR ANCHOR LINKS ======
function initSmoothScroll() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            const href = this.getAttribute('href');
            if (href === '#') return;
            
            const target = document.querySelector(href);
            if (target) {
                e.preventDefault();
                const headerOffset = 80;
                const elementPosition = target.getBoundingClientRect().top;
                const offsetPosition = elementPosition + window.pageYOffset - headerOffset;

                window.scrollTo({
                    top: offsetPosition,
                    behavior: 'smooth'
                });
            }
        });
    });
}

// ====== INITIALIZE ALL FUNCTIONS ======
document.addEventListener('DOMContentLoaded', function() {
    initThemeToggle();
    initMobileMenu();
    initHeaderScroll();
    initResponsiveEnhancements();
    initTouchOptimizations();
    preventIOSZoom();
    initLazyLoading();
    initSmoothScroll();
});

// ====== PAGE VISIBILITY API (PAUSE ANIMATIONS WHEN TAB INACTIVE) ======
document.addEventListener('visibilitychange', function() {
    if (document.hidden) {
        // Pause animations, videos, etc.
        document.body.classList.add('page-hidden');
    } else {
        document.body.classList.remove('page-hidden');
    }
});
