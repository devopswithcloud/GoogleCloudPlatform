

output "load-balancer-ip" {
  value = module.gce-lb-http.external_ip
}

output "load-balancer-ipv6" {
  value       = module.gce-lb-http.ipv6_enabled ? module.gce-lb-http.external_ipv6_address : "undefined"
  description = "The IPv6 address of the load-balancer, if enabled; else \"undefined\""
}

output "backend_services" {
  value = module.gce-lb-http.backend_services
}
