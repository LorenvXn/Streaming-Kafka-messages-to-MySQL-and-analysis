
1) Kafka, Flume, Zookeeper and Java already installed - make sure that Zookeeper is running before continuing

2) The required Kafka Topics are already created

3) Run script db_and_flumeconf.pl, for:
a) updating bashrc file
b) creating  database and tablespace for Kafka messages
c) create Kafka Producer 


3) Start Kafka Broker


4) Run script Set Up Environment/run_flume.pl to start Flume Service

```
###########################
#  ./bashrc configuration  
###########################


Insert FLUME_HOME:/usr/local/flume
insert KAFKA_HOME: /opt/kafka_2.10-0.8.2.1
insert JAVA_HOME :/usr/lib/jvm/java-8-oracle

###########################################
#  Kafka DB & table configuration          
###########################################
Database creation 
insert new name of database: KafkaDBA1
Create Table for Kafka Messages...
insert new name of kafka table: kafkanet1
Succesfully Created Kafka Messages Database and Table 
##############################################
# Create new conf file for flume & appenders         
##############################################
create conf file: kafkanet1.conf            

my kafka topic: kafka-mysql

my kafka source: kafkaSrc

my Kafka channel: channel1

jdbc :jdbcSink

agent sinks username mysql: root

agent sinks password mysql: <some passwd here>

write path & file to send:  /var/lib/mysql-files/final_output.txt

###########################################################
#Create Kafka Producer Perl script under current directory 
###########################################################

###########################################################
#               Configuration completed                    
###########################################################


```


6) Run script Set Up Environment/KafkaProducer.pl (which has been created at point 3), at every 2 seconds:

```
watch -n2 ./KafkaProducer.pl
``` 

7) Check if tablespace is populated! (be warned - there'd be duplicates!)

```
root@tron:/home/tron/KafkaFlume# mysql -u root -p -e "select * from KafkaDBA1.kafkanet1;"
Enter password: 
+---------------------+------+------------------+------------+------------------+-----------------+------+--------+
| Datez               | IP   | SourceIP         | SourcePort | DestinationIP    | DestinationPort | TCP  | Length |
+---------------------+------+------------------+------------+------------------+-----------------+------+--------+
| 2017-05-27 19:21:18 | IP   |  172.261.0.12    | 28061      |  216.58.207.78   |             443 | tcp  | 46     |
| 2017-05-27 19:21:18 | IP   |  216.58.207.78   | 443        |  172.261.0.12    |           28061 | tcp  | 0      |
| 2017-05-27 19:21:18 | IP   |  216.58.207.78   | 443        |  172.261.0.12    |           28061 | tcp  | 46     |
| 2017-05-27 19:21:18 | IP   |  172.261.0.12    | 28061      |  216.58.207.78   |             443 | tcp  | 0      |
| 2017-05-27 19:21:19 | IP   |  172.261.0.12    | 28061      |  216.58.207.78   |             443 | tcp  | 242    |
| 2017-05-27 19:21:19 | IP   |  172.261.0.12    | 28061      |  216.58.207.78   |             443 | tcp  | 732    |
| 2017-05-27 19:21:19 | IP   |  172.261.0.12    | 28061      |  216.58.207.78   |             443 | tcp  | 1368   |
| 2017-05-27 19:21:19 | IP   |  172.261.0.12    | 28061      |  216.58.207.78   |             443 | tcp  | 1368   |
| 2017-05-27 19:21:19 | IP   |  172.261.0.12    | 28061      |  216.58.207.78   |             443 | tcp  | 1368   |
| 2017-05-27 19:21:19 | IP   |  172.261.0.12    | 28061      |  216.58.207.78   |             443 | tcp  | 802    |
| 2017-05-27 19:21:19 | IP   |  216.58.207.78   | 443        |  172.261.0.12    |           28061 | tcp  | 0      |


```
 
Now that our text file is sent into mysql, it is time to convert it to .csv 


//the manual way...ugh...

Extract distinct lines and send them into a .csv:
```
mysql> SHOW VARIABLES LIKE "secure_file_priv";
+------------------+-----------------------+
| Variable_name    | Value                 |
+------------------+-----------------------+
| secure_file_priv | /var/lib/mysql-files/ |
+------------------+-----------------------+
1 row in set (0,01 sec)

mysql> \! ls /var/lib/mysql-files/
mysql> 
mysql>
mysql>select distinct * from KafkaDBA1.kafkanet1 into outfile '/var/lib/mysql-files/packetz.csv' fields terminated by ',' lines terminated by '\n';
mysql> \! head -5 /var/lib/mysql-files/packetz.csv
2017-05-27 19:21:18,IP, 172.261.0.12 ,28061, 216.58.207.78 ,443,tcp,46
2017-05-27 19:21:18,IP, 216.58.207.78 ,443, 172.261.0.12 ,28061,tcp,0
2017-05-27 19:21:18,IP, 216.58.207.78 ,443, 172.261.0.12 ,28061,tcp,46
2017-05-27 19:21:18,IP, 172.261.0.12 ,28061, 216.58.207.78 ,443,tcp,0
2017-05-27 19:21:19,IP, 172.261.0.12 ,28061, 216.58.207.78 ,443,tcp,242

```

//the perl way... the important snip! 

```
 use DBI;
 $dbh = DBI->connect('dbi:mysql:KafkaDBA1','','')
   or die "Connection Error: $DBI::errstr\n";
 $sth = $dbh->prepare("select distinct * from kafkanet1 ;" );

 $sth->execute
   or die "SQL Error: $DBI::errstr\n";
my $ref;

open(FH, "> /home/tron/overtherainbow.csv");

 while ($ref = $sth->fetchrow_arrayref) {
   print FH join (",", @{$ref}), "\n";
 }
```

All files configuration changes can be seen here: 
https://github.com/Satanette/Streaming-Kafka-messages-to-MySQL-and-analysis/blob/master/How-To-Example/FileChanges.md 
