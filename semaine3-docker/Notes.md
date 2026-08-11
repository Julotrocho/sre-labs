# Notes Semaine 2 (partie 2) — Docker Compose, limites de ressources, OOM

## Setup
Mise en place d'un docker-compose.yml complet avec deux services : app (build depuis le
Dockerfile local, dépend de db) et db (postgres:16). Le service db a un healthcheck
(pg_isready) et app utilise depends_on avec condition: service_healthy pour ne démarrer
qu'une fois la base réellement prête, pas juste "lancée". Un volume nommé (dbdata) assure
la persistance des données Postgres indépendamment du cycle de vie du conteneur.

## Test de limite mémoire — observations progressives
- À 50M : conso stabilisée à ~35MiB, pas d'OOM
- À 20M : conso à 97% de la limite (19.43/20MiB), toujours stable, pas de kill
- Ce que ça m'apprend : Docker/le noyau ne tue que sur DÉPASSEMENT réel, pas sur approche
  de la limite. Un conteneur peut tourner durablement très proche de sa limite sans alerte
  automatique — implique qu'un monitoring basé uniquement sur le statut running/healthy
  est insuffisant, il faut surveiller la métrique mémoire elle-même (ex : via Prometheus,
  semaine 4).

## Déclenchement de l'OOM (10M)
- Ce qui a été observé : boucle "Recreate" en continu dans docker compose up
- Ce que ça signifie : le conteneur est tué (OOM) puis automatiquement recréé par Compose,
  qui re-tue, en boucle — sans intervention, ce cycle continue indéfiniment et peut
  saturer inutilement les ressources de la machine hôte (CPU passé à recréer en boucle).

## Le code de sortie 137
- 137 = 128 + 9 (signal SIGKILL) — signature caractéristique d'un OOM kill sous Linux/Docker
- Point important : un OOM kill est silencieux côté application (le process est tué
  instantanément par le noyau via cgroups, pas de message d'erreur applicatif possible,
  contrairement à un crash applicatif classique qui laisse souvent une stack trace).

## Point de friction / nuance rencontrée
Après un Ctrl+C manuel, docker inspect a affiché des infos incohérentes entre elles
(OOMKilled=false mais ExitCode=137, logs montrant un arrêt propre) — probablement un
mélange entre l'état du dernier cycle (arrêt propre déclenché par mon Ctrl+C, donc
SIGTERM géré proprement par uvicorn) et un ExitCode résiduel d'un cycle OOM précédent
dans la boucle Recreate. Pour une preuve non ambiguë et non rétroactive : `docker events
--filter event=oom` dans un terminal séparé, qui capture l'événement OOM en direct au
moment où il se produit, plutôt que de se fier à l'état final après plusieurs cycles.

## Corrections apportées au docker-compose.yml
- ressources → resources (clé YAML en anglais, pas de traduction)
- environnement → environment (idem)
- postgresdl:// → postgresql:// (typo dans le protocole de l'URL de connexion)
- healthcheck test: format CMD attend un tableau d'arguments séparés ("pg_isready", "-U",
  "user") plutôt qu'une seule chaîne avec espaces — corrigé en utilisant CMD-SHELL qui
  accepte une chaîne complète et la découpe via un shell interne

## Ce que je retiens pour l'entretien
Savoir distinguer un OOM kill (ExitCode 137, silence applicatif, cgroups) d'un crash
applicatif classique est un vrai signal de compétence en diagnostic de prod — beaucoup de
gens confondent les deux ou ne savent pas expliquer pourquoi les logs sont vides après un
OOM.