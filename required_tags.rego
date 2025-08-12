package policy.required_tags

default allow = false
allow {
  input.resource.tags.env
  input.resource.tags.owner
  input.resource.tags.costcenter
  input.resource.tags.system == "appraps"
}
