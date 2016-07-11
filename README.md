# hadoop-spark
A single node hadoop -  spark cluster using vagrant

Setup:
Download and copy the following under softwares folder
1. hadoop-2.7.2.tar.gz
2. jdk-8u91-linux-x64.tar.gz
3. spark-2.0.0-preview-bin-hadoop2.7.tgz

Download centos65-x86_64-20131205.box and copy to hadoop-spark root directory

Commands:
$ vagrant up - bring up the hadoop-spark cluster
$ vagrant halt - shutdown the VM
$ vagrant destroy -f