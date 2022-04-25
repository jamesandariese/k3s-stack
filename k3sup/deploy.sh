printf "%50s: %s\n" K3S_DEFINITELY_INSTALL_OVER_EXISTING_CLUSTER "${K3S_DEFINITELY_INSTALL_OVER_EXISTING_CLUSTER:=no}"
printf "%50s: %s\n" K3S_EXTRA_ARGS "${K3S_EXTRA_ARGS:=--disable traefik --disable servicelb -disable local-storage}"
printf "%50s: %s\n" SERVER_USER "${SERVER_USER:=$USER}"
printf "%50s: %s\n" K3S_VERSION "${K3S_VERSION:=v1.23.5+k3s1}"
printf "%50s: %s\n" K3SUP_LOCAL_PATH "${K3SUP_LOCAL_PATH:=$HOME/.kube/config}"

if kubectl get nodes;then
  if [ x"$K3S_DEFINITELY_INSTALL_OVER_EXISTING_CLUSTER" = xyes ];then
    exit 0
  fi
  echo "About to deploy on the existing cluster:"
  kubectl cluster-info
  echo "Ctrl-C to cancel"
  sleep 30 || exit 1
  exit 0
fi

install_servers() {
  SERVER="$1"
  k3sup install --local-path "$K3SUP_LOCAL_PATH" --ip "$SERVER" --user "$SERVER_USER" --sudo --k3s-version "$K3S_VERSION" --k3s-extra-args "$K3S_EXTRA_ARGS" --cluster
  while [ $# -gt 1 ];do
    shift
    k3sup join --server --server-ip "$SERVER" --ip "$1" --server-user "$SERVER_USER" --user "$SERVER_USER" --sudo --k3s-version "$K3S_VERSION" --k3s-extra-args "$K3S_EXTRA_ARGS" &
  done
  wait
}

install_agents() {
  while [ $# -gt 0 ];do
    k3sup join --server-ip "$SERVER" --ip "$1" --server-user "$SERVER_USER" --user "$SERVER_USER" --sudo --k3s-version "$K3S_VERSION" &
    shift
  done
  wait
}

# expanding weirdly because zsh
install_servers $(echo "$SERVERS")
install_agents $(echo "$NODES")
