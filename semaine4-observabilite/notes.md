# Notes Semaine 4 — Observabilité

## Incident simulé
implémentation d'une boucle pour simluer des erreurs 500, configuration d'une alerte prometeheus et un dahsboard grafana pour observer la chaine complète, succès, observation des différents states pending, firing, et back to normal après modif, cf postmortem

## Packaging Helm
grep récursif pour lister les .Values attendus plutôt que deviner car certaines erreurs ont eu lieu sans ce grep recursif a l'installation, ca ma permis de completer mon values.yaml.
mise en place de clé avec des valeurs pour mon cas de test, et remplissage de certaines valeurs en null pour ne pas bloquer a l'installation

## Points de friction
double dossier sre-app-chart/sre-app-chart, clés Values manquantes en cascade
