resource "aws_iam_instance_profile" "cdc_profile" {
  name = "cdc_profile"
  role = aws_iam_role.cdc_role.name
}

resource "aws_iam_role" "cdc_role" {
  name = "cdc_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}