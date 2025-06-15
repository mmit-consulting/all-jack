# Windows notes:

To run the windows playbook:

ansible-playbook -i inventory.ini playbook_windows_ssm.yml -e "ansible_password='Test1'"


winrm quickconfig
winrm enumerate winrm/config/listener

Set-NetFirewallRule -Name "WINRM-HTTP-In-TCP" -Profile Any
Get-NetFirewallRule -Name "WINRM-HTTP-In-TCP" | Format-List Name, Enabled, Profile

to chagne the passwordnet user Administrator Test1