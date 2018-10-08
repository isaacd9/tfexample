resource "aws_route53_zone" "app_zone" {
  name = "${var.app_domain}"
}


resource "aws_route53_record" "base" {
  zone_id = "${aws_route53_zone.app_zone.zone_id}"
  name    = "${var.app_domain}"
  type    = "A"
  ttl     = "300"
  records = [
    "${aws_instance.container_instance.public_ip}"
  ]
}

resource "aws_route53_record" "www" {
  zone_id = "${aws_route53_zone.app_zone.zone_id}"
  name    = "www.${var.app_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = [
    "${var.app_domain}"
  ]
}
