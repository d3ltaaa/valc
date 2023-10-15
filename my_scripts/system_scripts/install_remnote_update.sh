#!/bin/bash
sudo rm /opt/remnote
cd ~/Downloads
curl -L -o remnote https://www.remnote.com/desktop/linux &&
chmod +x remnote &&
sudo mv remnote /opt

