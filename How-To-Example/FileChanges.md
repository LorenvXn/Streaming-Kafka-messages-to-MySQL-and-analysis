After running the configuration file:

1) .bashrc file will contain lines:

```
##adding path for flume, kafka and java conf in .bashrc
export FLUME_HOME=/usr/local/flume
export FLUME_CONF_DIR=$FLUME_HOME/conf
export FLUME_CLASSPATH=$FLUME_CONF_DIR
export PATH=$PATH:$FLUME_HOME/bin
export CLASSPATH=
export KAFKA_HOME=/opt/kafka_2.10-0.8.2.1 
export JAVA_HOME=/usr/lib/jvm/java-8-oracle

```
2) the new Flume conf file will look as below:

```
root@tron:/home/tron/KafkaFlume# more $FLUME_HOME/conf/kafkanet1.conf 

agent.sources=kafkaSrc
agent.channels=channel1
agent.sinks=jdbcSink
agent.channels.channel1.type=org.apache.flume.channel.kafka.KafkaChannel
agent.channels.channel1.brokerList=localhost:9092
agent.channels.channel1.topic=channel1
agent.channels.channel1.zookeeperConnect=localhost:2181
agent.channels.channel1.capacity=10000
agent.channels.channel1.transactionCapacity=1000
agent.sources.kafkaSrc.type = org.apache.flume.source.kafka.KafkaSource
agent.sources.kafkaSrc.channels = kafka-mysql
agent.sources.kafkaSrc.zookeeperConnect = localhost:2181
agent.sources.kafkaSrc.topic = kafka-mysql
agent.sinks.jdbcSink.type = com.stratio.ingestion.sink.jdbc.JDBCSink
agent.sinks.jdbcSink.connectionString = jdbc:mysql://127.0.0.1:3306/KafkaDBA1
agent.sinks.jdbcSink.username=root
agent.sinks.jdbcSink.password=<some password here>
agent.sinks.jdbcSink.batchSize = 10
agent.sinks.jdbcSink.channel =channel1
agent.sinks.jdbcSink.sqlDialect=MYSQL
agent.sinks.jdbcSink.driver=com.mysql.jdbc.Driver
agent.sinks.jdbcSink.sql=load data local infile /var/lib/mysql-files/output.txt' into table kafkanet1 fields terminated by '\t\t' lines terminated by '\n' 
```
3) The  KafkaProducer.pl script


```
root@tron:/home/tron/KafkaFlume# more KafkaProducer.pl 
#!/usr/bin/perl 

     use warnings;

    use Scalar::Util qw(
        blessed
    );
    use Try::Tiny;

    use Kafka::Connection;
    use Kafka::Producer;

        my $command = `echo -ne '\n\n'`;

     my ( $connection, $producer );

        $connection = Kafka::Connection->new( host => 'localhost' );

        $producer = Kafka::Producer->new( Connection => $connection );


        # Sending a series of messages
        my $response = $producer->send(

            'kafka-mysql',

            0,                  # partition

            [                   # send command as message -forces mysql table to update with new lines
                $command
            ]
        );
undef $producer;
$connection->close;
undef $connection; 

```
