#Viendo versión de PS
#$PSVersionTable

$version=$PSVersionTable
$version

#Get-ExecutionPolicy y Set-ExecutionPolicy
#Viendo política de ejecución
Get-ExecutionPolicy

#Estableciendo política de ejecución en Unrestricted
Set-ExecutionPolicy Unrestricted
Get-ExecutionPolicy

#Comandos SistemaOperativo
ping localhost
ipconfig

#New-Item
#Trabajar con directorios
New-Item "C:\carpetaPrueba" -ItemType Directory

#Get-Help
#Buscando comandos que contengan la cadena escrita
Get-Help *firewall*

#Viendo contenido de la ayuda en una ventana a parte
Get-Help New-LocalGroup -showWindow

#Viendo ejemplos de uso de un comando
Get-Help New-LocalUser -Examples

#Get-Alias y New-Alias
#Viendo Alias en el sistema
Get-Alias
#Viendo si existen alias relacionados con mkdir
Get-Alias -Definition "mkdir"
#Creando Alias para comando mkdir
New-Alias -Name carpeta -Value mkdir
Get-Alias carpeta
#Usando nuevo alias
carpeta carpetaPrueba2

#Get-Process y uso de tuberías |
#Viendo procesos del sistema
Get-Process
#Uso de tuberías para encadenar comando
Get-Process | Out-File C:\carpetaPrueba\Procesos.txt
notepad .\carpetaPrueba\Procesos.txt
#Mostrar en ventana externa
Get-Process | Out-GridView