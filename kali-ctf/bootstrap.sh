#!/usr/bin/env bash

set -eux -o pipefail

###########################################################################
# Dev tools.                                                              #
###########################################################################

echo 'Installing development packages...'
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  build-essential \
  checkinstall    \
  docker.io       \
  gdb             \
  git             \
  libssl-dev      \
  python2.7       \
  python-pip      \
  python3-pip

echo 'Installing terminal utilities...'
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  tmux  \
  xclip

###########################################################################
# Language runtimes.                                                      #
###########################################################################

echo 'Installing golang...'
# See: https://stackoverflow.com/a/41323785
new_golang_ver=$(curl https://golang.org/VERSION?m=text 2> /dev/null)
cd /tmp
wget https://dl.google.com/go/${new_golang_ver}.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf  ${new_golang_ver}.linux-amd64.tar.gz
echo ''                                      >> ~/.bashrc
echo '# golang setup'                        >> ~/.bashrc
echo 'export PATH=/usr/local/go/bin:${PATH}' >> ~/.bashrc
echo 'export GOPATH=${HOME}/gopath'          >> ~/.bashrc
echo 'export PATH=${GOPATH}/bin:${PATH}'     >> ~/.bashrc
source ~/.bashrc

echo 'Installing Rust...'
curl https://sh.rustup.rs -sSf | sh -s -- -y

echo 'Installing latest Python from source...'
# See: https://tecadmin.net/install-python-3-8-ubuntu/
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  libbz2-dev            \
  libc6-dev             \
  libffi-dev            \
  libgdbm-dev           \
  libncursesw5-dev      \
  libreadline-gplv2-dev \
  libsqlite3-dev        \
  libssl-dev            \
  tk-dev                \
  zlib1g-dev
cd /opt
sudo wget https://www.python.org/ftp/python/3.8.1/Python-3.8.1.tgz
sudo tar xzf Python-3.8.1.tgz
sudo rm -f Python-3.8.1.tgz
cd Python-3.8.1
sudo ./configure --enable-optimizations
sudo make altinstall

echo 'Setting up virtualenv and virtualenvwrapper...'
pip install --upgrade pip
pip install --upgrade virtualenvwrapper

VIRTUALENV_SETUP='
# virtualenvwrapper setup
export WORKON_HOME=~/Envs
mkdir -p $WORKON_HOME
source ~/.local/bin/virtualenvwrapper.sh
export PATH=~/.local/bin:${PATH}'

eval "$VIRTUALENV_SETUP"
cat <<< $VIRTUALENV_SETUP >> ~/.bashrc

echo 'Creating Python 2 utilities virtualenv...'
mkvirtualenv -p $(which python) utils-py2
workon utils-py2
pip install --upgrade \
  flake8   \
  pwntools \
  requests

echo 'Creating Python 3 utilities virtualenv...'
mkvirtualenv -p $(which python3.8) utils-py3
workon utils-py3
pip install --upgrade \
  flake8   \
  pwntools \
  requests

echo 'Installing modern Java JDK/JRE...'
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  openjdk-11-jdk \
  openjdk-11-jre

###########################################################################
# Web security tools.                                                     #
###########################################################################

echo 'Making web-tools virtualenv...'
mkvirtualenv -p $(which python3.8) web-tools
workon web-tools

echo 'Installing gobuster...'
go get github.com/OJ/gobuster

echo 'Installing wafw00f...'
pip install --upgrade wafw00f

###########################################################################
# Binary analysis tools.                                                  #
###########################################################################

echo 'Installing GEF...'
wget -q -O- https://github.com/hugsy/gef/raw/master/scripts/gef.sh | sh

echo 'Installing seccomp-tools...'
sudo gem install seccomp-tools

###########################################################################
# Wordlists.                                                              #
###########################################################################

echo 'Installing fuzzdb...'
cd /opt
sudo git clone https://github.com/fuzzdb-project/fuzzdb
sudo chown -R user /opt/fuzzdb

echo 'Installing SecLists...'
cd /opt
sudo git clone https://github.com/danielmiessler/SecLists
sudo chown -R user /opt/SecLists

###########################################################################
# Linux enumeration tools.                                                #
###########################################################################

echo 'Installing LinEnum...'
cd /opt
sudo git clone https://github.com/rebootuser/LinEnum
sudo chown -R user /opt/LinEnum

echo 'Installing pspy...'
sudo mkdir /opt/pspy
sudo wget -O /opt/pspy/pspy32 https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy32
sudo wget -O /opt/pspy/pspy64 https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy64
sudo wget -O /opt/pspy/pspy32s https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy32s
sudo wget -O /opt/pspy/pspy64s https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy64s
sudo chmod +x /opt/pspy/pspy*
sudo chown -R user /opt/pspy

###########################################################################
# Forensics tools.                                                        #
###########################################################################

echo 'Installing volatility...'
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y volatility

###########################################################################
# Stego tools.                                                            #
###########################################################################

echo 'Making stego-tools virtualenv...'
mkvirtualenv -p $(which python3.8) stego-tools
workon stego-tools

echo 'Installing oletools...'
pip install --upgrade oletools

echo 'Installing pngcheck...'
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y pngcheck

echo 'Installing zsteg...'
sudo gem install zsteg