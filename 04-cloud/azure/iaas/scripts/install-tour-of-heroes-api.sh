echo -e "Install nginx server"
sudo apt update && sudo apt install -y nginx unzip

echo -e "Install .NET Core"
wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && sudo dpkg -i packages-microsoft-prod.deb && rm packages-microsoft-prod.deb && sudo apt-get update && sudo apt-get install -y aspnetcore-runtime-7.0

systemctl status nginx

sudo mkdir -p /var/www/tour-of-heroes-api
sudo chown -R $USER:$USER /var/www/tour-of-heroes-api
sudo chmod -R 755 /var/www/tour-of-heroes-api

echo -e "Download the last release of the api app from github"
wget $1 -O drop.zip

echo -e "Unzip the api app"
unzip drop.zip -d /var/www/tour-of-heroes-api

sudo sed -i 's/# server_names_hash_bucket_size 64;/server_names_hash_bucket_size 128;/g' /etc/nginx/nginx.conf

sudo SERVER_NAME=$2 bash -c 'cat > /etc/nginx/sites-available/tour-of-heroes-api.conf <<EOF
server {
     listen        80;
     server_name   $SERVER_NAME;
     location / {
         proxy_pass         http://localhost:5000;
         proxy_http_version 1.1;
         proxy_set_header   Upgrade \$http_upgrade;
         proxy_set_header   Connection keep-alive;
         proxy_set_header   Host \$host;
         proxy_cache_bypass \$http_upgrade;
         proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
         proxy_set_header   X-Forwarded-Proto \$scheme;
     }
 }
EOF'

sudo ln -s /etc/nginx/sites-available/tour-of-heroes-api.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

sudo bash -c "cat <<EOF > /etc/systemd/system/tour-of-heroes-api.service
[Unit]
Description=Tour of heroes .NET Web API App running on Ubuntu

[Service]
WorkingDirectory=/var/www/tour-of-heroes-api
ExecStart=/usr/bin/dotnet /var/www/tour-of-heroes-api/tour-of-heroes-api.dll

RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=dotnet-tour-of-heroes-api
User=www-data
Environment=ASPNETCORE_ENVIRONMENT=Development
Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false
Environment=ConnectionStrings__DefaultConnection='Server=192.168.1.4,1433;Initial Catalog=heroes;Persist Security Info=False;User ID=$3;Password=$4;TrustServerCertificate=True'

[Install]
WantedBy=multi-user.target
EOF"

sudo systemctl enable tour-of-heroes-api.service
sudo systemctl start tour-of-heroes-api.service
# sudo systemctl disable tour-of-heroes-api.service
sudo systemctl status tour-of-heroes-api.service

# journalctl -u tour-of-heroes-api.service