# -*- mode: ruby -*-
# # vi: set ft=ruby :

# Specify minimum Vagrant version and Vagrant API version
Vagrant.require_version ">= 1.6.0"
VAGRANTFILE_API_VERSION = "2"

# Require YAML module
require 'yaml'

# Read YAML file with infrastructure details
hosts = YAML.load_file('servers.yaml')

# Create variables from YAML dictionary
net = hosts["subnet"]

file_root = File.dirname(File.expand_path(__FILE__))

# Create boxes
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    hosts["vms"].each_with_index do |servers, index|
        ip = servers["ip"] ||= "#{index + 100}"
        hostname = servers["name"]

        # Hostmanager Config
        config.hostmanager.enabled = true
        config.hostmanager.manage_host = false
        config.hostmanager.manage_guest = true
        config.hostmanager.ignore_private_ip = false
        config.hostmanager.include_offline = true
        # Hostmanager Config
        config.vm.synced_folder "files/", "/vagrant"
        config.vm.define servers["name"] do |srv|
            srv.vm.box = servers["box"]
            srv.vm.hostname = servers["name"]
            srv.vm.network "private_network", ip: "#{net}.#{ip}"
            #srv.hostmanager.aliases = %w("#{hostname}".ocp.core.local)
            srv.vm.provider :virtualbox do |vb|
                vb.name = servers["name"]
                vb.cpus = servers["cpu"]
                vb.memory = servers["ram"]
                vb.linked_clone = hosts["linked_mode"]
                vb.customize ["modifyvm", :id, "--macaddress1", "auto"]
                vb.customize ["modifyvm", :id, "--vram", "7"]
                if servers["storage"]
                    servers["storage"].each_with_index do |disk, index|
                        file_to_disk = File.join(file_root, "#{hostname}#{index}.vdi")
                        unless File.exist?(file_to_disk)
                            vb.customize ['createhd', '--filename', file_to_disk, '--format', 'VDI', '--size', disk["size"] * 1024]
                        end
                        scsiport = "#{index + 3}"
                        #vb.customize ['storageattach', :id,  '--storagectl', 'SCSI', '--port', scsiport, '--type', 'hdd', '--medium', file_to_disk]
                        # Following works for centos/7 box
                        deviceport = "#{index + 1}"
                        vb.customize ['storageattach', :id, '--storagectl', 'IDE', '--port', '0', '--device', deviceport, '--type', 'hdd', '--medium', file_to_disk]
                    end
                end
            end
            
            dns_config = <<-SCRIPT
                echo "...Configuring /etc/hosts"
                sed 's/127.0.0.1.*#{hostname}*/#{net}.#{ip} #{hostname}/' -i /etc/hosts
            SCRIPT
            
            srv.vm.provision "shell", inline: <<-SHELL
                #{dns_config}
            SHELL
            
            if servers["provision"]
                if servers["provision"]['scripts']
                    servers["provision"]['scripts'].each do |file|
                        srv.vm.provision "shell", path: file["name"], args: file["args"]
                    end
                end
            end
            
            if servers["provision"]
                if servers["provision"]['playbooks']
                    servers["provision"]['playbooks'].each do |file|
                        srv.vm.provision "ansible_local" do |ansible|
                            ansible.playbook = file["name"]
                        end
                    end
                end
            end
        end
    end
end    
