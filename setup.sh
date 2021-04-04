#!/bin/env bash

# read .env file
# TODO: change the path
export $(grep -v '^#' $HOME/dev/config/docker-kalilinux/.env | xargs)

docker build . -t $IMAGE_NAME
docker run -tid --net host --name $CONTAINER_NAME $IMAGE_NAME
docker exec -ti $CONTAINER_NAME apt install -y zsh kitty curl git bat trash-cli fzf papirus-icon-theme
docker exec -ti $CONTAINER_NAME useradd -ms /usr/bin/zsh $USER
docker exec -ti $CONTAINER_NAME gpasswd -a $USER sudo
echo "New password for root"
docker exec -ti $CONTAINER_NAME passwd root
echo "New password for ${USER}"
docker exec -ti $CONTAINER_NAME passwd $USER
# install oh my zsh
docker exec -tiu $USER $CONTAINER_NAME sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# install powerlevel10k
docker exec -tiu $USER $CONTAINER_NAME git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
# install zsh syntax highlighting
docker exec -ti $CONTAINER_NAME git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
	${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

docker commit $CONTAINER_NAME $IMAGE_NAME
docker stop $CONTAINER_NAME && docker container rm $CONTAINER_NAME
echo "Done."
