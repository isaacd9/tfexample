data "template_file" "traefik_task" {
  template = "${file("ecs-tasks/traefik.json")}"
  vars {
    domain = "${var.app_domain}"
  }
}


resource "aws_ecs_task_definition" "traefik" {
  family = "traefik"
  container_definitions = "${data.template_file.traefik_task.rendered}"
  task_role_arn = "${aws_iam_role.traefik_role.arn}"
}

resource "aws_ecs_service" "traefik" {
  name = "traefik"
  cluster = "${aws_ecs_cluster.cluster.id}"
  task_definition = "${aws_ecs_task_definition.traefik.id}"
  desired_count = 1
}

resource "aws_iam_role" "traefik_role" {
  name = "traefik"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "traefik_policy" {
  name = "traefik"
  description = "Traefik Policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "TraefikECSReadAccess",
            "Effect": "Allow",
            "Action": [
                "ecs:ListClusters",
                "ecs:DescribeClusters",
                "ecs:ListTasks",
                "ecs:DescribeTasks",
                "ecs:DescribeContainerInstances",
                "ecs:DescribeTaskDefinition",
                "ec2:DescribeInstances",
                "route53:ChangeResourceRecordSets",
                "route53:CreateHostedZone",
                "route53:GetChange",
                "route53:GetHostedZone",
                "route53:GetHostedZoneCount",
                "route53:ListHostedZones",
                "route53:ListHostedZonesByName",
                "route53:ListResourceRecordSets",
                "route53:UpdateHostedZoneComment"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "traefikAttachment" {
  role = "${aws_iam_role.traefik_role.name}"
  policy_arn  = "${aws_iam_policy.traefik_policy.arn}"
}
