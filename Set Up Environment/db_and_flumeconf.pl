#!/usr/bin/perl -w

##################################################################################################################
# this script will update ~./bashrc && create database &table for Kafka messages to be received
# Based on your keyboard input, for more automation,
#a KafkaProducer.pl script will be created in current dir on localhost
############################
##################
# usage: perl db_and_flumeconf.pl <mysql user> <mysql passwd>
# example: ./db_and_flumeconf.pl root r4tzy\!\!\*
##############

use File::Path;
use File::chdir;
use DBI;

$user=shift;
$mysqlPasswd=shift;


print "###########################" . "\n";
print "#  ./bashrc configuration  " . "\n";
print "###########################" . "\n";

print "\n\n";

print "Insert FLUME_HOME:" ;
$flumehome = <STDIN>;
chomp($flumehome);

print "insert KAFKA_HOME: ";
$kafkahome=<STDIN>;
chomp($kafkahome);

print "insert JAVA_HOME :" ;
$javahome = <STDIN>;
chomp($javahome);

open my $FH1, ">>" , "/root/.bashrc";
print $FH1 "
\##adding path for flume, kafka and java conf in .bashrc
export FLUME_HOME=$flumehome
export FLUME_CONF_DIR=$flumehome/conf
export FLUME_CLASSPATH=\$FLUME_CONF_DIR
export PATH=\$PATH:\$FLUME_HOME/bin
export CLASSPATH=
export KAFKA_HOME=$kafkahome
export JAVA_HOME=$javahome
" . "\n";

close $FH1;


print "\n";

print "###########################################" . "\n";
print "#  Kafka DB & table configuration          " . "\n";
print "###########################################" . "\n";



print "Database creation " . "\n";


print "insert new name of database: ";

$kafkadb = <STDIN>;
chomp($kafkadb);

use DBI;
my $dbh=DBI->connect("dbi:mysql:", '$user', '$passwd');
my $sth=$dbh->prepare("create database $kafkadb");
$sth->execute();


print "Create Table for Kafka Messages..." . "\n";


 $dbh = DBI->connect('dbi:mysql:$kafkadb','$user','$passwd')
   or die "Connection Error: $DBI::errstr\n";

print "insert new name of kafka table: ";
$kafkaTable=<STDIN>;
chomp($kafkaTable);

$dbh->do("CREATE TABLE $kafkaTable (Datez timestamp, IP VARCHAR(30), SourceIP varchar(30), SourcePort varchar(30), DestinationIP varchar(30), Destinatio
nPort varchar(30), TCP varchar(30), Length int(11));");
    $dbh->disconnect;

print "Succesfully Created Kafka Messages Database and Table " . "\n";


print "##############################################" . "\n";
print "# Create new conf file for flume & appenders         " . "\n";
print "##############################################" . "\n";


print "create conf file" ;
$confFile = <STDIN>;
chomp($confFile);

print "\n";


print "my kafka topic: " ;
$topic_name = <STDIN>;
chomp($topic_name);

print "\n";

print "my kafka source: " ;
$kafkasource = <STDIN>;
chomp($kafkasource);

print "\n";

print "my Kafka channel: " ;
$kafkachannel = <STDIN>;
chomp($kafkachannel);

print "\n";

print "agent sinks username mysql: ";
$username = <STDIN>;
chomp($username);

print "\n";

print "agent sinks password mysql: ";
$passwd = <STDIN>;
chomp($passwd);

print "\n";

print "jdbc :" ;
$jdbcSink = <STDIN>;
chomp($jdbcSink);

print "\n";


print "write path & file to send: ";
$file2send = <STDIN>;
chomp($file2send);

print "\n";

open my $FH2, ">" , "$flumehome/conf/$confFile";
print $FH2 "
agent.sources=$kafkasource
agent.channels=$kafkachannel
agent.sinks=$jdbcSink
agent.channels.$kafkachannel.type=org.apache.flume.channel.kafka.KafkaChannel
agent.channels.$kafkachannel.brokerList=localhost:9092
agent.channels.$kafkachannel.topic=$kafkachannel
agent.channels.$kafkachannel.zookeeperConnect=localhost:2181
agent.channels.$kafkachannel.capacity=10000
agent.channels.$kafkachannel.transactionCapacity=1000
agent.sources.$kafkasource.type = org.apache.flume.source.kafka.KafkaSource
agent.sources.$kafkasource.channels = $topic_name
agent.sources.$kafkasource.zookeeperConnect = localhost:2181
agent.sources.$kafkasource.topic = $topic_name
agent.sinks.$jdbcSink.type = com.stratio.ingestion.sink.jdbc.JDBCSink
agent.sinks.$jdbcSink.connectionString = jdbc:mysql://127.0.0.1:3306/$kafkadb
agent.sinks.$jdbcSink.username=$username
agent.sinks.$jdbcSink.password=$passwd
agent.sinks.$jdbcSink.batchSize = 10
agent.sinks.$jdbcSink.channel =$kafkachannel
agent.sinks.$jdbcSink.sqlDialect=MYSQL
agent.sinks.$jdbcSink.driver=com.mysql.jdbc.Driver
agent.sinks.$jdbcSink.sql=load data local infile \'$file2send\' into table $kafkaTable fields terminated by \'\\t\\t\' lines terminated by \'\\n\' " ;
close $FH2;

print "\n";

print "###########################################################" . "\n";
print "#Create Kafka Producer Perl script under current directory " . "\n";
print "###########################################################" . "\n";

open my $FH3, ">" , "./KafkaProducer.pl";
print $FH3 "\#\!/usr/bin/perl 

     use warnings;

    use Scalar::Util qw(
        blessed
    );
    use Try::Tiny;

    use Kafka::Connection;
    use Kafka::Producer;

        my \$command = `echo -ne '\\n\\n'`;

     my ( \$connection, \$producer );

        \$connection = Kafka::Connection->new( host => 'localhost' );

        \$producer = Kafka::Producer->new( Connection => \$connection );


        # Sending a series of messages
        my \$response = \$producer->send(

            '$topic_name',

            0,                 \ # partition

            [                   \# send command as message -forces mysql to update with new lines
                \$command
            ]
        );
undef \$producer;
\$connection->close;
undef \$connection; " . "\n";
close $FH3;

print "\n";

print "###########################################################" . "\n";
print "#               Configuration completed                    " . "\n";
print "###########################################################" . "\n";

