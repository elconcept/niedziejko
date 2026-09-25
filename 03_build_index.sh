#!/usr/bin/env bash
set -euo pipefail

cat > index.html <<'HTML'
<!doctype html>
<html lang="pl">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">

<title>Adwokat Kamil Niedziejko | Kraków</title>

<meta name="description" content="Kancelaria Adwokacka Kamil Niedziejko. Prawo karne, cywilne, rodzinne i reprezentacja przed sądami.">

assets/css/styles.css
</head>

<body>

<header class="hero">
    <div class="container">
        <div class="hero-grid">

            <div class="hero-copy">
                <span class="eyebrow">
                    Adwokat Kamil Niedziejko
                </span>

                <h1>
                    Rzetelna pomoc prawna oparta na analizie i doświadczeniu.
                </h1>

                <p>
                    Kancelaria świadczy pomoc prawną klientom indywidualnym
                    oraz przedsiębiorcom. Każda sprawa analizowana jest
                    indywidualnie z uwzględnieniem ryzyk, szans i realnych
                    możliwości działania.
                </p>

                #kontakt
                    Umów konsultację
                </a>
            </div>

            <figure class="hero-image">
                <img
                    src="assets/images/web/2.jpg"
                    alt="Identyfikacja wizualna kancelarii">
            </figure>

        </div>
    </div>
</header>

<section id="praktyka">
    <div class="
        <h2>
            Obszary praktyki
        </h2>

        <div class="practice-list">

            <div class="practice-item">
                <span>Prawo karne</span>
                <span>+</span>
            </div>

            <div class="practice-item">
                <span>Prawo cywilne</span>
                <span>+</span>
            </div>

            <div class="practice-item">
                <span>Prawo rodzinne</span>
                <span>+</span>
            </div>

            <div class="practice-item">
                <span>Obsługa przedsiębiorców</span>
                <span>+</span>
            </div>

            <div class="practice-item">
                <span>Dochodzenie roszczeń</span>
                <span>+</span>
            </div>

        </div>

    </div>
</section>

<section id="o-kancelarii">
    <div class="container">

        <div class="about-grid">

            <div>

                <span class="eyebrow">
                    O kancelarii
                </span>

                <h2>
                    Profesjonalna reprezentacja oraz indywidualne podejście.
                </h2>

                <p>
                    Każda sprawa wymaga dokładnej analizy oraz oceny
                    dostępnych środków prawnych. Kancelaria zapewnia
                    bezpośredni kontakt z adwokatem prowadzącym sprawę,
                    przejrzystą komunikację i odpowiedzialne prowadzenie
                    postępowań.
                </p>

            </div>

            <figure class="about-image">
                <img
                    src="assets/images/web/4.jpg"
                    alt="Profesjonalna reprezentacja">
            </figure>

        </div>

 an class="eyebrow">
            Standard pracy
        </span>

        <h2>
            Wartości kancelarii
        </h2>

        <div class="values">

            <div class="value">
                <strong>Rzetelność</strong>
                Analiza oparta na faktach i obowiązujących przepisach.
            </div>

            <div class="value">
                <strong>Dyskrecja</strong>
                Poufność informacji przekazywanych przez klientów.
            </div>

            <div class="value">
                <strong>Zaangażowanie</strong>
                Bezpośredni kontakt z adwokatem prowadzącym sprawę.
            </div>

        </div>

    </div>
</section>

<section id="identyfikacja">
    <div class="container">

        <span class="eyebrow">
            Identyfikacja wizualna
        </span>

        <h2>
            Charakter marki
        </h2>

        <div class="gallery">

            <figure>
                assets/images/thumbs/1.jpg
            </figure>

            <figure>
                assets/images/thumbs/3.jpg
            </figure>

            <figure>
                assets/images/thumbs/5.jpg
            </figure>

            <figure>
                assets/images/thumbs/6.jpg
            </figure>

            <figure>
                assets/images/thumbs/7.jpg
            </figure>

            <figure>
                assets/images/thumbs/8.jpg
            </figure>

        </div>

    </div>
</section>

<section id="kontakt">
    <div class="container">

        <div class="contact-grid">

            <div>

                <span class="eyebrow">
                    Kontakt
                </span>

                <h2>
                    Porozmawiajmy o Twojej sprawie.
                </h2>

                <p>
                    Pierwszy kontakt pozwala określić charakter sprawy
                    oraz możliwe kierunki dalszego działania.
                </p>

            </div>

            <div class="contact-card">

                <p>
                    <strong>ADWOKAT KAMIL NIEDZIEJKO</strong>
                </p>

                <br>

                <p>
                    ul. Dobrego Pasterza 189
                </p>

                <p>
                    31-416 Kraków
                </p>

                <br>

                <p>
                    kontakt@kamilniedziejko.pl
                </p>

                <p>
                    +48 512 458 132
                </p>

            </div>

        </div>

    </div>
</section>

<footer>
    <div class="container">
        ADWOKAT KAMIL NIEDZIEJKO • KRAKÓW
    </div>
</footer>

</body>
</html>
HTML

echo "Wygenerowano index.html"
