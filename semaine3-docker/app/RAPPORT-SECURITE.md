# Rapport de sécurité — sre-app

## Résumé du scan Trivy (image sre-app:v2, base debian 13.6)

Total : 174 vulnérabilités
- CRITICAL : 4
- HIGH : 19
- MEDIUM : 56
- LOW : 66
- UNKNOWN : 29

Répartition par origine :
- **Dépendances Python de l'application** (fastapi, pydantic, starlette, uvicorn, etc.) : 0 vulnérabilité détectée
- **`pip` (outil, pas dépendance applicative)** : 5 vulnérabilités
- **Paquets système Debian sous-jacents** (apt, bash, bsdutils, perl-base, etc.) : la quasi-totalité des 174, hérités de l'image de base `python:3.12-slim`

## Zoom : les 4 CRITICAL (perl-base)

## Vulnérabilités CRITICAL identifiées
4 CVE CRITICAL, toutes sur perl-base (5.40.1-6), aucune Fixed Version disponible à date.

## Tentative de correction
Perl n'étant pas utilisé par l'application (Python/FastAPI), tentative de suppression du paquet
via `apt-get remove perl-base`.

## Résultat
Échec : perl-base est marqué "essential" par Debian, sa suppression forcée
(--allow-remove-essential) risquerait de casser des mécanismes internes du système
pour un bénéfice incertain (CVE sans correctif disponible).

## Décision
Risque accepté et documenté plutôt que suppression forcée. À réévaluer quand un correctif
Debian sera disponible (surveiller le paquet perl-base sur le tracker de sécurité Debian).

## Le reste des 170 vulnérabilités (HIGH/MEDIUM/LOW/UNKNOWN)

Non traitées individuellement dans le cadre de ce projet, pour les raisons suivantes :
- La très large majorité provient de l'OS Debian de base (`python:3.12-slim`), pas du code
  applicatif — corriger CVE par CVE sur des paquets système non utilisés directement par
  l'app n'est pas une approche efficace (voir "Zoom perl-base" pour un exemple concret de
  pourquoi une correction ciblée peut être impossible ou risquée).
- Une partie (UNKNOWN : 29) reflète la fraîcheur de l'image de base (Debian 13/trixie,
  version récente) — statut de correction encore incertain côté mainteneurs Debian, pas un
  signe de négligence du projet.
- Approche recommandée en conditions réelles plutôt qu'un traitement CVE par CVE :
  - Surveiller les nouvelles versions de l'image de base (`python:3.12-slim`) et rebuild
    régulièrement — la majorité des CVE système se résolvent naturellement par la mise à jour
    de l'image de base, sans action ciblée par CVE
  - Intégrer `trivy image` dans un pipeline CI, avec un seuil de blocage
    (ex : bloquer le déploiement uniquement sur nouveau CRITICAL, pas sur l'ensemble)
  - Réévaluer périodiquement (ex : mensuel) plutôt qu'une correction ponctuelle unique

## Comparaison de taille d'image (bonus sécurité indirect)
- sre-app:v1 (python:3.12, Dockerfile naïf) : 414 MB
- sre-app:v2 (python:3.12-slim, multi-stage, non-root) : 48.3 MB
Une image plus petite = surface d'attaque réduite (moins de paquets = moins de CVE potentielles),
en plus du bénéfice opérationnel (pull/déploiement plus rapides).