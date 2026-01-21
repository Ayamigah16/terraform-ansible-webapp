[role_frontend]
${frontend_ip} ansible_user=${ssh_user} ansible_ssh_private_key_file=${private_key_path} ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'

[role_backend]
${backend_ip} ansible_user=${ssh_user} ansible_ssh_private_key_file=${private_key_path} ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyJump=${ssh_user}@${frontend_ip}'

[all:vars]
ansible_python_interpreter=/usr/bin/python3
project_name=${project_name}
