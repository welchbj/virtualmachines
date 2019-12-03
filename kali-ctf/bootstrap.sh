#!/usr/bin/env bash

set -ex

if [[ $(id -u) -ne 0 ]]; then
  echo 'This script is only designed to be run as root'
  exit 1
fi

# apt requirements
apt-get update
apt-get install -y  \
  build-essential   \
  gdb               \
  git               \
  libssl-dev        \
  libffi-dev        \
  python2.7         \
  python-pip        \
  python3-pip       \
  python-dev        \
  tmux              \
  xclip

mkdir /opt || true

# fetch dotfiles
if [[ ! -d /opt/dotfiles ]]; then
  git clone https://github.com/welchbj/dotfiles /opt/dotfiles
  pushd /opt/dotfiles && ./init.sh && popd
fi

# setup virtual environments
pip install --upgrade pip
pip install --upgrade virtualenvwrapper

VIRTUALENV_SETUP='
# virtualenvwrapper setup
export WORKON_HOME=~/Envs
mkdir -p $WORKON_HOME
source /usr/local/bin/virtualenvwrapper.sh'

eval "$VIRTUALENV_SETUP"
cat <<< $VIRTUALENV_SETUP >> ~/.bashrc

mkvirtualenv -p $(which python) utils2 || true
mkvirtualenv -p $(which python3) utils3 || true

# install Python 2 utility libraries
workon utils2
pip install --upgrade \
  flake8    \
  pwntools  \
  requests

# install Python 3 utility libraries
workon utils3
pip install --upgrade \
  flake8    \
  mypy      \
  pwntools  \
  requests

deactivate

# install GEF
if [[ ! -d /opt/gef ]]; then
  mkdir /opt/gef
  pushd /opt
  git clone https://github.com/hugsy/gef
  echo "source /opt/gef/gef.py" >> ~/.gdbinit
  popd
fi

# install go
if ! which go; then
  pushd /tmp
  wget -O go.tar.gz https://dl.google.com/go/go1.13.linux-amd64.tar.gz
  tar -xvf go.tar.gz
  sudo mv go/bin/go /usr/local/bin
  sudo mv go/bin/gofmt /usr/local/bin
  popd

  echo ''                              >> ~/.bashrc
  echo '# add go to path'              >> ~/.bashrc
  echo 'export GOROOT=/usr/local/go'   >> ~/.bashrc
  echo 'export PATH=$GOROOT/bin:$PATH' >> ~/.bashrc
fi

# install gobuster binaries
if [[ ! -d /opt/gobuster ]]; then
  GOBUSTER_TMP=$(mktemp -d)
  pushd $GOBUSTER_TMP
  wget -O gobuster.7z https://github.com/OJ/gobuster/releases/download/v3.0.1/gobuster-linux-amd64.7z
  7z x gobuster.7z
  pushd gobuster-linux-amd64
  chmod +x gobuster
  mkdir /opt/gobuster
  mv gobuster /opt/gobuster/gobuster
  popd
  popd
  rm -rf $GOBUSTER_TMP

  echo ''                                >> ~/.bashrc
  echo '# add gobuster to path'          >> ~/.bashrc
  echo 'export PATH=/opt/gobuster:$PATH' >> ~/.bashrc
fi

# install pspy binaries
if [[ ! -d /opt/pspy ]]; then
  mkdir /opt/pspy
  pushd /opt/pspy
  wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy32
  wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy64
  wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy32s
  wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy64s
  chmod +x /opt/pspy/pspy*
  popd

  echo ''                            >> ~/.bashrc
  echo '# add pspy to PATH'          >> ~/.bashrc
  echo 'export PATH=/opt/pspy:$PATH' >> ~/.bashrc
fi
