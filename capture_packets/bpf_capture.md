
<b>Packets capture and filtering</b>

Create a simple filter, bpf1.txt, that allows only IPv4 TCP packets

```
         ldh [12]
         jne #0x800, drop
         ldb [23]
         jneq #6, drop
         ret #-1
         drop: ret #0
```
Compile it:

```
bpfc -i bpf1.txt > ethernet1.bpfc
```
Now, use netsniff-ng tool to create a pcap capture:
```
netsniff-ng --in <some interface> --out capture.pcap --filter ethernet1.bpfc
```

Send all output in a file, with the help of tcpdump:

```
tcpdump -qns 0 -X -r capture.pcap > output.txt
```

Use script capture_packets.sh to process data, to be sent in a MySQL database.
https://github.com/Satanette/Streaming-Kafka-messages-to-MySQL-and-analysis/blob/master/capture_packets/capture_packets.sh 

From an output looking like this:

```
19:21:18.094852 IP 172.58.207.78.443 > 172.161.0.12.28061: tcp 0
	0x0000:  4500 0034 ed1e 0000 3906 2c68 d83a cf4e  E..4....9.,h.:.N
	0x0010:  c0a8 000c 01bb 6d9d afbe feb3 b30a a18c  ......m.........
	0x0020:  8010 0656 fc89 0000 0101 080a 392f 9991  ...V........9/..
	0x0030:  0018 c664                                ...d
```

It should be looking like this:
```
 2017/05/2 19:21:18.094852 		IP		 172.58.207.78      443		 172.161.0.12 		28061		tcp		0

```
