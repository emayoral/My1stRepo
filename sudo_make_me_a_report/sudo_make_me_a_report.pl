#!/usr/bin/perl
use strict;
#use Data::Dumper;
use MIME::Lite;
use POSIX;

system('/usr/lib/hobbit/server/bin/bb 127.0.0.1 "hobbitdboard test=^3par-space  fields=hostname,msg" > 3par-space.txt') == 0  or die $!; 

open CSV, ">", "your_report.csv" or die $!;


open FILE, "<", "3par-space.txt" or die $!;


print CSV "'3PAR','','','','','','','','','','',''\n";
print CSV "'','','','','','','','','','','',''\n";
print CSV "'HostName','Type','Total','Used','Unavailable','Free','Pct Used','','','','',''\n";
my $countstr;
$countstr = "'','','','','','','','','','','',''\n";
$countstr .= "'3PAR disk counts','','','','','','','','','','',''\n";
$countstr .= "'','','','','','','','','','','',''\n";
$countstr .= "'HostName','Type','Size','Count','','','','','','','',''\n";

while (<FILE>) 
	{ 
	my $line= $_;
	my @linearray = split('\|', $line);
	my $hostname= $linearray[0];
	my $msg =  $linearray[1];
	my $msgline;
	#print "Hostname: $hostname\n";
	#print "Message: $msg\n";
	my @msglines = split(/\\n/, $msg);
	
	my %totals;
	my %counts;
	
	foreach  $msgline (@msglines)
		{
		#print "$msgline\n";
		if ($msgline =~ /(NL|FC) \(GB\): Total: (\d+) Used: (\d+) Unavailable: (\d+) Free: (\d+) Pct Used: (\d+)%/)
			{
			my $type = $1;
			$totals{$type}{'total'} = $2;
			$totals{$type}{'used'} = $3;
			$totals{$type}{'unavailable'} = $4;
			$totals{$type}{'free'} = $5;
			$totals{$type}{'usedpct'} = $6;
			#print 	$type , $totals{$type}{'total'} ,$totals{$type}{'used'} ,$totals{$type}{'used'} ,$totals{$type}{'unavailable'} ,	$totals{$type}{'free'} = $5,	$totals{$type}{'usedpct'} = $6;
			}
		if ($msgline =~ /\d+ \d+:\d+:\d+\s+(NL|FC)\s+[a-z]+\s+(\d+)\s+.*/)
			{
			my $type = $1;
			my $size = $2 ;
			if (exists $counts{$type}{$size})
				{
				$counts{$type}{$size} += 1;
				}
			else
				{
				$counts{$type}{$size} = 1;
				}
	
			}
		}
	#print Dumper(\%totals);
	#print Dumper(\%counts);
	my $key;
	foreach $key (sort(keys %totals)) 
		{
		print CSV "'$hostname','$key','$totals{$key}{'total'}','$totals{$key}{'used'}','$totals{$key}{'unavailable'}','$totals{$key}{'free'}','$totals{$key}{'usedpct'}','','','','',''\n";
		}

	foreach $key (sort(keys %counts)) 
		{
		my $key2;
		foreach $key2 (sort(keys %{$counts{$key}}))
			{
			$countstr .= "'$hostname','$key','$key2','$counts{$key}{$key2}','','','','','','','',''\n";
			}
		}
	
	}
print CSV $countstr;
	
close FILE;

system('/usr/lib/hobbit/server/bin/bb 127.0.0.1 "hobbitdboard test=^na_aggr_space  fields=hostname,msg" > na_aggr_space.txt') == 0 or die $!;


open FILE, "<", "na_aggr_space.txt" or die $!;

print CSV "'','','','','','','','','','','',''\n";
print CSV "'Netapp aggregates','','','','','','','','','','',''\n";
print CSV "'','','','','','','','','','','',''\n";
print CSV "'HostName','Aggregate','Util','Size','Used','Free','Snap','A-Sis','Metadata','VolSize','VolAlloc','VolUsed'\n";

while (<FILE>) 
	{ 
	my $line= $_;
	my @linearray = split('\|', $line);
	my $hostname= $linearray[0];
	my $msg =  $linearray[1];
	my $msgline;
	#print "Hostname: $hostname\n";
	#print "Message: $msg\n";
	my @msglines = split(/\\n/, $msg);
	my %totals;
	foreach  $msgline (@msglines)
		{
		#print "$msgline\n";
		                                  #Util(%)       Size       Used       Free       Snap      A-Sis   MetaData    VolSize   VolAlloc    VolUsed
		if ($msgline =~ /(\w+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/)
			{
			my $aggr=$1;
			$totals{$aggr}{'util'} = $2;
			$totals{$aggr}{'size'} = $3;
			$totals{$aggr}{'used'} = $4;
			$totals{$aggr}{'free'} = $5;
			$totals{$aggr}{'snap'} = $6;
			$totals{$aggr}{'a-sis'} = $7;
			$totals{$aggr}{'metadata'} = $8;
			$totals{$aggr}{'volsize'} = $9;
			$totals{$aggr}{'volalloc'} = $10;
			$totals{$aggr}{'volused'} = $11;
			}
		}
	#print Dumper(\%totals);	

	my $key;
	foreach $key (sort(keys %totals)) 
		{
		print CSV "'$hostname','$key','$totals{$key}{'util'}','$totals{$key}{'size'}','$totals{$key}{'used'}','$totals{$key}{'free'}','$totals{$key}{'snap'}','$totals{$key}{'a-sis'}','$totals{$key}{'metadata'}','$totals{$key}{'volsize'}','$totals{$key}{'volalloc'}','$totals{$key}{'volused'}'\n";
		}
	}
	
close FILE;


system('/usr/lib/hobbit/server/bin/bb 127.0.0.1 "hobbitdboard test=^na_vol_space  fields=hostname,msg" > na_vol_space.txt') == 0 or die $!;

open FILE, "<", "na_vol_space.txt" or die $!;

print CSV "'','','','','','','','','','','',''\n";
print CSV "'Netapp volumes','','','','','','','','','','',''\n";
print CSV "'','','','','','','','','','','',''\n";
print CSV "'HostName','Volume','Util','Size','Used','Free','Snap','A-Sis','Metadata','VolSize','VolAlloc','VolUsed'\n";

while (<FILE>) 
	{ 
	my $line= $_;
	my @linearray = split('\|', $line);
	my $hostname= $linearray[0];
	my $msg =  $linearray[1];
	my $msgline;
	#print "Hostname: $hostname\n";
	#print "Message: $msg\n";
	my @msglines = split(/\\n/, $msg);
	my %totals;
	foreach  $msgline (@msglines)
		{
		#print "$msgline\n";
		#Volume                       Status       Aggr    Reserve    Util(%)   Inode(%)   Size(GB)   Used(GB)   Free(GB)      DEDUP   Saved(%)  Saved(GB)        Schedule
		#&green aqua                      online      aggr3       none         77          0       2500       1915        584        N/A          0          0             N/A
		if ($msgline =~ /&\w+\s+(\w+)\s+\w+\s+(\w+)\s+(\w+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+.*/)
			{
			my $vol=$1;
			$totals{$vol}{'aggr'} = $2;
			$totals{$vol}{'reserve'} = $3;
			$totals{$vol}{'utilpct'} = $4;
			$totals{$vol}{'inodepct'} = $5;
			$totals{$vol}{'size'} = $6;
			$totals{$vol}{'used'} = $7;
			$totals{$vol}{'free'} = $8;
			}
		
		}
	#print Dumper(\%totals);	
	my $key;
	foreach $key (sort(keys %totals)) 
		{
		print CSV "'$hostname','$key','$totals{$key}{'aggr'}','$totals{$key}{'reserve'}','$totals{$key}{'utilpct'}','$totals{$key}{'inodepct'}','$totals{$key}{'size'}','$totals{$key}{'used'}','$totals{$key}{'free'}','','',''\n";
		}

	}
	
close FILE;
close CSV;



my $msg = MIME::Lite->new(
    From    => 'sudo_make_me_a_report@arsys.es',
    To      => 'xxx@example.com',
    Cc      => 'yyy@example.com',
    Subject => 'Informe de almacenamiento',
    Type    => 'multipart/mixed',
);

$msg->attach(
    Type     => 'TEXT',
    Data     => "Informe de almacenamiento de ". strftime('%F %T', localtime()) ,
);

$msg->attach(
    Type     => 'text/csv',
    Path     => 'your_report.csv',
    Filename => 'almacenamiento.csv',
);

$msg->send;
