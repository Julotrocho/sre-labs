# Notes Semaine 2 (partie 2) — Docker Compose, limites de ressources, OOM

## Setup
(2-3 phrases : docker-compose complet app+db, healthcheck sur db, depends_on condition
service_healthy, volume nommé pour la persistance Postgres)

## Test de limite mémoire — observations progressives
- À 50M : conso stabilisée à ~35MiB, pas d'OOM
- À 20M : conso à 97% de la limite (19.43/20MiB), toujours stable, pas de kill
- Ce que ça m'apprend : Docker/le noyau ne tue que sur DÉPASSEMENT réel, pas sur approche
  de la limite. Un conteneur peut tourner durablement très proche de sa limite sans alerte.

## Déclenchement de l'OOM (10M)
- Ce qui a été observé : boucle "Recreate" en continu dans docker compose up
- Ce que ça signifie : le conteneur est tué (OOM) puis automatiquement recréé par Compose,
  qui re-tue, en boucle

## Le code de sortie 137
- 137 = 128 + 9 (signal SIGKILL) — signature caractéristique d'un OOM kill sous Linux/Docker
- Point important : un OOM kill est silencieux côté application (le process est tué
  instantanément par le noyau, pas de message d'erreur applicatif possible)

## Point de friction / nuance rencontrée
Après un Ctrl+C manuel, docker inspect a affiché des infos incohérentes entre elles
(OOMKilled=false mais ExitCode=137, logs montrant un arrêt propre) — probablement un
mélange entre l'état du dernier cycle (arrêt propre déclenché par mon Ctrl+C) et un
ExitCode résiduel d'un cycle OOM précédent. Pour une preuve non ambiguë : `docker events
--filter event=oom` dans un terminal séparé, qui capture l'événement en direct.

## Corrections apportées au docker-compose.yml
(les 4 typos : ressources->resources, environnement->environment, postgresdl->postgresql,
format CMD du healthcheck)