import hcl2
import os

INSTANCE_ID = "ssoins-7223e28d1218cf56"
INSTANCE_ARN = f"arn:aws:sso:::instance/{INSTANCE_ID}"
PERMISSION_SET_ARN_PREFIX = f"arn:aws:sso:::permissionSet/{INSTANCE_ID}"

# Read terraform.tfvars file
def load_tfvars(filepath):
    with open(filepath, 'r') as f:
        return hcl2.load(f)

# Generate the bash script
def generate_bash_script(tfvars_data, output_path):
    permission_sets = tfvars_data['permission_sets']
    bash_lines = ["#!/bin/bash\n"]

    for ps in permission_sets:
        name = ps['name']
        ps_id = ps.get("permission_set_id", name)
        bash_lines.append(f"######## Imports for Permission Set: {name} ########")

        # 1. Import Permission Set itself
        bash_lines.append(f"terraform import 'aws_ssoadmin_permission_set.this[\"{name}\"]' '{PERMISSION_SET_ARN_PREFIX}/{ps_id},{INSTANCE_ARN}'")

        # 2. Import Inline Policy (if present)
        if 'inline_policy_file' in ps and ps['inline_policy_file']:
            bash_lines.append(f"terraform import 'aws_ssoadmin_permission_set_inline_policy.this[\"{name}\"]' '{PERMISSION_SET_ARN_PREFIX}/{ps_id},{INSTANCE_ARN}'")

        # 3. Import Managed Policy Attachments
        for policy_arn in ps.get('managed_policies', []):
            policy_name = os.path.basename(policy_arn)
            key = f"{name}-{policy_name}"
            bash_lines.append(f"terraform import 'aws_ssoadmin_managed_policy_attachment.this[\"{key}\"]' '{policy_arn},{PERMISSION_SET_ARN_PREFIX}/{ps_id},{INSTANCE_ARN}'")

        # 4. Import Assignments
        for assign in ps.get('assignments', []):
            principal_id = assign['principal_id']
            principal_type = assign['principal_type']
            account_id = assign['account_id']
            assignment_key = f"{name}-{account_id}-{principal_id}"
            bash_lines.append(f"terraform import 'aws_ssoadmin_account_assignment.this[\"{assignment_key}\"]' '{principal_id},{principal_type},{account_id},AWS_ACCOUNT,{PERMISSION_SET_ARN_PREFIX}/{ps_id},{INSTANCE_ARN}'")
        
        bash_lines.append("")

                          
    # Write the file
    with open(output_path, 'w') as f:
        f.write('\n'.join(bash_lines))

    os.chmod(output_path, 0o755)
    print(f"Bash script generated: {output_path}")

if __name__ == "__main__":
    tfvars_path = "terraform.tfvars"
    output_bash = "import_commands.sh"

    tfvars_data = load_tfvars(tfvars_path)
    generate_bash_script(tfvars_data, output_bash)
