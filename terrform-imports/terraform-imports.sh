# 1. Import the Permission Set itself
terraform import 'aws_ssoadmin_permission_set.this["Bespin_DSG"]' \
'arn:aws:sso:::instance/ssoins-7223e28d1218cf56/arn:aws:sso:::permissionSet/ssoins-7223e28d1218cf56/ps-fe78bb93162b526d'

# 2. Import the Inline Policy (if you have an inline JSON policy)
terraform import 'aws_ssoadmin_permission_set_inline_policy.this["Bespin_DSG"]' \
'arn:aws:sso:::permissionSet/ssoins-7223e28d1218cf56/ps-fe78bb93162b526d,arn:aws:sso:::instance/ssoins-7223e28d1218cf56'

# 3. Import all Managed Policy Attachments (you already listed correctly)

terraform import 'aws_ssoadmin_managed_policy_attachment.this["Bespin_DSG-AmazonEC2FullAccess"]' \
'arn:aws:iam::aws:policy/AmazonEC2FullAccess,arn:aws:sso:::permissionSet/ssoins-7223e28d1218cf56/ps-fe78bb93162b526d,arn:aws:sso:::instance/ssoins-7223e28d1218cf56'

terraform import 'aws_ssoadmin_managed_policy_attachment.this["Bespin_DSG-AmazonECS_FullAccess"]' \
'arn:aws:iam::aws:policy/AmazonECS_FullAccess,arn:aws:sso:::permissionSet/ssoins-7223e28d1218cf56/ps-fe78bb93162b526d,arn:aws:sso:::instance/ssoins-7223e28d1218cf56'

# etc ...

# 4. Import the Assignment (Account + Group/User)

# shared servies dev (already imported)
terraform import 'aws_ssoadmin_account_assignment.this["Bespin_DSG-729960212337-84d89438-90b1-70c3-d3aa-4832fb1a1f64"]' \
'84d89438-90b1-70c3-d3aa-4832fb1a1f64,GROUP,729960212337,AWS_ACCOUNT,arn:aws:sso:::permissionSet/ssoins-7223e28d1218cf56/ps-fe78bb93162b526d,arn:aws:sso:::instance/ssoins-7223e28d1218cf56'

# hoopla pord
terraform import 'aws_ssoadmin_account_assignment.this["Bespin_DSG-058253789961-94381428-a061-7000-1b8f-2567e807c3a3"]' \
'94381428-a061-7000-1b8f-2567e807c3a3,GROUP,058253789961,AWS_ACCOUNT,arn:aws:sso:::permissionSet/ssoins-7223e28d1218cf56/ps-fe78bb93162b526d,arn:aws:sso:::instance/ssoins-7223e28d1218cf56'


# sharedsrvprod
terraform import 'aws_ssoadmin_account_assignment.this["Bespin_DSG-875993331183-d4286428-40f1-7010-6f7d-15ace5a3a1fc"]' \
'd4286428-40f1-7010-6f7d-15ace5a3a1fc,GROUP,875993331183,AWS_ACCOUNT,arn:aws:sso:::permissionSet/ssoins-7223e28d1218cf56/ps-fe78bb93162b526d,arn:aws:sso:::instance/ssoins-7223e28d1218cf56'


# sharedsvctest
terraform import 'aws_ssoadmin_account_assignment.this["Bespin_DSG-279530709713-d4384408-2071-7008-0fad-64bd07c3edc3"]' \
'd4384408-2071-7008-0fad-64bd07c3edc3,GROUP,279530709713,AWS_ACCOUNT,arn:aws:sso:::permissionSet/ssoins-7223e28d1218cf56/ps-fe78bb93162b526d,arn:aws:sso:::instance/ssoins-7223e28d1218cf56'

