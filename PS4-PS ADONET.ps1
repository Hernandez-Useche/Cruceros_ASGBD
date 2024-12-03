#Variable para que no haya problema con certificados al realizar conexión
$Connection = "server=localhost;integrated security=true"
$ConnectionSHU = "server=localhost;integrated security=true;database=SHU"
$ConexiónSql = New-Object System.Data.SqlClient.SqlConnection($Connection)
$ConexiónSHU = New-Object System.Data.SqlClient.SqlConnection($ConnectionSHU)

#Creando db
$ComandoCreacion = New-Object System.Data.SqlClient.SqlCommand("CREATE DATABASE SHU", $ConexiónSql)

$ConexiónSql.Open()
$ComandoCreacion.ExecuteNonQuery()
$ConexiónSql.Close()

#Comprobando existencia con dbatools
Get-DbaDatabase -SqlInstance $Connection -Database SHU

#Creando tabla
#Creando variable con sentencia de creación
$ComandoCreacionTabla = @"
CREATE TABLE TablaADONET(
    Id INT PRIMARY KEY,
    Nombre NVARCHAR(50),
    Fecha DATE
);
"@

#Creando objeto de comando
$ComandoCreacionTabla = New-Object System.Data.SqlClient.SqlCommand($ComandoCreacionTabla, $ConexiónSHU)

#Creando tabla
$ConexiónSHU.Open()
try{
    $ComandoCreacionTabla.ExecuteNonQuery()
    Write-Host "Tabla Creada correctamente"
} catch {
    Write-Host "Error al crear la tabla"
} finally {
    $ConexiónSHU.Close()
}

# Variable ruta archivo .txt
$RutaArchivoTxT = "C:\carpetaPrueba\cargaTablaADONET.txt"

# Lectura del archivo línea por línea
$datosArchivo = Get-Content $RutaArchivoTxT

#Añadiendo campos de archivo .txt
# Abrir conexión
$ConexiónSHU.Open()
try {
    foreach ($linea in $datosArchivo) {
        # Dividiendo campos por coma
        $campos = $linea -split ","

        # Asignando valores a variables
        $Id = [int]$campos[0]
        $Nombre = $campos[1]
        $Fecha = $campos[2]
       
        # Comando de inserción
        $ComandoSQL = "INSERT INTO TablaADONET (Id, Nombre, Fecha) VALUES ($Id, '$Nombre', '$Fecha')"

        # Creando objeto de comando para cada inserción
        $ComandoInsercionDatos = New-Object System.Data.SqlClient.SqlCommand($ComandoSQL, $ConexiónSHU)

        # Ejecutando comando
        $ComandoInsercionDatos.ExecuteNonQuery()
    }
    Write-Host "Registros insertados correctamente"
} catch {
    Write-Error "Error al insertar datos:"
} finally {
    # Cerrando conexión
    $ConexiónSHU.Close()
}

#Listando registros de una tabla
$ComandoListarRegistros = "SELECT * FROM TablaADONET"

#Creando objeto de comando
$ComandoSelección = New-Object System.Data.SqlClient.SqlCommand($ComandoListarRegistros,$ConexiónSHU)

#Leer registros
$ConexiónSHU.Open()
try{
    #Ejecutar comando y obtener datos
    $Lector =$ComandoSelección.ExecuteReader()
    #Leer registros y mostrarlos
    while($Lector.Read()){
        $Id = $Lector["Id"]
        $Nombre = $Lector["Nombre"]
        $Fecha = $Lector["Fecha"]
        #Mostrar resultados
        Write-Host "Id: $Id, Nombre: $Nombre, Fecha: $Fecha"
        #Guardar resultados en txt
        $Línea = "$Id,$Nombre,$($Fecha.ToString('yyyy-MM-dd'))"
        Add-Content -Path C:\carpetaPrueba\datos.txt -Value $Línea
    }
    #Cerrar lector
    $Lector.Close()
} catch {
    Write-Error "Error al listar los registros de la tabla"
} finally {
    #Cerrar conexión
    $ConexiónSHU.Close()
}