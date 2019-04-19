# [Apache Hadoop](http://hadoop.apache.org/) ![hadoop](https://hadoop.apache.org/hadoop-logo.jpg)

## Hadoop Cluster Setup

### deployment of hadoop cluster
|hostnmae |ip            |install packages      |running processes                                 |
|---------|--------------|----------------------|--------------------------------------------------| 
|m1.cnt.io|192.168.88.121|jdk, hadoop           |NameNode, DFSZKFailoverController(zkfc)           |
|m2.cnt.io|192.168.88.122|jdk, hadoop           |NameNode, DFSZKFailoverController(zkfc)           |
|r1.cnt.io|192.168.88.123|jdk, hadoop           |ResourceManager                                   |
|r2.cnt.io|192.168.88.124|jdk, hadoop           |ResourceManager                                   |
|z1.cnt.io|192.168.88.125|jdk, hadoop, zookeeper|DataNode, NodeManager, JournalNode, QuorumPeerMain|
|z2.cnt.io|192.168.88.126|jdk, hadoop, zookeeper|DataNode, NodeManager, JournalNode, QuorumPeerMain|
|z3.cnt.io|192.168.88.127|jdk, hadoop, zookeeper|DataNode, NodeManager, JournalNode, QuorumPeerMain|

**1. install zookeeper cluster(first operate in z1.cnt.io)**
* wget https://apache.org/dist/zookeeper/stable/zookeeper-3.4.14.tar.gz 
* mkdir /usr/local/cnt
* tar xvf zookeeper-3.4.14.tar.gz -C /usr/local/cnt/
* cd /usr/local/cnt/zookeeper-3.4.14/conf
* cp zoo_sample.cfg zoo.cfg
* vim zoo.cfg
```
dataDir=/usr/local/cnt/zookeeper-3.4.14/data
server.1=z1.cnt.io:2888:3888
server.2=z2.cnt.io:2888:3888
server.3=z3.cnt.io:2888:3888
```
* mkdir /usr/local/cnt/zookeeper-3.4.14/data
* echo 1 > /usr/local/cnt/zookeeper-3.4.14/data/myid
* vim /etc/profile
```
export JAVA_HOME=/usr/local/java/jdk1.8.0_172
export HADOOP_HOME=/usr/local/cnt/hadoop-3.2.0
export ZK_HOME=/usr/local/cnt/zookeeper-3.4.14
export PATH=$ZK_HOME/bin:$HADOOP_HOME/bin:$JAVA_HOME/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```
* mkdir /usr/local/cnt(in host z2.cnt.io and z3.cnt.io)
* scp -r /usr/local/cnt/zookeeper-3.4.14 z2.cnt.io:/usr/local/cnt/
* scp -r /usr/local/cnt/zookeeper-3.4.14 z3.cnt.io:/usr/local/cnt/
* echo 2 > /usr/local/cnt/zookeeper-3.4.14/data/myid(in host z2.cnt.io)
* echo 3 > /usr/local/cnt/zookeeper-3.4.14/data/myid(in host z3.cnt.io)

**2. install hadoop cluster(first operate in m1.cnt.io)**
* wget https://www.apache.org/dyn/closer.cgi/hadoop/common/hadoop-3.2.0/hadoop-3.2.0.tar.gz
* mkdir /usr/local/cnt
* tar xvf hadoop-3.2.0.tar.gz -C /usr/local/cnt/
* vim /etc/profile
```
export JAVA_HOME=/usr/local/java/jdk1.8.0_172
export HADOOP_HOME=/usr/local/cnt/hadoop-3.2.0
export PATH=$HADOOP_HOME/bin:$JAVA_HOME/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```
* cd /usr/local/cnt/hadoop-3.2.0/etc/hadoop
* vim hadoop-env.sh
```bash
export JAVA_HOME=/usr/local/java/jdk1.8.0_172
```
* vim core-site.xml
```xml
<configuration>
  <!-- specify the nameservice of hdfs -->
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://ns1/</value>
  </property>
  <!-- specify the tmp dir of hadoop -->
  <property>
    <name>hadoop.tmp.dir</name>
    <value>/usr/local/cnt/hadoop-3.2.0/tmp</value>
  </property>
					
  <!-- specify the addresses of zookeeper cluster -->
  <property>
    <name>ha.zookeeper.quorum</name>
    <value>z1.cnt.io:2181,z2.cnt.io:2181,z3.cnt.io:2181</value>
  </property>
</configuration>
```
* vim hdfs-site.xml
```xml
<configuration>
  <!--specify the nameservice of hdfs, should be in consistence with the one in core-site.xml -->
  <property>
    <name>dfs.nameservices</name>
    <value>ns1</value>
  </property>
  <!-- two namenodes for ns1: nn1 and nn2 respectively -->
  <property>
    <name>dfs.ha.namenodes.ns1</name>
    <value>nn1,nn2</value>
  </property>
  <!-- specify the rpc conmunication address of nn1 -->
  <property>
    <name>dfs.namenode.rpc-address.ns1.nn1</name>
    <value>m1.cnt.io:9000</value>
  </property>
  <!-- specify the http conmunication address of nn1 -->
  <property>
    <name>dfs.namenode.http-address.ns1.nn1</name>
    <value>m1.cnt.io:50070</value>
  </property>
  <!-- specify the rpc conmunication address of nn2 -->
  <property>
    <name>dfs.namenode.rpc-address.ns1.nn2</name>
    <value>m2.cnt.io:9000</value>
  </property>
  <!-- specify the http conmunication address of nn2 -->
  <property>
    <name>dfs.namenode.http-address.ns1.nn2</name>
    <value>m2.cnt.io:50070</value>
  </property>
  <!-- specify the location of depositing namenode's metadata in journalnode -->
  <property>
    <name>dfs.namenode.shared.edits.dir</name>
    <value>qjournal://z1.cnt.io:8485;z2.cnt.io:8485;z3.cnt.io:8485/ns1</value>
  </property>
  <!-- specify the location of depositing data in local disk for journalnode -->
  <property>
    <name>dfs.journalnode.edits.dir</name>
    <value>/usr/local/bigdata/hadoop-2.8.1/journaldata</value>
  </property>
  <!-- enable the automatic shifting of failover for namenode -->
  <property>
    <name>dfs.ha.automatic-failover.enabled</name>
    <value>true</value>
  </property>
  <!-- specify the implementation provider of failover mechanism -->
  <property>
    <name>dfs.client.failover.proxy.provider.ns1</name>
    <value>org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider</value>
  </property>
  <!-- config methods of isolation mechanism, different methods are seperated by a line break -->
  <property>
    <name>dfs.ha.fencing.methods</name>
    <value>
      sshfence
      shell(/bin/true)
    </value>
  </property>
  <!-- specify the private key files to login with no need for password -->
  <property>
    <name>dfs.ha.fencing.ssh.private-key-files</name>
    <value>/root/.ssh/id_rsa</value>
  </property>
  <!-- config the timeout time of isolation mechanism for sshfence -->
  <property>
    <name>dfs.ha.fencing.ssh.connect-timeout</name>
    <value>30000</value>
  </property>
</configuration>
```
* vim mapred-site.xml
```xml
<configuration>
  <!-- specify the framework of allocating and scheduling resource -->
  <property>
    <name>mapreduce.framework.name</name>
    <value>yarn</value>
  </property>
</configuration>
```
* vim yarn-site.xml
```xml
<configuration>
  <!-- enable high available for resourcemanager -->
  <property>
    <name>yarn.resourcemanager.ha.enabled</name>
    <value>true</value>
  </property>
  <!-- specify the cluster id for resourcemanager -->
  <property>
    <name>yarn.resourcemanager.cluster-id</name>
    <value>yrc</value>
  </property>
  <!-- specify the names resourcemanager -->
  <property>
    <name>yarn.resourcemanager.ha.rm-ids</name>
    <value>rm1,rm2</value>
  </property>
  <!-- specify the addresses for resourcemanager respectively -->
  <property>
    <name>yarn.resourcemanager.hostname.rm1</name>
    <value>r1.cnt.io</value>
  </property>
  <property>
    <name>yarn.resourcemanager.hostname.rm2</name>
    <value>r2.cnt.io</value>
  </property>
  <!-- specify the addresses for zookeeper cluster -->
  <property>
    <name>yarn.resourcemanager.zk-address</name>
    <value>z1.cnt.io:2181,z2.cnt.io:2181,z3.cnt.io:2181</value>
  </property>
  <property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
  </property>
</configuration>
```
* vim slaves
```
z1.cnt.io
z2.cnt.io
z3.cnt.io
```
* ssh-keygen(in host m1.cnt.io)
> ssh-copy-id m1.cnt.io  
ssh-copy-id m2.cnt.io  
ssh-copy-id r1.cnt.io  
ssh-copy-id r2.cnt.io  
ssh-copy-id z1.cnt.io  
ssh-copy-id z2.cnt.io  
ssh-copy-id z3.cnt.io
* ssh-keygen(in host m2.cnt.io)
> ssh-copy-id m1.cnt.io
* ssh-keygen(in host r1.cnt.io)
> ssh-copy-id r2.cnt.io  
ssh-copy-id z1.cnt.io  
ssh-copy-id z2.cnt.io  
ssh-copy-id z3.cnt.io
* copy configed hadoop to other nodes(in host m1.cnt.io)
> scp -r /usr/local/cnt/hadoop-3.2.0 m2.cnt.io:/usr/local/cnt/  
scp -r /usr/local/cnt/hadoop-3.2.0 r1.cnt.io:/usr/local/cnt/  
scp -r /usr/local/cnt/hadoop-3.2.0 r2.cnt.io:/usr/local/cnt/  
scp -r /usr/local/cnt/hadoop-3.2.0 z1.cnt.io:/usr/local/cnt/  
scp -r /usr/local/cnt/hadoop-3.2.0 z2.cnt.io:/usr/local/cnt/  
scp -r /usr/local/cnt/hadoop-3.2.0 z3.cnt.io:/usr/local/cnt/

**3. startup cluster**
* zkServer.sh start(in hosts z1.cnt.io, z2.cnt.io, z3.cnt.io)
* zkServer.sh status
* cd /usr/local/cnt/hadoop-3.2.0
* sbin/hadoop-daemon.sh start journalnode

* hdfs namenode -format(in host m1.cnt.io)
* scp -r /usr/local/cnt/hadoop-3.2.0/tmp m2.cnt.io:/usr/local/cnt/hadoop-3.2.0(or hdfs namenode -bootstrapStandby)
* hdfs zkfc -formatZK
* sbin/start-dfs.sh
* sbin/start-yarn.sh

* access http://m1.cnt.io:50070
