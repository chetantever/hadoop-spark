Vagrant.require_version ">= 1.4.3"
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	config.vm.define :master do |master|
		master.vm.box = "centos65-x86_64-20131205.box"
		master.vm.provider "virtualbox" do |v|
		  v.name = "hadoop-yarn"
		  v.customize ["modifyvm", :id, "--memory", "1536"]
		end
		master.vm.network :public_network, ip: "10.211.55.101"
		master.vm.hostname = "hadoop-yarn"
		master.vm.provision :shell, :path=> 'setup.sh'
		master.vm.network "forwarded_port", guest: 50070, host: 50070
		master.vm.network "forwarded_port", guest: 50075, host: 50075
		master.vm.network "forwarded_port", guest: 8088, host: 8088
		master.vm.network "forwarded_port", guest: 8042, host: 8042
		master.vm.network "forwarded_port", guest: 19888, host: 19888
		master.vm.network "forwarded_port", guest: 4040, host: 4040
	end
end