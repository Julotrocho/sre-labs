# Notes Semaine 3 — Kubernetes, bases

## Cluster kind
configuration dans kindconfig.yaml dun cluster, un controle plane et deux worker, création de conteners géré par k8, meme fonctonnement que docker car visible via docker ps

## Deployment -> ReplicaSet -> Pods
configuration du Deployement.yaml, ==> mode déclaratif, config des containers et des conditions de déploiement, gestion auto du déploiement si contener mort ou autre

## readinessProbe vs livenessProbe
readinessProbe échoue ==> le pod est retiré du Service (plus de trafic envoyé), mais reste vivant, aucun redémarrage — utile par exemple si ton app est temporairement surchargée et doit "souffler" sans perdre son état interne
livenessProbe échoue ==> Kubernetes tue et redémarre le conteneur, en partant du principe qu'il est dans un état irrécupérable

## Mécanisme d'auto-réparation observé
suppresion manuel d'un pod pendant le run pour observer le mécanisme de renouvellement: suppression manuelle déclenchée en premier, qui fait immédiatement réagir le ReplicaSet pour créer un nouveau pod en remplacement — les deux processus se chevauchent dans le temps (d'où le pic à 4 pods), mais c'est bien la suppression qui cause la création, pas l'inverse.

## Points de friction
Fautes de frappes dans les scripts