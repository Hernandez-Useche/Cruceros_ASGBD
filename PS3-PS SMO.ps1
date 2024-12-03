#Importando librería SQLSERVER
Import-Module SQLSERVER -NoClobber
#Comprobando importación
Get-Module SQLSERVER

#Instancia en variable
$NombreInstancia = "localhost"
$Server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $NombreInstancia

#Comprobar inexistencia de db que se creará
$Server.Databases | Select Name

#Varible nombre db 
$Dbnueva = "SHU"
$db = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Database($Server, $Dbnueva)
#Creando db
$db.Create()

#Comprobando creación
$Server.Databases | Select Name

#Variable para dbatools (para que no dé problema de certificados)
$Conexion = "Server=localhost;Trusted_Connection=True;TrustServerCertificate=True;"
#Comprobando db creada con dbatools
Get-DbaDatabase -SqlInstance $Conexion -Database SHU

#Eliminando db
$dbBorrar = $Server.Databases[$Dbnueva]
if ($dbBorrar)
{ 
    $Server.KillDatabase($Dbnueva) 
}

#Comprobando que no existe
Get-DbaDatabase -SqlInstance $Conexion -Database SHU