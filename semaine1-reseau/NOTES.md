# Notes Semaine 1 — Réseau Linux

## Namespaces, veth pair, bridge
Namespaces: réseau virtuel interne propre au noyau linux, assignation d'une adresse ip et table de routage locale et propre, utilisé par docker pour isoler les containeurs 
Veth pair: lien réseau entre deux namespace avec des adresse ip dédiée, equivalent du cable ethernet
Bridge: équivalent du réseau local pour que les containeur communique entre eux

## Commande 1 : ss -tulpn
- Ce que ça fait : écoute des ports et des protocols ainsi que des processus utilisant ces protocoles et ces ports
- Exemple de sortie obtenue : 
Netid    State     Recv-Q    Send-Q        Local Address:Port        Peer Address:Port    Process
udp      UNCONN    0         0                127.0.0.54:53               0.0.0.0:*
udp      UNCONN    0         0             127.0.0.53%lo:53               0.0.0.0:*
udp      UNCONN    0         0            10.255.255.254:53               0.0.0.0:*
udp      UNCONN    0         0                 127.0.0.1:323              0.0.0.0:*
udp      UNCONN    0         0                 127.0.0.1:323              0.0.0.0:*
udp      UNCONN    0         0                     [::1]:323                 [::]:*
udp      UNCONN    0         0                     [::1]:323                 [::]:*
tcp      LISTEN    0         1000         10.255.255.254:53               0.0.0.0:*
tcp      LISTEN    0         511               127.0.0.1:33717            0.0.0.0:*        users:(("MainThread",pid=11450,fd=23))
tcp      LISTEN    0         4096          127.0.0.53%lo:53               0.0.0.0:*
tcp      LISTEN    0         4096             127.0.0.54:53               0.0.0.0:*
- Ce que ça m'apprend : je peux surveiller les protocoles, les ports et les process utilisés par mon/mes containeurs, me permettant aussi d'auditer et de diagnostiquer

## Commande 2 : dig
- Ce que ça fait :résoudre un nom de domaine en adresse ip
- Exemple de sortie obtenue :
; <<>> DiG 9.20.18-1ubuntu2.1-Ubuntu <<>> google.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 2823
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;google.com.                    IN      A

;; ANSWER SECTION:
google.com.             156     IN      A       172.217.16.238

;; Query time: 8 msec
;; SERVER: 10.255.255.254#53(10.255.255.254) (UDP)
;; WHEN: Thu Aug 06 10:14:19 CEST 2026
;; MSG SIZE  rcvd: 55
- Ce que ça m'apprend : je peux décrouvrir grace à cette commande l'adresse du serveur dns qui communique avec mon containeur

## Commande 3 : tcpdump
- Ce que ça fait : écoute les paquets transmis entre mon containeur et l'exterieur de celui-ci, filtrage possible sur le type de paquet, ainsi que le device depuis lequel l'écoute se fait
- Exemple de sortie obtenue : 
tcpdump: WARNING: any: That device doesn't support promiscuous mode
(Promiscuous mode not supported on the "any" device)
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on any, link-type LINUX_SLL2 (Linux cooked v2), snapshot length 262144 bytes
10:18:28.605345 eth0  Out IP 172.24.69.247 > lhr48s28-in-f14.1e100.net: ICMP echo request, id 34759, seq 1, length 64
10:18:28.609655 eth0  In  IP lhr48s28-in-f14.1e100.net > 172.24.69.247: ICMP echo reply, id 34759, seq 1, length 64
10:18:29.607238 eth0  Out IP 172.24.69.247 > lhr48s28-in-f14.1e100.net: ICMP echo request, id 34759, seq 2, length 64
10:18:29.615136 eth0  In  IP lhr48s28-in-f14.1e100.net > 172.24.69.247: ICMP echo reply, id 34759, seq 2, length 64
10:18:30.609113 eth0  Out IP 172.24.69.247 > lhr48s28-in-f14.1e100.net: ICMP echo request, id 34759, seq 3, length 64
10:18:30.615140 eth0  In  IP lhr48s28-in-f14.1e100.net > 172.24.69.247: ICMP echo reply, id 34759, seq 3, length 64
10:18:31.611137 eth0  Out IP 172.24.69.247 > lhr48s28-in-f14.1e100.net: ICMP echo request, id 34759, seq 4, length 64
10:18:31.617080 eth0  In  IP lhr48s28-in-f14.1e100.net > 172.24.69.247: ICMP echo reply, id 34759, seq 4, length 64
^C
8 packets captured
8 packets received by filter
0 packets dropped by kernel
- Ce que ça m'apprend : je peux observer en détail les échanges de paquet pour diagnostiquer les pertes de paquet ou les non réponses des protocoles

## Points de friction rencontrés
je ne sais pas écrire icmp, je met toujours imcp
git push ne fonctionne pas avec login mdp ==> génération de token nécéssaire
Docker0 (bridge docker par défaut) non visible dans les process car pas host sur mon wsl2, mais sur une instance dédiée non visible, docker network inspect bridge pour trouver son ip et subnet
Les interfaces sont down par défaut, il faut les activer
set -e au début d'un script stop le script a la première erreur

