package policy.allowed_skus

allowed = {"Standard_D4s_v5","Standard_E8s_v5","Standard_E16s_v5"}

default allow = false
allow {
  allowed[input.resource.sku]
}
