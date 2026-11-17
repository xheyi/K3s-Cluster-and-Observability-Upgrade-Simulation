data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "k3s_master_role" {
  name               = "k3s-master-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_policy" "k3s_master_policy" {
  name = "k3s-master-ssm-policy"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ssm:PutParameter"
        ]

        Resource = "arn:aws:ssm:eu-north-1:${data.aws_caller_identity.current.account_id}:parameter/k3s/cluster/node-token"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "master_ssm" {
  role       = aws_iam_role.k3s_master_role.name
  policy_arn = aws_iam_policy.k3s_master_policy.arn
}

resource "aws_iam_instance_profile" "k3s_master_profile" {
  name = "k3s-master-profile"
  role = aws_iam_role.k3s_master_role.name
}
