resource "aws_ecs_cluster" "cluster" {
  name = "${var.app_name}"
}

resource "aws_iam_role" "ecs_instance_role" {
  name = "ecs-instance"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ecs_instance_policy" {
  name = "AmazonEC2ContainerServiceforEC2Role"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_instance_attachment" {
  role = "${aws_iam_role.ecs_instance_role.name}"
  policy_arn  = "${aws_iam_policy.ecs_instance_policy.arn}"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name  = "ecs-instance-profile"
  role = "${aws_iam_role.ecs_instance_role.name}"
}

data "template_file" "ecs_agent" {
  template = <<EOF
#!/bin/bash
echo "ECS_CLUSTER=$${cluster_name}" >> /etc/ecs/ecs.config
EOF
  vars {
    cluster_name = "${aws_ecs_cluster.cluster.name}"
  }
}

resource "aws_key_pair" "container_instance_keypair" {
  key_name = "container-instance-keypair"
  public_key = "${var.public_key}"
}

resource "aws_security_group" "container_instance_security_group" {
  name        = "container-instance-security-group"
  description = "Allow traffic from HTTP and SSH"
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "container_instance" {
  ami           = "${var.instance_ami}"
  instance_type = "${var.instance_size}"
  subnet_id     = "${aws_subnet.subnet.id}"
  associate_public_ip_address = true
  iam_instance_profile = "${aws_iam_instance_profile.ecs_instance_profile.id}"
  user_data = "${data.template_file.ecs_agent.rendered}"
  key_name = "${aws_key_pair.container_instance_keypair.key_name}"
  vpc_security_group_ids = [
    "${aws_security_group.container_instance_security_group.id}"
  ]
  depends_on = ["aws_internet_gateway.vpc_gateway"]
}

