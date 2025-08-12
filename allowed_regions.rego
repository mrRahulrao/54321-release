package policy.allowed_regions

default allow = false
allow {
  input.resource.location == "southeastasia"
}
