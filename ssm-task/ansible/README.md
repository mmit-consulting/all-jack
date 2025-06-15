# Windows notes:

To run the windows playbook:

```bash
ansible-playbook -i inventory.ini playbook_windows_ssm.yml
```

```bash
ansible-playbook -i inventory.ini playbook_windows_ssm.yml --ask-pass
```

```bash
winrm quickconfig
```

```bash
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
```

```bash
winrm set winrm/config/service/auth '@{Basic="true"}'
```


to chagne the password net user Administrator Test1234
