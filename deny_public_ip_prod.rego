package policy.deny_public_ip_prod

default allow = true
allow {
  not (input.env == "prod" and input.resource.public_ip == true and input.resource.tags.approved != "true")
}
