variable "subscription_id" { type = string }
variable "location" { type = string  default = "southeastasia" }
variable "tags" {
  type = map(string)
  default = {
    system     = "appraps"
  }
}
