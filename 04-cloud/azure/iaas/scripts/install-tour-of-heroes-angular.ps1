param(
    [string]$release_url,
    [string]$api_url
)

Write-Output "Install IIS on the frontend vm"
Install-WindowsFeature -name Web-Server -IncludeManagementTools

Write-Output "Download URL Rewrite Module from here https://www.iis.net/downloads/microsoft/url-rewrite"
Invoke-WebRequest -Uri "https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi" -OutFile C:\Temp\rewrite_amd64_en-US.msi

Write-Output "Install URL Rewrite Module"
Start-Process -FilePath "C:\Temp\rewrite_amd64_en-US.msi" -ArgumentList "/quiet" -Wait

Write-Output "Modify the default website index.html with the name of the computer"
$new_content =
@"
<!DOCTYPE html>
<html>
<body>
<h1>Hello developer!</h1>
<p>Running on <b>$env:computername</b></p>
</body>
</html>
"@

Set-Content -Path C:\inetpub\wwwroot\index.html -Value $new_content

Write-Output "Create a folder for the frontend app"
mkdir $env:systemdrive\inetpub\wwwroot\frontend

Write-Output "Download the last release of the frontend app from github"
Invoke-WebRequest -Uri $release_url -OutFile C:\Temp\dist.zip

Write-Output "Unzip the frontend app in the folder"
Expand-Archive -Path C:\Temp\dist.zip -DestinationPath C:\inetpub\wwwroot\frontend

Write-Output "Replace environment variables like envsubst in linux"
((Get-Content -path C:\inetpub\wwwroot\frontend\assets\env.template.js -Raw) -replace ([regex]::Escape('${API_URL}')), $api_url) | Set-Content -Path C:\inetpub\wwwroot\frontend\assets\env.js
 
Write-Output "Create a new website in IIS"
New-IISSite -Name "TourOfHeroesAngular" -BindingInformation "*:8080:" -PhysicalPath "$env:systemdrive\inetpub\wwwroot\frontend"

Write-Output "Create an aplication inside the new site"
New-WebApplication -Name "TourOfHeroesAngular" -Site "TourOfHeroesAngular" -ApplicationPool "TourOfHeroesAngular" -PhysicalPath "$env:systemdrive\inetpub\wwwroot\frontend"

Write-Output "Enable 8080 port in the firewall"
New-NetFirewallRule -DisplayName "Allow 8080" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow
