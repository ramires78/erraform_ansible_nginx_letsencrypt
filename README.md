## Beschreibung

### Ansible. TLS (NGINX+Let's Encrypt)

#### Roles description

Rollen ermöglichen es Ihnen, aus kleineren Teilen für verschiedene Situationen und Lösungen ein Playbook für verschiedene Aufgaben zusammenzustellen. Und Sie müssen nicht von Anfang an Skripte schreiben.

#### Verwenden von Rollen auf Play Niveauen

```
- hosts: 
  - webservers
  become: true
  become_method: sudo
    
  roles:
    - { role: nginx, tags: role1 }
    - { role: vhosts, tags: role2 }
    - { role: TLS, tags: role3 }

```

    $ ansible-playbook -i ./ansible/inventories/webservers/hosts.yml ./ansible/nginx.yml --list-task

  play #1 (webservers): webservers  TAGS: []
    tasks:
      nginx : install Nginx und Letsencrypt TAGS: [web_install, webservers]
      nginx : copy the nginx config file    TAGS: [nginx_conf, web_install]
      vhosts : add folder for item and sertifications virtual hosts TAGS: [add_opt_folders, make_hosts]
      vhosts : Remove default nginx config  TAGS: [del_default, make_hosts]
      vhosts : copy the nginx vhotsts config file and the content of the web site   TAGS: [erste_templates, make_hosts]
      vhosts : Check NGINX configs  TAGS: [check_nginx, make_hosts]
      vhosts : Flush handlers   TAGS: [make_hosts]
      TLS : take cert from letsencrypt  TAGS: [letsencrypt_cert, make_cert]
      TLS : Add letsencrypt cronjob for cert renewal    TAGS: [cron_cert, make_cert]
      TLS : copy the new 443 nginx vhotsts config file  TAGS: [make_cert, new_host]
      


#### Zieldateien für Rolle

`./roles/{name of specific role}/{vars,tasks,handlers}/`

## Methoden der Erstellung

1. Bereitstellen einer virtuellen Maschine mit Hilfe von Terraform auf DO und A-Record auf Route 53 von AWS:

```shell
    $ terraform apply -var-file=terrafor.tfvars
    oder 
    $ terraform apply -var-file=variables.tf
```
2. Bereitstellen virtueller Hosts in der Cloud mit Hilfe von Ansible:

```shell
    $ ansible-playbook -i ./ansible/inventories/webservers/hosts.yml ./ansible/nginx.yml
```

## die Ergebnisse

1. Nach der Anwendung können Sie die Ergebnisse sehen

```shell
    $ cat outputs_result.csv
```
**P.S. Beachtung! Ändern Sie die Werte der Variablen in Ihre eigenen!**

## License

GNU
