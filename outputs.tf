output "vm_name" {
 
  description = "Name of the Linux virtual machine."
  value       = azurerm_linux_virtual_machine.artizent.name
 
}
 
output "resource_group_name" {
 
  description = "Name of the resource group."
  value       = azurerm_resource_group.artizent.name
 
}