## installation of LAMP stack on two automated  vagrant machine

This demo project shows a simple automation script for automating 
- A master and a slave machine  vagrant machine
- installation of lamp stack on the two vagrant  machine
- User management
-Inter-node Communication
-Data Management and Transfer
-Process monitoring
-Deployment of lampstack

## create and directory with mkdir Vagrant and touch vagrant.sh to automate the  creation of two machines

Step 1: Initialize a vagrant ubuntu machine
            vagrant init ubuntu/focal64
            N:B ubuntu is a distro of GNU\Linux  and you can decide to install any distro of your choice 

Step 2: Write the configuration of the slave and master machine into vagrant file for outer stream
                   cat <<EOF > Vagrantfile

     Step 2.1: Initializing machine configuration               
     Vagrant.configure("2") do |config|
     config.vm.define "slave_machine" do |slave_machine|

     Step 2.2: specify slave machine hostname
    slave_machine.vm.hostname = "slave_machine"

    Step 2.3: Specifying preferred box
    slave_machine.vm.box = "ubuntu/focal64"

    Step 2.4: Configuring slave machine network type and IP addressing
    slave_machine.vm.network "private_network", ip: "192.168.3.55"
   
    Step 2.5: Provisioning  the slave machine  to  update necessary packages 
    slave_machine.vm.provision "shell", inline: <<-SHELL
    sudo apt-get update && sudo apt-get upgrade -y
    
    Step 2.6: Installing sshpass and enabling Password Authentication to allow ssh connection

    sudo apt install sshpass -y
    sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sudo systemctl restart sshd
    sudo apt-get install -y avahi-daemon libnss-mdns
    SHELL
  end

  config.vm.define "master" do |master|

    master.vm.hostname = "master"
    master.vm.box = "ubuntu/focal64"
    master.vm.network "private_network", ip: "192.168.3.54"
  
    master.vm.provision "shell", inline: <<-SHELL
    sudo apt-get update && sudo apt-get upgrade -y

        N:B  You can get the configuration of vagrant machine on vagrant documentation site below
        https://developer.hashicorp.com/vagrant/docs

Step 3: configuring resource to the machine provider
    config.vm.provider "virtualbox" do |vb|
      vb.memory = "512"
      vb.cpus = "1"
    end
end
EOF

Step 4: Start Machines
              vagrant up

Step 5: ssh into the master machine 
               vagrant ssh

Step 6:Create a user altschool and add to sudo and  root group ,generate an ssh key  and name it authorized_keys , copy and paste the key into a new directory in the slave machine and check the process running 
    sudo useradd -m -G sudo altschool
    echo -e "Damola\nDamola\n" | sudo passwd altschool 
    sudo usermod -aG root altschool
    sudo useradd -ou 0 -g 0 altschool
    sudo -u altschool ssh-keygen -t rsa -b -f /home/altschool/.ssh/id_rsa -N "" -y
    sudo cp /home/altschool/.ssh/id_rsa.pub authorized_key
    sudo ssh-keygen -t rsa -b 4096 -f /home/vagrant/.ssh/id_rsa -N ""
    sudo cat /home/vagrant/.ssh/id_rsa.pub | sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no vagrant@192.168.20.100 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'
    sudo cat ~/authorized_key | sshpass -p "vagrant" ssh vagrant@192.168.20.11 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'
    sshpass -p "Damola" sudo -u altschool mkdir -p /mnt/altschool/slave
    sshpass -p "Damola" sudo -u altschool scp -r /mnt/* vagrant@192.168.20.100:/home/vagrant/mnt
    sudo ps aux > /home/vagrant/running_processes
    exit

Step 7:Installation of LAMPSTACK
       echo -e "\n\nUpdating Apt Packages and upgrading latest patches\n"
sudo apt update -y

sudo apt install apache2 -y

echo -e "\n\nAdding firewall rule to Apache\n"
sudo ufw allow in "Apache"

sudo ufw status

echo -e "\n\nInstalling MySQL\n"
sudo apt install mysql-server -y

echo -e "\n\nPermissions for /var/www\n"
sudo chown -R www-data:www-data /var/www
echo -e "\n\n Permissions have been set\n"

sudo apt install php libapache2-mod-php php-mysql -y

echo -e "\n\nEnabling Modules\n"
sudo a2enmod rewrite
sudo phpenmod mcrypt

sudo sed -i 's/DirectoryIndex index.html index.cgi index.pl index.xhtml index.htm/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/' /etc/apache2/mods-enabled/dir.conf

echo -e "\n\nRestarting Apache\n"
sudo systemctl reload apache2

echo -e "\n\nLAMP Installation Completed"