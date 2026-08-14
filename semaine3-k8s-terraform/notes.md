# Notes Semaine 3 — Kubernetes (suite) : Ingress, RBAC, Terraform

## Ingress
ingress exposer proprement l'app ves l'extérieur, equivalent du reverse proxy nginx pour k8
usage du controlleur pour rediriger le traffic depuis l'exterieur vers le contener concerné
point de friction lors du l'usage sur les usages des port multiple entre wsl2 windows et docker

## RBAC
Role based access controle, création d'un namespace dédié pour les profils, définition d'un role et usage scindé, fichier role et role binding==> permet usage d'un même role dans différents role binding
création d'un user read only et test des permission accessibel via can -i et vers l'exterieur du namespace du role

## Terraform provider Kubernetes
Ici terraform pilote k8s et tous les service qui lui corresponde, terraform et k8 sont tous les deux des outils déclaratif, mais contrairement a K8, terraform maintient un state propre, alors que k8 apply n'en a pas

## Drift Terraform — démonstration
test de scale manuel, passage de 3 à 5 replicas, ensuite action via terraform, terraform detecte les changements, et va donc écraser les nouvelles instances pour revenir à la config prévue. Si actions de scaling, les faire via terraform car celui-ci ne sais pas si le scaling et voulu ou non ou sain, c'est du comparatif pur avec son fichier config

