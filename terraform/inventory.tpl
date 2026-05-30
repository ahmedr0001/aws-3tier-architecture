[frontend]
frontend_server ansible_host=${frontend_ip}

[backend]
backend_server ansible_host=${backend_ip}

[database]
db_server ansible_host=${db_ip}

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/3tier-key


#this allow ansible ssh backend and db over frontend server as it's in private subnet

# Forces the jump through frontend, explicitly using the SSH key and ignoring fingerprints
[backend:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q ubuntu@${frontend_ip} -i ~/.ssh/3tier-key -o StrictHostKeyChecking=no" -o StrictHostKeyChecking=no'

[database:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q ubuntu@${frontend_ip} -i ~/.ssh/3tier-key -o StrictHostKeyChecking=no" -o StrictHostKeyChecking=no'