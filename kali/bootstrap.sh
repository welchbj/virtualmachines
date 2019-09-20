#!/usr/bin/env bash

set -e

# apt requirements
sudo apt-get update
sudo apt-get install -y \
  build-essential  \
  git              \
  libssl-dev       \
  libffi-dev       \
  python2.7        \
  python-pip       \
  python3-pip      \
  python-dev       \
  tmux             \
  xclip

# install vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# fetch dotfiles
if [[ -d ~/.dotfiles ]]; then
  rm -rf ~/.dotfiles
fi
git clone https://github.com/welchbj/dotfiles ~/.dotfiles
ln -sf ~/.dotfiles/.bashrc       ~/.bashrc
ln -sf ~/.dotfiles/.bash_aliases ~/.bash_aliases
ln -sf ~/.dotfiles/.vimrc        ~/.vimrc

# setup virtual environments
sudo pip install --upgrade pip
sudo pip install --upgrade virtualenvwrapper

VIRTUALENV_SETUP='
# virtualenvwrapper setup
export WORKON_HOME=~/Envs
mkdir -p $WORKON_HOME
source ~/.local/bin/virtualenvwrapper.sh'

eval "$VIRTUALENV_SETUP"
cat <<< $VIRTUALENV_SETUP >> ~/.bashrc

mkvirtualenv -p $(which python) utils-py2 || true
mkvirtualenv -p $(which python3) utils-py3 || true

# install Python 2 utility libraries
workon utils-py2
pip install --upgrade \
  flake8   \
  pwntools \
  requests

# install Python 3 utility libraries
workon utils-py3
pip install --upgrade \
  flake8   \
  mypy     \
  requests

deactivate

# install peda
if [[ ! -d /opt/peda ]]; then
  sudo git clone https://github.com/longld/peda.git /opt/peda
  echo "source /opt/peda/peda.py" >> ~/.gdbinit
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
  sudo mkdir -p /opt/gobuster
  sudo mv gobuster /opt/gobuster/gobuster
  popd
  popd
  rm -rf $GOBUSTER_TMP

  echo ''                                >> ~/.bashrc
  echo '# add gobuster to path'          >> ~/.bashrc
  echo 'export PATH=/opt/gobuster:$PATH' >> ~/.bashrc
fi

# install pspy binaries
if [[ ! -d /opt/psy ]]; then
  sudo mkdir -p /opt/pspy
  pushd /opt/pspy
  sudo wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy32
  sudo wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy64
  sudo wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy32s
  sudo wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy64s
  sudo chmod +x /opt/pspy/pspy*
  popd

  echo ''                            >> ~/.bashrc
  echo '# add pspy to PATH'          >> ~/.bashrc
  echo 'export PATH=/opt/pspy:$PATH' >> ~/.bashrc
fi
