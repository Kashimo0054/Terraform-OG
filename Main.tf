
provider "aws" {
  region = "us-east-1"  # Replace with your desired AWS region
  access_key = ""       # Replace with your access key 
  secret_key = ""       # Replace with your secret key 
}






resource "aws_organizations_organizational_unit" "Security_OU" {
  name            = "Security_OU"
  parent_id       = "r-8c15"  # Replace with your root organization ID
}



resource "aws_organizations_organizational_unit" "Monitoring_OU" {
  name            = "Monitoring_OU"
  parent_id       = "ou-8c15-julurhx8"  # Replace with your root organization ID
}




resource "aws_organizations_organizational_unit" "Production_Ou" {
  name            = "Production_Ou"
  parent_id       = "r-8c15"  # Replace with your root organization ID
  
}





resource "aws_organizations_organizational_unit" "Dev_Ou" {
  name            = "Dev_Ou"
  parent_id       = "r-8c15"  # Replace with your root organization ID
}







resource "aws_organizations_account" "example_account" {
  name         = "ExampleAccount"
  email        = "example@yahoo.in"
  role_name    = "OrganizationAccountAccessRole"
  parent_id    = "ou-8c15-julurhx8" # Replace with your parent organization ID
}


resource "aws_organizations_policy" "ec2_restrictions_policy" {
  name        = "EC2RestrictionsPolicy"
  description = "Restricts EC2 instance launch in US East 1 region"
  type        = "SERVICE_CONTROL_POLICY"
  content     = <<-EOT
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "DenyEC2LaunchUSEast1",
          "Effect": "Deny",
          "Action": "ec2:RunInstances",
          "Resource": "*",
          "Condition": {
            "StringEquals": {
              "aws:RequestedRegion": "us-east-1"
            }
          }
        }
      ]
    }
  EOT
}

resource "aws_organizations_policy_attachment" "ec2_restrictions_attachment" {
  policy_id   = aws_organizations_policy.ec2_restrictions_policy.id
  target_id   = aws_organizations_organizational_unit.Monitoring_OU.id
}



resource "aws_organizations_policy" "full_aws_access_policy" {
  name        = "FullAWSAccessPolicy"
  description = "Default full AWS access policy"
  type        = "SERVICE_CONTROL_POLICY"
  content     = <<-EOT
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": "*",
          "Resource": "*",
          "Condition": {
            "StringNotEquals": {
              "aws:PrincipalOrgID": "*"
            },
            "StringNotEquals": {
              "aws:PrincipalOrgID": "ou-8c15-31rt7jsa"  # Replace with your organization ID
            }
          },
          "NotAction": [
            "organizations:Describe*",
            "organizations:List*",
            "organizations:ListRoots",
            "organizations:ListChildren",
            "organizations:ListParents",
            "organizations:ListPoliciesForTarget",
            "organizations:ListTargetsForPolicy"
          ],
          "NotResource": "*",
          "Sid": "FullAWSAccess"
        }
      ]
    }
  EOT
}

resource "aws_organizations_policy_attachment" "full_aws_access_attachment" {
  policy_id   = aws_organizations_policy.full_aws_access_policy.id
  target_id   = aws_organizations_organizational_unit.Monitoring_OU.id
  exclude     = true
}

