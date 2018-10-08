# Service 1
data "template_file" "app_task" {
  template = "${file("ecs-tasks/application.json")}"
  vars {
    domain = "${var.app_domain}"
    image = "${var.app_image}"
    name = "${var.app_name}"
    port = "${var.app_port}"
  }
}

resource "aws_ecs_task_definition" "app_task" {
  family = "app"
  container_definitions = "${data.template_file.app_task.rendered}"
}

resource "aws_ecs_service" "app_service" {
  name = "${var.app_name}"
  cluster = "${aws_ecs_cluster.cluster.id}"
  task_definition = "${aws_ecs_task_definition.app_task.id}"
  desired_count = "${var.desired_count}"
}
