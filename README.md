# sre-labs — Montée en compétence SRE (réseau, Docker, Kubernetes, observabilité, Terraform)

Projet personnel réalisé en 4 semaines pour acquérir les fondamentaux pratiques attendus sur un poste DevOps/SRE, en complément d'un profil ingénieur cloud/cybersécurité (CEH Master).

**Objectif** : ne pas se contenter de la théorie — chaque notion est accompagnée d'un lab reproductible, de pannes provoquées volontairement, et de notes documentant les erreurs rencontrées et leur résolution. L'angle cyber (durcissement, RBAC, scan de vulnérabilités) est volontairement mis en avant à chaque fois qu'il est pertinent.

## Stack technique

Environnement local : Windows + WSL2 (Ubuntu) + Docker Desktop, 16 Go de RAM (WSL2 plafonné à 8 Go).

| Outil | Rôle |
|---|---|
| Docker / Docker Compose | Conteneurisation, orchestration locale simple |
| kind | Cluster Kubernetes local (nœuds = conteneurs Docker) |
| kubectl | Pilotage du cluster Kubernetes |
| Helm | Packaging et déploiement d'applications Kubernetes |
| Terraform | Infrastructure as Code (providers Docker et Kubernetes) |
| Trivy | Scan de vulnérabilités d'images |
| Prometheus / Grafana | Métriques, dashboards, alerting |
| Nginx | Reverse proxy, load balancing, Ingress controller |

## Structure du dépôt

| Dossier | Contenu |
|---|---|
| `semaine1-reseau/` | Namespaces réseau Linux, veth pair, bridge — mécanismes bas niveau utilisés par Docker |
| `semaine2-lb/` | Reverse proxy Nginx, load balancing round robin, panne simulée, healthcheck |
| `semaine3-docker/` | Dockerfile multi-stage, scan de sécurité Trivy, conteneur non-root, docker-compose avec limites de ressources, test OOM |
| `semaine3-docker-terraform/` | Infra as Code du lab Docker (provider `kreuzwerker/docker`) |
| `semaine3-k8s/` | Cluster kind, Deployment/ReplicaSet/Pod, Service, probes, Ingress, RBAC |
| `semaine3-k8s-terraform/` | Infra as Code du lab Kubernetes (provider `hashicorp/kubernetes`), démonstration de drift |
| `semaine4-observabilite/` | Stack Prometheus/Grafana via Helm, instrumentation applicative, alerte, incident simulé, postmortem, packaging Helm final (`sre-app-chart/`) |

*Note : les dossiers gardent leur numérotation d'origine (8 semaines), mais le projet a été mené sur un format compressé à 4 semaines — voir correspondance ci-dessous.*

## Progression (format 4 semaines)

### Semaine 1 — Réseau Linux + Load Balancing
- Recréation manuelle du mécanisme réseau utilisé par Docker (namespace, veth pair, bridge) avant de l'utiliser à travers l'outil
- Reverse proxy Nginx devant deux backends, observation du failover automatique et de la distinction *conteneur mort* vs *conteneur `unhealthy`*
- Script de lab idempotent (`setup-netns-lab.sh`), diagnostic réseau (`ss`, `dig`, `tcpdump`, `traceroute`, `mtr`)

### Semaine 2 — Docker en profondeur + Terraform (provider Docker)
- Dockerfile multi-stage : réduction de la taille d'image de **414 MB à 53 MB** (~87%)
- Scan Trivy, analyse des vulnérabilités CRITICAL, décision de gestion de risque documentée (paquet non patchable, non supprimable sans casser le système → risque accepté et justifié)
- Utilisateur non-root fonctionnel (résolution d'un conflit classique entre `pip install --user` et permissions `/root`)
- `docker-compose.yml` avec limites CPU/mémoire, provocation d'un OOM kill volontaire (code de sortie `137`), démonstration que le noyau ne tue que sur dépassement réel, jamais sur simple approche de la limite
- Introduction de Terraform : réécriture du lab en HCL (provider Docker), cycle `init/plan/apply/destroy`

### Semaine 3 — Kubernetes + Terraform (provider Kubernetes)
- Cluster local `kind` (3 nœuds), hiérarchie Deployment → ReplicaSet → Pod
- Observation en direct du mécanisme d'auto-réparation (suppression manuelle d'un pod → recréation automatique par le ReplicaSet)
- Distinction `readinessProbe` / `livenessProbe`, et comparaison avec le découplage healthcheck/routage observé sous Docker Compose en semaine 2
- Ingress (reverse proxy piloté par Kubernetes) et RBAC (namespace dédié, ServiceAccount, Role/RoleBinding en lecture seule, tests de permissions via `kubectl auth can-i`)
- Terraform (provider Kubernetes) : démonstration concrète du **drift** — une modification manuelle (`kubectl scale`) est détectée et annulée par `terraform plan`/`apply`, illustrant pourquoi une ressource gérée par Terraform ne doit jamais être modifiée manuellement

### Semaine 4 — Observabilité, incident, Helm
- Stack Prometheus + Grafana déployée via Helm (`kube-prometheus-stack`)
- Instrumentation de l'application (endpoint `/metrics`, `ServiceMonitor`), dashboard Grafana avec requêtes PromQL
- Alerte Prometheus (`PrometheusRule`) sur le taux d'erreurs 5xx
- **Incident simulé de bout en bout** : injection d'erreurs volontaires → alerte observée en direct (`Inactive` → `Pending` → `Firing`) → diagnostic via logs → correction → retour à la normale → **postmortem blameless rédigé**
- Packaging final avec un chart Helm complet (`sre-app-chart/`)

## Quelques défis techniques rencontrés (et résolus)

Le dépôt documente volontairement les erreurs traversées, pas seulement le résultat final — chaque dossier contient un `NOTES.md` détaillant ce qui a coincé et pourquoi. Points marquants :

- **Debug d'un pod en `CrashLoopBackOff`** : `imagePullPolicy` mal configuré + port applicatif désaligné entre `Dockerfile` et manifest Kubernetes — résolu en isolant les causes une par une via `kubectl describe`/`logs` plutôt qu'en devinant
- **`ServiceMonitor` invisible côté Prometheus** : confusion entre `spec.selector` (cible les pods) et `metadata.labels` (identifie le Service lui-même) — un piège Kubernetes classique
- **Packaging Helm** : plutôt que de deviner les clés de `values.yaml` une par une, extraction exhaustive de toutes les références `.Values.*` utilisées dans les templates (`grep -rho`) pour construire une configuration complète en une seule passe

## Lancer le projet

Prérequis : WSL2 + Ubuntu, Docker Desktop (intégration WSL2 activée), `kubectl`, `kind`, `helm`, `terraform`, `trivy` installés (voir `semaine1-reseau/` pour le détail du setup).

```bash
# Cluster Kubernetes local
kind create cluster --name sre-lab --config semaine3-k8s/kind-config.yaml

# Déploiement applicatif (via le chart Helm final)
cd semaine4-observabilite
helm install sre-app ./sre-app-chart

# Stack d'observabilité
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

## Suite naturelle

Certification **CKA** (Certified Kubernetes Administrator) et/ou **HashiCorp Terraform Associate**.