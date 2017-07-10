# Streaming Kafka messages to MySQL and data preparation for machine learning
(...what a title - just checking how to make CSV with the help of Big Data, MySQL &Perl, l3l!, )

```
|-----------------|		|--------------|
|		  |		|	       |
| Kafka producer  |------------>| Kafka Topic  |
| 		  |		|	       |
|-----------------|		|-------|------|
					|	
			|---------------|
			|		
			|		
			|	|---------------|		    
			|	|		|		              		
			|------>|     Flume	|-                                     	
				|(Kafka  source)|		   			        
				|----|----------|		  
				     |
		         |-----------|
			 |				|-------------------|
                         |				|		    |
         		 |----------------------------->|   Flume channel   |	
							|-------------------|
								|
								|
		                                    |-----------|						
						    |
						    |------------------->|---------|
									 | MySQL   |---> export csv
									 |---------|


```


Small example on filtered network packets. 
For obtaining the text file that should be sent in mysql (...and from there converted to .csv), check this part of the project: https://github.com/Satanette/Streaming-Kafka-messages-to-MySQL-and-analysis/tree/master/capture_packets



Kafka, Flume, Zookeeper and Java should be already installed - make sure that Zookeeper is running before continuing. 
Make sure Jook is installed as well (you can find it in jars folder)

Run script db_and_flumeconf.pl, for: 
a) updating bashrc file 
b) creating database and tablespace for Kafka messages 
c) create Kafka Producer Perl script

More details at How-To-Example folder:
https://github.com/Satanette/Streaming-Kafka-messages-to-MySQL-and-analysis/tree/master/How-To-Example 


Memo to self: Why not making this easier? I don't care - it seemed like phun!  ...it can be made bigger &better, tho! 
