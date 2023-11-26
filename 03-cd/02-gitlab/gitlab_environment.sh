#!/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
VAGRANT_BOX="bootcampVM"
export VAGRANT_VAGRANTFILE="gitlab/Vagrantfile"
export VAGRANT_DOTFILE_PATH="$HOME/gitlab-vagrant"
DOCKER_COMPOSE_FILE="gitlab/docker-compose.yml"

docker_tool () { 
	docker compose -f $DOCKER_COMPOSE_FILE $1 
}

vagrant_tool () {
	vagrant $1 $VAGRANT_BOX
}
echo -e "${YELLOW}1 - Docker environment"
echo -e "${YELLOW}2 - Vagrant environment"
echo -e "${GREEN}### Choose the Gitlab environment ###"
read gitlab_env;
case $gitlab_env in
  1) echo -e "${YELLOW}1 - Build and run gitlab"
     echo -e "${YELLOW}2 - Stop gitlab"
     echo -e "${YELLOW}3 - Start gitlab"
     echo -e "${YELLOW}4 - Destroy gitlab"
     echo -e "${GREEN}### Choose your option and press enter ###"
     read docker_option;
     case $docker_option in
       1) echo -e "${GREEN}### Preparing gitlab environment ###\n"
          docker_tool "up -d"
          echo -e "${GREEN}\n### Registering gitlab runner ###\n"
          /bin/bash gitlab/runner_register.sh
       ;;
       2) echo -e "${YELLOW}### Stopping gitlab environment ###\n"
          docker_tool "stop"
       ;;
       3) echo -e "${GREEN}### Starting gitlab environment ###\n"
          docker_tool "start"
       ;;
       4) echo -e ${RED}"### Destroying gitlab environment ###\n"
          docker_tool "down -v"
       ;;
       *) echo " Please choose a different option (1,2,3,4)";; 
     esac
  ;;
  2) echo -e "${YELLOW}1 - Build and run gitlab vagrant machine"
     echo -e "${YELLOW}2 - Suspend gitlab vagrant machine"
     echo -e "${YELLOW}3 - Resume gitlab vagrant machine"
     echo -e "${YELLOW}4 - Destroy gitlab vagrant machine"
     read vagrant_option;
     case $vagrant_option in
       1) echo -e "${GREEN}### Preparing gitlab vagrant machine ###\n"
          vagrant_tool "up"
       ;;
       2) echo -e "${YELLOW}### Suspending gitlab vagrant machine ###\n"
          vagrant_tool "suspend"
       ;;
       3) echo -e "${GREEN}### Resuming gitlab vagrant machine  ###\n"
          vagrant_tool "resume"
       ;;
       4) echo -e ${RED}"### Destroying gitlab vagrant machine ###\n"
          vagrant_tool "destroy"
       ;;
       *) echo " Please choose a different option (1,2,3,4)";;
     esac
  ;;
  *) echo " Please choose a different option (1,2)";;    
esac
