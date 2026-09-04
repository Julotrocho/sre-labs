# Notes Semaine 2 (partie 3) — Terraform, provider Docker

## Principe général
Terraform fonctionne en mode déclaratif : on décrit l'état désiré de l'infrastructure
(quelles ressources doivent exister, avec quelle config) dans des fichiers .tf, plutôt que
d'écrire une séquence d'actions comme dans un script bash. Le cycle de travail est
toujours le même : `terraform init` (télécharge les providers nécessaires),
`terraform plan` (calcule et affiche le diff entre l'état désiré et l'état réel, sans rien
exécuter), `terraform apply` (applique uniquement les changements nécessaires). Terraform
garde la trace de ce qu'il gère dans un fichier state (terraform.tfstate).

## Différence avec docker run / docker-compose
docker run/docker-compose sont impératifs : chaque exécution relance les actions écrites,
sans mémoire de ce qui existe déjà (au mieux, Docker refuse si un nom est déjà pris).
Terraform, lui, compare l'état désiré à l'état réel via son state, et n'agit que sur les
écarts. Observé concrètement : après un premier apply partiellement échoué (conflit de
port), le second apply n'a recréé que la ressource manquante (1 added) plutôt que de tout
retenter depuis zéro (3 added) — la preuve que Terraform sait "ce qu'il a déjà fait".

## Syntaxe de référence entre ressources
Pattern : <type>.<nom_local>.<attribut> — par exemple docker_image.app.image_id.
- <type> : le type de ressource défini par le provider (ex : docker_image, docker_network,
  docker_container)
- <nom_local> : un identifiant choisi arbitrairement dans le code Terraform (ex : "app"),
  purement interne, sans lien avec un nom Docker réel
- <attribut> : une valeur calculée automatiquement par Terraform après création de la
  ressource (ex : image_id, name)
On n'écrit jamais un ID en dur copié depuis `docker images` : ça casserait la reproductibilité
(l'ID change à chaque rebuild) et irait à l'encontre du principe déclaratif — Terraform doit
pouvoir résoudre ces références dynamiquement à chaque exécution.

## Observations pendant apply/destroy
- Premier apply : erreur "port already allocated" — le port 8000 était déjà occupé par le
  conteneur du docker-compose.yml de la partie précédente, toujours actif. Résolu en
  arrêtant ce conteneur (docker compose stop) avant de relancer l'apply.
- Deuxième apply : "1 added" au lieu de "3 added" — confirme que Terraform avait bien gardé
  en state la création réussie de l'image et du réseau lors du premier apply, malgré
  l'échec du conteneur.
- destroy : avec keep_locally = true sur la ressource docker_image, l'image sre-app:v2
  survit à la destruction alors que le conteneur et le réseau créés par Terraform
  disparaissent bien. Sans ce paramètre, destroy aurait aussi supprimé l'image localement.

## Point de vigilance Git
.terraform/ (cache local du provider téléchargé) et *.tfstate (état courant de
l'infrastructure) ne doivent jamais être poussés sur Git : le premier est régénérable à
volonté via terraform init, le second contient l'état réel de l'infra et doit, en
environnement d'équipe, être stocké sur un backend distant (S3, Terraform Cloud...) plutôt
que local, pour éviter toute désynchronisation entre plusieurs contributeurs.

## Points de friction rencontrés
- Confusion initiale sur la référence à l'image (tentative d'écrire l'ID Docker en dur
  plutôt que d'utiliser docker_image.app.image_id) — corrigée avant le premier apply.
- Conflit de port 8000 avec le conteneur docker-compose encore actif de la partie
  précédente — résolu en arrêtant ce conteneur avant de relancer terraform apply.

## Ce que je retiens pour l'entretien
Savoir expliquer la différence fondamentale déclaratif (Terraform, kubectl apply) vs
impératif (docker run, scripts bash) est une question classique. Le exemple concret du
"1 added" après un apply partiellement échoué est une bonne illustration pratique à citer.
