---
  webservers:
    hosts:
%{ for index, dns in names ~}                                         
      ${dns}: 
        ansible_host: ${ip_addrs[index]}
        ansible_ssh_user: root
%{ endfor ~}


