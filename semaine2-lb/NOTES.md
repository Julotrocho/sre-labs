# Notes Semaine 2 — Load Balancing

## Architecture mise en place
(2-3 phrases : proxy Nginx + 2 backends, round robin, DNS interne Docker Compose)
Mise en place de 3 containeurs ==> 2 conteneur web nginx avec backend + 1 resverse proxy qui gère le flux et la balance
loadbalancing en round robin, un try successifs sur chaque containeur
observation du dns interne de docker compose

## Comportement observé : panne de web1 (avant healthcheck)
- Ce qui se passe côté client (curl) : retour du serveur 2, qui est sain, uniquement, aucune erreur affichée
- Ce qui se passe côté logs proxy : visibilité des essais jusqua non respect des quotas, message d'erreur visible dans les logs proxy contrairement au curl
- Ce que ça m'apprend sur le mécanisme de failover de Nginx : experience user final fluide, et gestion des erreurs dans les logs du proxy

## Ajout du healthcheck
- Ce que ça change concrètement : ajout de limite sur les temps de time out et de nombre de retry ainis que de délais de réponse
- Différence avec le comportement "sans healthcheck" observé plus haut : visibilité de Healthy/unhealthy dans docker compose en fonction des conditions du health check, permet des décisions d'orchestration, ne modifie pas automatiquement le comprotemet du loabalancer nginx.
Nginx continue de router vers un backend unhealthy tant qu'il répond au connexion tcp ==> check necssaires sur le health balanceur 

## Points de friction rencontrés
erreur de typo sur le retries
temps de shutdown du containeur trop court pour observer un unhealthy
