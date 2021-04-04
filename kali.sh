#!/bin/env bash

# read .env file
export $(grep -v '^#' $HOME/dev/config/docker-kalilinux/.env | xargs)

# options
case $1 in
	commit) docker commit $CONTAINER_NAME $IMAGE_NAME;;
	reboot) docker commit $CONTAINER_NAME $IMAGE_NAME && docker stop $CONTAINER_NAME && docker container rm $CONTAINER_NAME;;
	fast-reboot) docker stop $CONTAINER_NAME && docker container rm $CONTAINER_NAME;;
esac

function boot() {
	docker run -td \
		--privileged \
		--net host \
		--name $CONTAINER_NAME \
		--gpus all \
		--security-opt label=type:container_runtime_t \
		-e DISPLAY=unix$DISPLAY \
		-e PULSE_SERVER=unix:/run/user/1000/pulse/native \
		-e QT_QPA_PLATFORMTHEME=qt5ct \
		-e _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel -Dsun.java2d.opengl=true' \
		-e XDG_RUNTIME_DIR=/run/user/1000 \
		-e GTK_USER_PORTAL=1 \
		-e JAVA_HOME=/usr/lib/jvm/default \
		-u 1000 \
		-v /etc/hosts:/etc/hosts \
		-v /hdd:/hdd \
		-v /tmp/:/tmp/ \
		-v /run/user/1000:/run/user/1000 \
		-v $HOME/.gnupg:$HOME/.gnupg:ro \
		-v $HOME/.Xauthority:$HOME/.Xauthority \
		$IMAGE_NAME

	echo 'Copying fonts'
	docker cp /usr/share/fonts $CONTAINER_NAME:/usr/share/fonts
	echo 'Copying fonts configuration'
	docker cp /etc/fonts $CONTAINER_NAME:/etc/fonts
	echo 'Copying themes'
	docker cp /usr/share/themes $CONTAINER_NAME:/usr/share/themes
	echo 'Copying xfce4 configuration'
	docker cp $HOME/.config/xfce4 $CONTAINER_NAME:$HOME/.config/xfce4
}

# if container doesn't exist
[[ -z `docker ps -aqf name=${CONTAINER_NAME}` ]] && boot

# if container stopped
[[ -z `docker ps -qf name=${CONTAINER_NAME}` ]] && docker start $CONTAINER_NAME

# Start the necessary services
docker exec -du root $CONTAINER_NAME service binfmt-support start

if [[ `docker exec -ti ${CONTAINER_NAME} ls "$(pwd)"` == *"cannot access"* ]]; then
	echo "Redirected to $HOME"
	docker exec -ti -w "${HOME}" $CONTAINER_NAME /usr/bin/zsh
else
	docker exec -ti -w "`pwd`" $CONTAINER_NAME /usr/bin/zsh
fi
