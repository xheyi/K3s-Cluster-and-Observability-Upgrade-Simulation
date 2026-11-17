data "aws_caller_identity" "current" {}

resource "aws_iam_role" "k3s_worker_role" {
  name               = "k3s-worker-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_policy" "k3s_worker_policy" {
  name = "k3s-worker-ssm-policy"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ssm:GetParameter"
        ]

        Resource = "arn:aws:ssm:eu-north-1:${data.aws_caller_identity.current.account_id}:parameter/k3s/cluster/node-token"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "worker_ssm" {
  role       = aws_iam_role.k3s_worker_role.name
  policy_arn = aws_iam_policy.k3s_worker_policy.arn
}


resource "aws_iam_instance_profile" "k3s_worker_profile" {
  name = "k3s-worker-profile"
  role = aws_iam_role.k3s_worker_role.name
}