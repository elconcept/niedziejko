#!/usr/bin/env bash
set -euo pipefail

cat >> assets/css/styles.css <<'CSS'

/* ==========================================================
   HEADER
   ========================================================== */

.site-header{
    position:fixed;
    top:0;
    left:0;
    width:100%;
    z-index:1000;

    transition:
        background .25s ease,
        backdrop-filter .25s ease,
        box-shadow .25s ease;
}

.site-header.is-scrolled{
    background:rgba(252,250,247,.92);
    backdrop-filter:blur(14px);
    box-shadow:0 12px 30px rgba(0,0,0,.05);
}

.site-header-inner{
    height:76px;

    display:flex;
    align-items:center;
    justify-content:space-between;
}

.site-logo{
    font-family:"Baskervville",serif;
    font-size:1.35rem;
    letter-spacing:.04em;
}

.site-nav{
    display:flex;
    gap:36px;
}

.site-nav a{
    color:var(--muted);
    transition:var(--transition);
}

.site-nav a:hover{
    color:var(--text);
}

/* ==========================================================
   REVEAL ANIMATIONS
   ========================================================== */

.reveal{
    opacity:0;
    transform:translateY(28px);
    transition:
        opacity .7s ease,
        transform .7s ease;
}

.reveal.revealed{
    opacity:1;
    transform:none;
}

/* ==========================================================
   PRACTICE PANELS
   ========================================================== */

.practice-panel{
    max-height:0;
    overflow:hidden;

    transition:
        max-height .35s ease,
        opacity .25s ease;

    opacity:0;

    border-bottom:1px solid var(--line);
}

.practice-panel.is-open{
    max-height:240px;
    opacity:1;
}

.practice-panel-inner{
    padding:0 0 24px 0;

    max-width:820px;

    color:var(--muted);

    font-size:1rem;
    line-height:1.8;
}

/* ==========================================================
   IMAGE POLISH
   ========================================================== */

.hero-image img,
.about-image img,
.gallery img{
    transition:
        transform .8s ease;
}

.hero-image:hover img,
.about-image:hover img,
.gallery figure:hover img{
    transform:scale(1.03);
}

/* ==========================================================
   CONTACT CARD
   ========================================================== */

.contact-card{
    position:relative;
}

.contact-card::before{
    content:"";

    position:absolute;

    top:0;
    left:0;

    width:4px;
    height:100%;

    background:var(--accent);
}

/* ==========================================================
   FOOTER
   ========================================================== */

footer{
    background:var(--surface);
}

footer .container{
    letter-spacing:.12em;
    text-transform:uppercase;
    font-size:.75rem;
}

/* ==========================================================
   MOBILE
   ========================================================== */

@media (max-width:980px){

    .site-header-inner{
        height:64px;
    }

    .site-nav{
        display:none;
    }

    .site-logo{
        font-size:1.1rem;
    }
}
CSS

echo
echo "Rozszerzono assets/css/styles.css"
echo
echo "Nastepny krok:"
echo "06_upgrade_index_structure.sh"
echo
