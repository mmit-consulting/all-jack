# Windows notes:

To run the windows playbook:

ansible-playbook -i inventory.ini playbook_windows_ssm.yml
ansible-playbook -i inventory.ini playbook_windows_ssm.yml --ask-pass


winrm quickconfig
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'

to chagne the password net user Administrator Test1234
