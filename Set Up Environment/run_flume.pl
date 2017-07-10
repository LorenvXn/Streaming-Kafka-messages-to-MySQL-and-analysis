#!/usr/bin/perl -w

print "insert Flume home directory: ";
$directory=<STDIN>;
chomp($directory);

print "insert Flume conf file: ";
$flumeconf=<STDIN>;
chomp($flumeconf);
system("$directory/bin/flume-ng agent -n agent -c conf -f $directory/conf/$flumeconf -Dflume.root.logger=INFO,console");
