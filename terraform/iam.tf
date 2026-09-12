# ============================================================
# GitHub Actions OIDC Provider
# ============================================================

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  tags = {
    Name = "github-actions-oidc"
  }
}

# ============================================================
# GitHub Actions IAM Role
# ============================================================

resource "aws_iam_role" "github_actions" {
  name = "rivermark-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }

          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:Himanshu-cyber-alt/RiverMark:*"
          }
        }
      }
    ]
  })

  tags = {
    Name = "rivermark-github-actions-role"
  }
}

# ============================================================
# GitHub Actions Permissions
# ============================================================

resource "aws_iam_role_policy" "github_actions" {
  name = "rivermark-github-actions-policy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [

      # --------------------------------------------------------
      # ECR authentication
      # --------------------------------------------------------

      {
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken"
        ]

        Resource = "*"
      },

      # --------------------------------------------------------
      # Push Docker image to ECR
      # --------------------------------------------------------

      {
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]

        Resource = aws_ecr_repository.backend.arn
      },

      # --------------------------------------------------------
      # Deploy through Systems Manager
      # --------------------------------------------------------

      {
        Effect = "Allow"

        Action = [
          "ssm:SendCommand",
          "ssm:GetCommandInvocation"
        ]

        Resource = "*"
      },

      # --------------------------------------------------------
      # EC2 information
      # --------------------------------------------------------

      {
        Effect = "Allow"

        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeAddresses"
        ]

        Resource = "*"
      },

      # --------------------------------------------------------
      # Elastic IP switching
      # --------------------------------------------------------

      {
        Effect = "Allow"

        Action = [
          "ec2:AssociateAddress",
          "ec2:DisassociateAddress"
        ]

        Resource = "*"
      },

      # --------------------------------------------------------
      # RDS information
      # --------------------------------------------------------

      {
        Effect = "Allow"

        Action = [
          "rds:DescribeDBInstances"
        ]

        Resource = "*"
      }
    ]
  })
}

# ============================================================
# EC2 IAM Role
# ============================================================

resource "aws_iam_role" "ec2" {
  name = "rivermark-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "rivermark-ec2-role"
  }
}

# ============================================================
# EC2 → ECR
# ============================================================

resource "aws_iam_role_policy" "ec2_ecr" {
  name = "rivermark-ec2-ecr-policy"
  role = aws_iam_role.ec2.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [

      {
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]

        Resource = aws_ecr_repository.backend.arn
      }
    ]
  })
}

# ============================================================
# EC2 → SSM Parameter Store
# ============================================================

resource "aws_iam_role_policy" "ec2_ssm" {
  name = "rivermark-ec2-ssm-policy"
  role = aws_iam_role.ec2.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ssm:GetParameter"
        ]

        Resource = aws_ssm_parameter.db_password.arn
      }
    ]
  })
}

# ============================================================
# EC2 Instance Profile
# ============================================================

resource "aws_iam_instance_profile" "ec2" {
  name = "rivermark-ec2-profile"
  role = aws_iam_role.ec2.name

  tags = {
    Name = "rivermark-ec2-profile"
  }
}

# ============================================================
# Systems Manager
# ============================================================

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}