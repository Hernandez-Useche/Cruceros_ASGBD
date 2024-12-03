#Install-Module
#Instalando cmdlets de SQLServer
Install-Module -Name SqlServer -AllowClobber

#Get-Module
#Verificando instalación
Get-Module SqlServer -ListAvailable

#Get-Command
#Viendo los cmdlets de SqlServer
Get-Command -Module SqlServer

#Manejo de servicios
#Get-Service
#Buscando servicios que tengan relación con SQL
Get-Service | ?{$_.name -like '*sql*'} | ogv

#Start-Service
#Arrancando servicios
Start-Service "SQLSERVERAGENT"
Get-Service -Name SQLSERVERAGENT

#Stop-Service
#Detener el servicio
Stop-Service "SQLSERVERAGENT"
Get-Service -Name SQLSERVERAGENT

#Sentencias SQL con Invoke-sqlcmd -Query
Invoke-Sqlcmd -Database "Cruceros_ASGBD" -Query "SELECT * FROM Factura" -ServerInstance "." -Username "sa" -Password "Feik12345" -TrustServerCertificate | ogv

#Backup-SqlDatabase
#Copia de seguridad sencilla
Backup-SqlDatabase -ServerInstance "." -Database "Cruceros_ASGBD" -BackupFile "C:\carpetaPrueba\Backup.bak"

#Copia más profesional
$fecha = Get-Date -Format yyyyMMddHHmmss
$instancia = "."
$nombreDb = 'Cruceros_ASGBD2'
Backup-SqlDatabase -ServerInstance $instancia -Database $nombreDb -BackupFile "C:\carpetaPrueba\$($nombreDb)_db_$($fecha).bak"

#Restore-SqlDatabase
#Eliminando db
Invoke-Sqlcmd -ServerInstance "." -TrustServerCertificate -Query "Drop database CRUCEROS_ASGBD2;"
#Restaurando db
Restore-SqlDatabase -ServerInstance $instancia -Database $nombreDb -BackupFile "C:\carpetaPrueba\Cruceros_ASGBD2_db_20241203002420.bak" -ReplaceDatabase

#Instalación dbatools
#Install-Module
Install-Module -Name dbatools
$Conexion = "Server=localhost;Trusted_Connection=True;TrustServerCertificate=True;"

#Creación DB con SQL dinámico
$sql="
   CREATE DATABASE [db_ps]
   CONTAINMENT = NONE
   ON PRIMARY
   ( NAME = N'db_ps', FILENAME = N'C:\carpetaPrueba\db_ps.mdf' , SIZE = 1048576KB , FILEGROWTH=262144KB )
    LOG ON
   ( NAME = N'db_ps_log', FILENAME = N'C:\carpetaPrueba\db_ps_log.ldf' , SIZE = 524288KB , FILEGROWTH = 131072KB )
   GO
   
   USE [master]
   GO
   ALTER DATABASE [db_ps] SET RECOVERY SIMPLE WITH NO_WAIT
   GO
   
   ALTER AUTHORIZATION ON DATABASE::[db_ps] TO [sa]
   GO"

Invoke-Sqlcmd -ServerInstance . -Query $sql -TrustServerCertificate
Get-DbaDatabase -SqlInstance $Conexion -Database db_ps

#Verificar conexión a sv db con dbatools
Test-DbaConnection $Conexion

#Get-DbaDatabase
#Obtener información sobre db específica
Get-DbaDatabase -SqlInstance $Conexion -Database $nombreDb

#Backup-DbaDatabase
#Copias de seguridad db específica con dbatools
Backup-DbaDatabase -SqlInstance $Conexion -Path C:\carpetaPrueba -Database Cruceros_ASGBD2 -Type Full -Confirm

#New-DbaDatabase
#Creación database con dbatools
$DbName = 'db_dbatools'
$DataPath = 'C:\carpetaPrueba'
$LogPath = 'C:\carpetaPrueba'
$Recovery = 'Simple'
$Owner = 'sa'
$PrimaryFileSize = 1024
$PrimaryFileGrowth = 256
$LogSize = 512
$LogGrowth = 128

New-DbaDatabase -SqlInstance $Conexion -Name $DbName -DataFilePath $DataPath -LogFilePath $LogPath -RecoveryModel $Recovery -Owner $Owner -PrimaryFilesize $PrimaryFileSize -PrimaryFileGrowth $PrimaryFileGrowth -LogSize $LogSize -LogGrowth $LogGrowth

#Comprobando existencia
Get-DbaDatabase -SqlInstance $Conexion -Database $DbName

#Remove-DbaDatabase
#Eliminar db con dbatools
Remove-DbaDatabase -SqlInstance $Conexion -Database $DbName
Get-DbaDatabase -SqlInstance $Conexion -Database $DbName

#Restore-DbaDatabase
#Recuperar Base de datos
Restore-DbaDatabase -SqlInstance $Conexion -Path C:\carpetaPrueba\db_dbatools_202412031407.bak -DestinationDataDirectory C:\carpetaPrueba -WithReplace
Get-DbaDatabase -SqlInstance $Conexion -Database $DbName

#Usando SP desde PS
#SP con Parámetros
$id_promocion = 1
$precio = 99.99
$metodo_pago = "Tarjeta de Crédito"
$fecha_emision = "2024-12-01"
$servidor = "localhost"
$basedatos = "Cruceros_ASGBD2"

Invoke-Sqlcmd -ServerInstance $servidor -Database $baseDatos -Query @"
EXEC [Contadores].[InsertarNuevaFactura]
    @id_promocion = $id_promocion,
    @precio = $precio,
    @metodo_pago = N'$metodo_pago',
    @fecha_emision = '$fecha_emision';
"@ -TrustServerCertificate

#Vista y exportación de salida
$vista = Invoke-Sqlcmd -ServerInstance $servidor -Database $basedatos -Query "sELECT * FROM [Contadores].[Facturas]" -TrustServerCertificate
#viendo vista
$vista

#Exportando en formato .txt
$vista | Out-File C:\carpetaPrueba\vista.txt
notepad C:\carpetaPrueba\vista.txt

#Exportando en formato .cvs
$vista | Export-Csv C:\carpetaPrueba\vista.csv -NoTypeInformation
notepad C:\carpetaPrueba\vista.csv