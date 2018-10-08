output "nameservers" {
  value = [
    "${aws_route53_zone.app_zone.name_servers.0}",
    "${aws_route53_zone.app_zone.name_servers.1}",
    "${aws_route53_zone.app_zone.name_servers.2}",
    "${aws_route53_zone.app_zone.name_servers.3}",
  ]
}
