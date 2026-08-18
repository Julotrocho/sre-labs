# Postmortem — Taux d'erreur élevé sur sre-app

**Date de l'incident** : 17 août 2026
**Statut** : Résolu
**Sévérité** : Simulée (drill), équivalent warning en conditions réelles

## Résumé
configuration d'une alerte via prometheus sur tous les retour en 5.. (retour en erreur) sur des les requetes http, avec un seuil a 0.1, et une durée minimal d'erreur à 2min

## Timeline
- 14:00 — Début de l'injection de trafic vers /crash (déclencheur du drill)
- 14:01 — Alerte HighErrorRate passe à Pending
- 14:02 — Alerte passe à Firing
- 14:04 — Diagnostic via kubectl logs, cause identifiée (endpoint /crash)
- 14:07 — Correctif déployé (rollout restart avec nouvelle image)
- 14:08 — Alerte repasse à Inactive

## Impact
seul mon endpoint, car le seul déployé et en run, le system reste healthy car ce test est une simulation volontaire d'erreur

## Root cause
forcage d'une execption non gérer via le main.py, de manière délibérer dans ce drill avec pour but de tester et d'observer l'erreur

## Détection
Détéction via HighErrorRate dans prometheus, délais du déclenchement entre pending et firing de 2min pour consider le cas de figure réel

## Résolution
1. Modification de main.py : suppression du comportement d'exception volontaire sur /crash
2. `docker build -t sre-app:v2 .`
3. `kind load docker-image sre-app:v2 --name sre-lab`
4. `kubectl rollout restart deployment sre-app`
5. Vérification : `kubectl rollout status deployment sre-app`


## Ce qui a bien fonctionné
chaine complète d'observabilité: modification du code, déploiement de l'alerte, instrumention via prometheus, scraping des erreur, remontée de l'alerte dans le system
la localisation précise via kubectl logs, l'impact limité à un seul endpoint

## Ce qui pourrait être amélioré
délai de 2min peut etre trop long sur un cas réel, delta d'alerte a affiner sur les cas réel pour avoir un threshold raisonnable
pas de notification automatique configurée - Alertmanager présent mais
non connecté à un canal de notification réel dans ce lab,
dashboard pourrait mieux visualiser la proportion erreurs/trafic total

## Actions correctives 
ici les actions correctives ne sont pas relevant car ce cas de figure a été mis en place pour but de test, cependant la mise en place d'une notifiaction vers l'admin ou la personne en charge serait une amelioraiton réel pour cette alerte