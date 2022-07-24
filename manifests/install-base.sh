#!/usr/bin/bash

sudo apt-get update -qq && sudo apt-get -y -qq upgrade

# Install Components
sudo apt-get -y -qq install gnupg2 curl apt-transport-https > /dev/null

# Install JRE
# Test if JRE is installed
java --version > /dev/null 2>&1
JRE_IS_INSTALLED=$?

if [[ $JRE_IS_INSTALLED -ne 0 ]]; then
  echo ">>> Installing JRE"
  sudo apt-get -qq -y install default-jre > /dev/null
else
  echo ">>> JRE is already installed!"
fi

# Install JDK
# Test if JDK is installed
javac --version > /dev/null 2>&1
JDK_IS_INSTALLED=$?

if [[ JDK_IS_INSTALLED -ne 0 ]]; then
  echo ">>> Installing JDK"
  sudo apt-get -qq -y install default-jdk > /dev/null
else
  echo ">>> JDK is already installed!"
fi
