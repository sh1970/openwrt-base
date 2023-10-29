#!/bin/bash
#set -x

export IMAGE="openwrt-dnsmasq:latest"
export CONTAINERNAME="tftpboot-server"

ARGS="--rm --name tftpboot-server -d --cap-add NET_ADMIN --network host -v $PWD/dnsmasq.conf:/etc/dnsmasq.conf -v $PWD/tftpboot:/tftpboot"

if command -v docker-compose &> /dev/null; then
  # If docker-compose exists, use it
  case "$1" in
    build)
      docker-compose build
      ;;
    config)
      docker-compose config
      ;;
    start)
      docker-compose up -d
      ;;
    stop)
      docker-compose down
      ;;
    restart)
      docker-compose restart $CONTAINERNAME
      ;;
    *)
      echo "Usage: $0 {build|config|start|stop|restart}" >&2
      exit 1
      ;;
  esac
else
  # If docker-compose doesn't exist, run other commands
  case "$1" in
    build)
      docker build -t $IMAGE -f Dockerfile.dnsmasq .
      ;;
    start)
      docker run $ARGS $IMAGE
      ;;
    stop)
      docker stop $CONTAINERNAME
      ;;
    restart)
      docker restart $CONTAINERNAME
      ;;
    *)
      echo "Usage: $0 {build|start|stop|restart}" >&2
      exit 1
      ;;
  esac
fi

