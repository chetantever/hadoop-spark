#!/bin/bash
export JAVA_HOME=/usr/local/java
export HADOOP_HOME=/usr/local/
export HADOOP_PREFIX=/usr/local/hadoop
export SPARK_HOME=/usr/local/spark

HADOOP_ARCHIVE=/vagrant/softwares/hadoop-2.7.2.tar.gz
JAVA_ARCHIVE=/vagrant/softwares/jdk-8u91-linux-x64.tar.gz
SPARK_ARCHIVE=/vagrant/softwares/spark-2.0.0-preview-bin-hadoop2.7.tgz
	
function fileExists {
	FILE=/vagrant/resources/$1
	if [ -e $FILE ]
	then
		return 0
	else
		return 1
	fi
}

function disableFirewall {
	echo "disabling firewall"
	service iptables save
	service iptables stop
	chkconfig iptables off
}

function installLocalJava {
	echo "installing oracle jdk"
	FILE=$JAVA_ARCHIVE
	tar -xvzf $FILE -C /usr/local
}

function installRemoteJava {
	echo "install open jdk"
	yum install -y java-1.7.0-openjdk.x86_64
}

function installLocalHadoop {
	echo "install hadoop from local file"
	FILE=$HADOOP_ARCHIVE
	tar -xvzf $FILE -C /usr/local
}

function installRemoteHadoop {
	echo "install hadoop from remote file"
	#curl -o /home/vagrant/hadoop-2.7.2.tar.gz -O -L $HADOOP_MIRROR_DOWNLOAD
	tar -xzf /vagrant/softwares/hadoop-2.7.2.tar.gz -C /usr/local
}

function setupJava {
	echo "setting up java"
	ln -s /usr/local/jdk1.8.0_91 /usr/local/java
}

function setupHadoop {
	echo "creating hadoop directories"
	mkdir /tmp/hadoop-namenode
	mkdir /tmp/hadoop-logs
	mkdir /tmp/hadoop-datanode
	ln -s /usr/local/hadoop-2.7.2 /usr/local/hadoop
	echo "copying over hadoop configuration files"
	cp -f /vagrant/resources/core-site.xml /usr/local/hadoop/etc/hadoop
	cp -f /vagrant/resources/hdfs-site.xml /usr/local/hadoop/etc/hadoop
	cp -f /vagrant/resources/mapred-site.xml /usr/local/hadoop/etc/hadoop
	cp -f /vagrant/resources/yarn-site.xml /usr/local/hadoop/etc/hadoop
	cp -f /vagrant/resources/slaves /usr/local/hadoop/etc/hadoop
	cp -f /vagrant/resources/hadoop-env.sh /usr/local/hadoop/etc/hadoop
	cp -f /vagrant/resources/yarn-env.sh /usr/local/hadoop/etc/hadoop
	cp -f /vagrant/resources/yarn-daemon.sh /usr/local/hadoop/sbin
	cp -f /vagrant/resources/mr-jobhistory-daemon.sh /usr/local/hadoop/sbin
	echo "modifying permissions on local file system"
	chown -fR vagrant /tmp/hadoop-namenode
    chown -fR vagrant /tmp/hadoop-logs
    chown -fR vagrant /tmp/hadoop-datanode
	mkdir /usr/local/hadoop-2.7.2/logs
	chown -fR vagrant /usr/local/hadoop-2.7.2/logs
}

function setupEnvVars {
	echo "creating java environment variables"
	#if fileExists $JAVA_ARCHIVE; then
	#	echo export JAVA_HOME=/usr/local/jdk1.7.0_51 >> /etc/profile.d/java.sh
	#else
	#	echo export JAVA_HOME=/usr/lib/jvm/jre >> /etc/profile.d/java.sh
	#fi
	echo export JAVA_HOME=/usr/local/java >> /etc/profile.d/java.sh
	echo export PATH=\${JAVA_HOME}/bin:\${PATH} >> /etc/profile.d/java.sh
	
	echo "creating hadoop environment variables"
	cp -f /vagrant/resources/hadoop.sh /etc/profile.d/hadoop.sh
}

function setupHadoopService {
	echo "setting up hadoop service"
	cp -f /vagrant/resources/hadoop /etc/init.d/hadoop
	chmod 777 /etc/init.d/hadoop
	chkconfig --level 2345 hadoop on
}

function setupNameNode {
	echo "setting up namenode"
	/usr/local/hadoop-2.7.2/bin/hdfs namenode -format myhadoop
}

function startHadoopService {
	echo "starting hadoop service"
	service hadoop start
}

function installHadoop {
	installLocalHadoop
}

function installJava {
	installLocalJava
}

function initHdfsTempDir {
	$HADOOP_PREFIX/bin/hdfs --config $HADOOP_PREFIX/etc/hadoop dfs -mkdir /tmp
	$HADOOP_PREFIX/bin/hdfs --config $HADOOP_PREFIX/etc/hadoop dfs -chmod -R 777 /tmp
}

function installSpark {
	echo "install spark from local file"
	FILE=$SPARK_ARCHIVE
	tar -xvzf $FILE -C /usr/local
	ln -s /usr/local/spark-2.0.0-preview-bin-hadoop2.7 /usr/local/spark
}

function setupSpark {
	echo "setup spark"
	cp -f /vagrant/resources/slaves /usr/local/spark/conf
}

function setupSparkEnvVars {
	echo "creating spark environment variables"
	echo export SPARK_HOME=/usr/local/spark >> /etc/profile.d/spark.sh
	echo export PATH=\${SPARK_HOME}/bin:\${SPARK_HOME}/sbin:\${PATH} >> /etc/profile.d/spark.sh
	chown -fR vagrant /tmp/*
	chown -fR vagrant $SPARK_HOME/*
}


function startSpark {
	$SPARK_HOME/sbin/start-all.sh
}

disableFirewall
installJava
installHadoop
setupJava
setupHadoop
setupEnvVars
setupNameNode
setupHadoopService
startHadoopService
initHdfsTempDir
installSpark
setupSpark
setupSparkEnvVars
startSpark