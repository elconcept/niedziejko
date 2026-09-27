document.addEventListener('DOMContentLoaded', () => {

    const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    const body = document.body;

    const header = document.querySelector('.site-header');

    if (header) {
        window.addEventListener('scroll', () => {
            if (window.scrollY > 30) {
                header.classList.add('is-scrolled');
            } else {
                header.classList.remove('is-scrolled');
            }
        });
    }

    if (!prefersReducedMotion) {
        initParallax();
        initDepth();
    }

    const revealElements = document.querySelectorAll(
        '.hero-copy, .about-copy, .contact-grid > div, .contact-card, .practice-grid > .reveal, .values-grid > .reveal'
    );

    const revealObserver = new IntersectionObserver(
        entries => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('revealed');
                    revealObserver.unobserve(entry.target);
                }
            });
        },
        {
            threshold: 0.15,
            rootMargin: '0px 0px -50px 0px'
        }
    );

    revealElements.forEach(el => {
        el.classList.add('reveal');
        revealObserver.observe(el);
    });

    const staggerElements = document.querySelectorAll('.reveal-stagger');
    const staggerObserver = new IntersectionObserver(
        entries => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('revealed');
                    staggerObserver.unobserve(entry.target);
                }
            });
        },
        {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        }
    );

    staggerElements.forEach(el => {
        staggerObserver.observe(el);
    });

    document.querySelectorAll('.practice-item').forEach(wrap => {

        const btn = wrap.querySelector('button');
        const panel = wrap.querySelector('.practice-panel');

        if (!btn || !panel) {
            return;
        }

        btn.addEventListener('click', () => {

            const isOpen = panel.classList.contains('is-open');

            document
                .querySelectorAll('.practice-panel.is-open')
                .forEach(el => {
                    if (el !== panel) {
                        el.classList.remove('is-open');
                        const otherBtn = el.previousElementSibling;
                        if (otherBtn && otherBtn.tagName === 'BUTTON') {
                            otherBtn.setAttribute('aria-expanded', 'false');
                        }
                    }
                });

            panel.classList.toggle('is-open', !isOpen);
            btn.setAttribute('aria-expanded', String(!isOpen));
        });
    });

    document.querySelectorAll('a[href^="#"]').forEach(anchor => {

        anchor.addEventListener('click', e => {

            const href = anchor.getAttribute('href');

            const target = document.querySelector(href);

            if (!target) {
                return;
            }

            e.preventDefault();

            target.scrollIntoView({
                behavior: prefersReducedMotion ? 'auto' : 'smooth',
                block: 'start'
            });
        });

    });

});

function initParallax() {
    const parallaxElements = document.querySelectorAll('.parallax');

    if (parallaxElements.length === 0) return;

    let ticking = false;
    const speed = parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--parallax-speed')) || 0.12;

    function updateParallax() {
        const scrollY = window.scrollY;

        parallaxElements.forEach(el => {
            const rect = el.getBoundingClientRect();
            const elementTop = rect.top + scrollY;
            const elementHeight = rect.height;
            const viewportHeight = window.innerHeight;

            if (elementTop + elementHeight > 0 && elementTop < scrollY + viewportHeight) {
                const distanceFromCenter = (scrollY + viewportHeight / 2) - (elementTop + elementHeight / 2);
                const translateY = distanceFromCenter * speed;
                el.style.transform = `translateY(${translateY}px)`;
            }
        });

        ticking = false;
    }

    function requestTick() {
        if (!ticking) {
            requestAnimationFrame(updateParallax);
            ticking = true;
        }
    }

    window.addEventListener('scroll', requestTick, { passive: true });
    window.addEventListener('resize', requestTick, { passive: true });
}

function initDepth() {
    const depthElements = document.querySelectorAll('.depth-1, .depth-2, .depth-3');

    if (depthElements.length === 0) return;

    let ticking = false;

    const speeds = {
        'depth-1': parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--depth-speed-1')) || 0.05,
        'depth-2': parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--depth-speed-2')) || 0.08,
        'depth-3': parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--depth-speed-3')) || 0.12
    };

    function updateDepth() {
        const scrollY = window.scrollY;
        const viewportHeight = window.innerHeight;

        depthElements.forEach(el => {
            const rect = el.getBoundingClientRect();
            const elementTop = rect.top + scrollY;
            const elementHeight = rect.height;

            if (elementTop + elementHeight > 0 && elementTop < scrollY + viewportHeight) {
                const progress = (scrollY + viewportHeight - elementTop) / (viewportHeight + elementHeight);
                const clampedProgress = Math.max(0, Math.min(1, progress));

                let speed = 0;
                if (el.classList.contains('depth-1')) speed = speeds['depth-1'];
                else if (el.classList.contains('depth-2')) speed = speeds['depth-2'];
                else if (el.classList.contains('depth-3')) speed = speeds['depth-3'];

                const translateY = (clampedProgress - 0.5) * elementHeight * speed * 2;
                el.style.transform = `translateY(${translateY}px)`;
            }
        });

        ticking = false;
    }

    function requestTick() {
        if (!ticking) {
            requestAnimationFrame(updateDepth);
            ticking = true;
        }
    }

    window.addEventListener('scroll', requestTick, { passive: true });
    window.addEventListener('resize', requestTick, { passive: true });
}
