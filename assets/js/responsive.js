document.addEventListener('DOMContentLoaded', () => {
    const menuBtn = document.querySelector('.mobile-menu-btn');
    const mobileNav = document.querySelector('.mobile-nav');
    const mobileNavCloseBtn = document.querySelector('.mobile-nav-close');
    const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    const formatValue = (value, suffix) => `${Math.round(value).toLocaleString('en-AU')}${suffix}`;

    const animateCounter = (counter) => {
        if (counter.dataset.counted === 'true') {
            return;
        }

        const target = Number(counter.dataset.countTo || 0);
        const duration = Number(counter.dataset.duration || 1600);
        const suffix = counter.dataset.suffix || '';

        counter.dataset.counted = 'true';

        if (prefersReducedMotion) {
            counter.textContent = formatValue(target, suffix);
            return;
        }

        const startTime = performance.now();
        counter.classList.add('is-counting');

        const tick = (currentTime) => {
            const elapsed = currentTime - startTime;
            const progress = Math.min(elapsed / duration, 1);
            const easedProgress = 1 - Math.pow(1 - progress, 3);
            const currentValue = target * easedProgress;

            counter.textContent = formatValue(currentValue, suffix);

            if (progress < 1) {
                window.requestAnimationFrame(tick);
            } else {
                counter.textContent = formatValue(target, suffix);
                counter.classList.remove('is-counting');
            }
        };

        window.requestAnimationFrame(tick);
    };

    const initHomeHighlightCounters = () => {
        const highlightsSection = document.querySelector('.home-highlights');
        if (!highlightsSection) {
            return;
        }

        const counters = highlightsSection.querySelectorAll('.home-highlight-value[data-count-to]');

        const revealHighlights = () => {
            highlightsSection.classList.add('is-visible');
            counters.forEach(animateCounter);
        };

        if (!counters.length || prefersReducedMotion || !('IntersectionObserver' in window)) {
            revealHighlights();
            return;
        }

        const observer = new IntersectionObserver((entries) => {
            entries.forEach((entry) => {
                if (entry.isIntersecting) {
                    revealHighlights();
                    observer.disconnect();
                }
            });
        }, {
            threshold: 0.35,
            rootMargin: '0px 0px -8% 0px'
        });

        observer.observe(highlightsSection);
    };

    const initAboutStatsCounters = () => {
        const aboutSection = document.querySelector('.about');
        if (!aboutSection) {
            return;
        }

        const counters = aboutSection.querySelectorAll('.stats .stat-box h3[data-count-to]');
        if (!counters.length) {
            return;
        }

        const revealStats = () => {
            aboutSection.classList.add('is-visible');
            counters.forEach(animateCounter);
        };

        if (prefersReducedMotion || !('IntersectionObserver' in window)) {
            revealStats();
            return;
        }

        const observer = new IntersectionObserver((entries) => {
            entries.forEach((entry) => {
                if (entry.isIntersecting) {
                    revealStats();
                    observer.disconnect();
                }
            });
        }, {
            threshold: 0.35,
            rootMargin: '0px 0px -8% 0px'
        });

        observer.observe(aboutSection);
    };

    const initHomeResponseReveal = () => {
        const responseSection = document.querySelector('.home-response-model');
        if (!responseSection) {
            return;
        }

        const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
        const isMobileViewport = window.matchMedia('(max-width: 768px)').matches;
        if (prefersReducedMotion || isMobileViewport || !('IntersectionObserver' in window)) {
            responseSection.classList.add('is-visible');
            return;
        }

        const observer = new IntersectionObserver((entries) => {
            entries.forEach((entry) => {
                if (entry.isIntersecting) {
                    responseSection.classList.add('is-visible');
                    observer.disconnect();
                }
            });
        }, {
            threshold: 0.24,
            rootMargin: '0px 0px -6% 0px'
        });

        observer.observe(responseSection);
    };

    if (menuBtn && mobileNav && !window.__mobileNavInitialized) {
        window.__mobileNavInitialized = true;
        if (!mobileNav.id) {
            mobileNav.id = 'mobile-nav';
        }
        menuBtn.setAttribute('aria-controls', mobileNav.id);
        menuBtn.setAttribute('aria-expanded', 'false');
        mobileNav.setAttribute('aria-hidden', 'true');

        const setMenuState = (open) => {
            mobileNav.classList.toggle('is-open', open);
            mobileNav.classList.toggle('active', open);
            document.body.classList.toggle('nav-open', open);
            menuBtn.setAttribute('aria-expanded', open ? 'true' : 'false');
            mobileNav.setAttribute('aria-hidden', open ? 'false' : 'true');
        };

        const closeMenu = () => {
            setMenuState(false);
        };

        const openMenu = () => {
            setMenuState(true);
        };

        menuBtn.addEventListener('click', () => {
            const isOpen = mobileNav.classList.contains('is-open') || mobileNav.classList.contains('active');
            if (isOpen) {
                closeMenu();
            } else {
                openMenu();
            }
        });

        if (mobileNavCloseBtn) {
            mobileNavCloseBtn.addEventListener('click', closeMenu);
        }

        mobileNav.addEventListener('click', (event) => {
            const link = event.target.closest('a');
            if (link) {
                closeMenu();
            }
        });

        document.addEventListener('keydown', (event) => {
            if (event.key === 'Escape' && (mobileNav.classList.contains('is-open') || mobileNav.classList.contains('active'))) {
                closeMenu();
            }
        });

        window.addEventListener('resize', () => {
            if (window.innerWidth > 767) {
                closeMenu();
            }
        });
    }

    // Lazy-load below-the-fold images and keep hero/loading-critical images eager.
    const images = document.querySelectorAll('img');
    images.forEach((img) => {
        const inHero = img.closest('.hero, .about-hero, .service-hero, .contact-hero, .blog-hero');
        const isLikelyLcp = inHero || img.closest('header') || img.classList.contains('logo-light') || img.classList.contains('logo-dark');

        if (!img.hasAttribute('loading') && !isLikelyLcp) {
            img.setAttribute('loading', 'lazy');
        }
        if (!img.hasAttribute('decoding')) {
            img.setAttribute('decoding', 'async');
        }
        if (!img.hasAttribute('fetchpriority') && isLikelyLcp) {
            img.setAttribute('fetchpriority', 'high');
        }
    });

    initHomeHighlightCounters();
    initAboutStatsCounters();
    initHomeResponseReveal();
});
