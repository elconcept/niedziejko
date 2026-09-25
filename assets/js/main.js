document.addEventListener('DOMContentLoaded', () => {

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

    const revealElements = document.querySelectorAll(
        '.hero-copy, .about-grid, .value, .gallery figure, .contact-card, .practice-item'
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
            threshold: 0.15
        }
    );

    revealElements.forEach(el => {
        el.classList.add('reveal');
        revealObserver.observe(el);
    });

    const practiceDescriptions = {
        'Prawo karne':
            'Obrona i reprezentacja na każdym etapie postępowania karnego, od czynności przygotowawczych po postępowanie sądowe.',
        'Prawo cywilne':
            'Spory majątkowe, zobowiązania, odszkodowania, dochodzenie należności oraz bieżące doradztwo.',
        'Prawo rodzinne':
            'Rozwody, kontakty z dziećmi, alimenty oraz sprawy dotyczące wykonywania władzy rodzicielskiej.',
        'Obsługa przedsiębiorców':
            'Wsparcie prawne działalności gospodarczej, opiniowanie umów oraz reprezentacja w sporach.',
        'Dochodzenie roszczeń':
            'Kompleksowa analiza i dochodzenie roszczeń od podmiotów prywatnych oraz instytucjonalnych.'
    };

    document.querySelectorAll('.practice-item').forEach(item => {

        const title = item.querySelector('span')?.textContent?.trim();

        if (!title || !practiceDescriptions[title]) {
            return;
        }

        const panel = document.createElement('div');

        panel.className = 'practice-panel';

        panel.innerHTML = `
            <div class="practice-panel-inner">
                ${practiceDescriptions[title]}
            </div>
        `;

        item.insertAdjacentElement('afterend', panel);

        item.style.cursor = 'pointer';

        item.addEventListener('click', () => {

            const isOpen = panel.classList.contains('is-open');

            document
                .querySelectorAll('.practice-panel.is-open')
                .forEach(el => {
                    if (el !== panel) {
                        el.classList.remove('is-open');
                    }
                });

            panel.classList.toggle('is-open', !isOpen);
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
                behavior: 'smooth',
                block: 'start'
            });
        });

    });

});
