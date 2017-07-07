#!/usr/bin/perl -w

###############################################################################################################
# this script will create database &table for Kafka messages to be received
# Based on your keyboard input, for more automation, a KafkaProducer.pl script will be created in current dir
############################
##################
# usage: perl db_and_flumeconf.pl <mysql user> <mysql passwd>
# example: /db_and_flumeconf.pl root r4tzy\!\!\*
##############

use File::Path;
use File::chdir;
use DBI;

$mysqlUSER=ARGV[0];
$mysqlPasswd=ARGV[1];

print "Database creation " . "\n";


print "insert new name of database: ";

$kafkadb = <STDIN>;
chomp($kafkadb);

my $dbh = DBI->connect('dbi:mysql:', "$mysqlUSER", "$mysqlPasswd");

if($dbh->do("create database $kafkadb")){

        print "databases created";
}else{
        print "could not create it";
}

print "Create Table for Kafka Messages..." . "\n";


 $dbh = DBI->connect('dbi:mysql:$kafkadb','$mysqlUSER','$mysqlPasswd')
   or die "Connection Error: $DBI::errstr\n";

print "insert new name of kafka table: ";
$kafkaTable=<STDIN>;
chomp($kafkaTable);

$dbh->do("CREATE TABLE $kafkaTable (Datez timestamp, IP VARCHAR(30), SourceIP varchar(30), SourcePort varchar(30), DestinationIP varchar(30), DestinationPort varchar(30), TCP varchar(30), Length int(11));");
    $dbh->disconnect;

print "Succesfully Created Kafka Messages Database and Table " . "\n";

print "Open Flume conf directory: ";
my $directory = <STDIN> ;
chomp($directory);


print "create conf file" ;
$confFile = <STDIN>;
chomp($confFile);


print "my kafka topic: " ;
$topic_name = <STDIN>;
chomp($topic_name);

print "my kafka source: " ;
$kafkasource = <STDIN>;
chomp($kafkasource);


print "my Kafka channel: " ;
$kafkachannel = <STDIN>;
chomp($kafkachannel);

print "agent sinks username mysql: ";
$username = <STDIN>;
chomp($username);

print "agent sinks password mysql: ";
$passwd = <STDIN>;
chomp($passwd);

print "jdbc :" ;
$jdbcSink = <STDIN>;
chomp($jdbcSink);


print "write path & file to send: ";
$file2send = <STDIN>;
chomp($file2send);

open my $FH, ">" , "$directory/$confFile";
print $FH "
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
agent.sinks.$jdbcSink.sql=load data local infile \'$file2send\' into table $kafkaTable fields terminated by \'\\t\\t\' lines terminated by \'\\n\'
" . "\n";
close $FH;

print "\n";

print "Create Kafka Producer Perl script under current directory " . "\n";

open my $FH, ">" , "./KafkaProducer.pl";
print $FH "

\#!usr/bin/perl

use strict;
use scalar;

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
undef \$connection;
";
close $FH;


print "Configuration  Completed..." . "\n";



