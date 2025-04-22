#!/bin/bash

# Limpar todas as regras existentes
iptables -F
iptables -X
iptables -t nat -F
iptables -t mangle -F

# Definir as políticas padrão
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Permitir conexões essenciais
iptables -A INPUT -p tcp --dport 22 -j ACCEPT  # Permite SSH
iptables -A INPUT -p tcp --dport 80 -j ACCEPT  # Permite HTTP
iptables -A INPUT -p tcp --dport 443 -j ACCEPT  # Permite HTTPS

# Permitir conexões de loopback (localhost)
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Limitar conexões SSH (3 tentativas por minuto)
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 3 -j REJECT

# Permitir tráfego DNS (porta 53)
iptables -A INPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p udp --sport 53 -j ACCEPT

# Log de tentativas de conexão negadas
iptables -A INPUT -j LOG --log-prefix "iptables denied: " --log-level 4

# Salvar as regras (se necessário para sua distribuição)
# Para Debian/Ubuntu
iptables-save > /etc/iptables/rules.v4
# Para sistemas com netfilter-persistent
# netfilter-persistent save

# Exibir as regras aplicadas
iptables -L -v -n
