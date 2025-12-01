resource "aws_iam_role" "eb_instance_role" {
  name = "aws-elasticbeanstalk-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "eb_instance_profile" {
  name = "eb-ec2-instance-profile"
  role = aws_iam_role.eb_instance_role.name
}


resource "aws_iam_role_policy_attachment" "eb_instance_role_attachment" {
  role       = aws_iam_role.eb_instance_role.name
  policy_arn = data.aws_iam_policy.eb_web_tier.arn
}

resource "aws_iam_role_policy_attachment" "eb_worker_role_attachment" {
  role       = aws_iam_role.eb_instance_role.name
  policy_arn = data.aws_iam_policy.eb_worker_tier.arn
}

resource "aws_iam_role_policy_attachment" "eb_multi_container_docker_attachment" {
  role       = aws_iam_role.eb_instance_role.name
  policy_arn = data.aws_iam_policy.eb_multi_container_docker.arn
}

resource "aws_iam_role" "eb_service_role" {
  name = "aws-elasticbeanstalk-service-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "elasticbeanstalk.amazonaws.com"
        }
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "eb_enhanced_health_attachment" {
  role       = aws_iam_role.eb_service_role.name
  policy_arn = data.aws_iam_policy.eb_enhanced_health.arn

}

resource "aws_iam_role_policy_attachment" "eb_managed_updates_attachment" {
  role       = aws_iam_role.eb_service_role.name
  policy_arn = data.aws_iam_policy.eb_managed_updates.arn
}