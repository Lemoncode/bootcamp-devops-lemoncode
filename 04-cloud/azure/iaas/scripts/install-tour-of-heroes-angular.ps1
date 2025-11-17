param(
    [string]$release_url,
    [string]$api_url
)

# Crear carpeta Temp si no existe
Write-Output "[INFO] Creando carpeta temporal C:\Temp"
if (-not (Test-Path "C:\Temp")) {
    New-Item -ItemType Directory -Path "C:\Temp" -Force | Out-Null
}

Write-Output "[INFO] Instalando IIS en la VM del frontend"
Install-WindowsFeature -name Web-Server -IncludeManagementTools

Write-Output "[INFO] Descargando modulo URL Rewrite"
Invoke-WebRequest -Uri "https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi" -OutFile C:\Temp\rewrite_amd64_en-US.msi

Write-Output "[INFO] Instalando modulo URL Rewrite"
Start-Process -FilePath "C:\Temp\rewrite_amd64_en-US.msi" -ArgumentList "/quiet" -Wait

Write-Output "[INFO] Modificando pagina index.html predeterminada"
$new_content =
@"
<!DOCTYPE html>
<html>
<body>
<h1>Hola desarrollador!</h1>
<p>Ejecutandose en <b>$env:computername</b></p>
</body>
</html>
"@

Set-Content -Path C:\inetpub\wwwroot\index.html -Value $new_content

Write-Output "[INFO] Creando carpeta para la aplicacion del frontend"
mkdir $env:systemdrive\inetpub\wwwroot\frontend

Write-Output "[INFO] Descargando la ultima version de la aplicacion desde GitHub"
Invoke-WebRequest -Uri $release_url -OutFile C:\Temp\dist.zip

Write-Output "[INFO] Descomprimiendo la aplicacion del frontend"
Expand-Archive -Path C:\Temp\dist.zip -DestinationPath C:\inetpub\wwwroot\frontend

Write-Output "[INFO] Reemplazando variables de entorno"
((Get-Content -path C:\inetpub\wwwroot\frontend\assets\env.template.js -Raw) -replace ([regex]::Escape('${API_URL}')), $api_url) | Set-Content -Path C:\inetpub\wwwroot\frontend\assets\env.js
 
Write-Output "[INFO] Creando nuevo sitio web en IIS"
New-IISSite -Name "TourOfHeroesAngular" -BindingInformation "*:8080:" -PhysicalPath "$env:systemdrive\inetpub\wwwroot\frontend"

Write-Output "[INFO] Creando aplicacion dentro del nuevo sitio"
New-WebApplication -Name "TourOfHeroesAngular" -Site "TourOfHeroesAngular" -ApplicationPool "TourOfHeroesAngular" -PhysicalPath "$env:systemdrive\inetpub\wwwroot\frontend"

Write-Output "[INFO] Habilitando puerto 8080 en el firewall"
New-NetFirewallRule -DisplayName "Permitir 8080" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow

Write-Output "[SUCCESS] Instalacion completada!"
