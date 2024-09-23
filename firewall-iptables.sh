#!/bin/sh
#Script de inicio
### BEGIN INIT INFO
# Provides: firewall-iptables.sh
# Required-Start: $all
# Required-Stop: $all
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Firewall para red interna.
# Description: Daemon para hacer funcionar la máquina como firewall usando iptables.
### END INIT INFO

#Borrado de reglas de todas las tablas
iptables -F
iptables -X
iptables -Z
iptables -t nat -F

#politicas por defecto
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P POSTROUTING ACCEPT

#filtros
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -s 192.168.1.0/24 -j ACCEPT
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o wan -j MASQUERADE

sysctl -w net.ipv4.ip_forward=1

#permitimos acceso al puerto 22
iptables -A INPUT -s 0.0.0.0/0 -i lan -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -s 0.0.0.0/0 -i wan -p tcp --dport 22 -j ACCEPT

#redireccionamiento de puertos
iptables -t nat -A PREROUTING -i wan -p tcp --dport 2201 -j DNAT --to 192.168.1.1:22
#iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 2202 -j DNAT --to 172.16.38.27:22
#iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 3389 -j DNAT --to 172.16.38.4:3389
#iptables -t nat -A PREROUTING -i enp0s8 -p udp --dport 3389 -j DNAT --to 172.16.38.4:3389
#iptables -t nat -A PREROUTING -i enp0s8 -p udp --dport 67   -j DNAT --to 172.16.38.2:67
#iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 80   -j DNAT --to 172.16.38.26:41062
#iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 53   -j DNAT --to 172.16.38.10:53
#iptables -t nat -A PREROUTING -i enp0s8 -p udp --dport 53   -j DNAT --to 172.16.38.10:53

#necesario para modo pasivo y uso desde la red externa
#iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 21   -j DNAT --to 172.16.38.27:21
#iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 20   -j DNAT --to 172.16.38.27:20
#iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 80   -j DNAT --to 172.16.38.27:80
#iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 10000:15000 -j DNAT --to 172.16.38.27:10000-15000
#IPTABLES_MODULES="nf_conntrack_ftp ip_nat_ftp"

#cerramos el resto de puertos
iptables -A INPUT -s 0.0.0.0/0 -i wan -p tcp --dport 1:1024 -j DROP
iptables -A INPUT -s 0.0.0.0/0 -i wan -p udp --dport 1:1024 -j DROP

#incluimos red interna opuesta en las rutas del sistema
ip route add 192.168.2.0/24 via 172.16.0.2 dev wan


#Permitir ping de fuera hacia adentro
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT

#Permitir ping de dentro hacia fuera
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
