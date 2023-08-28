sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-$(lsb_release -cs)-prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/dotnetdev.list'


sudo apt update  -y
sudo apt-get install azure-functions-core-tools-4 -y
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
