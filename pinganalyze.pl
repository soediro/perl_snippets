#  Ping-based WAN trend analysis - perl script for
#  calculating ping response times and number of successful and unsuccessful
#  pings pr hour
#  Accepts two command line arguments :
#	-i logfile generated by "pingcollect.pl" (appended logfiles are also accepted!)
#	-o Result file in CSV-format
#  v1.0, mar99 : initial version - tevfik@itefix.no

use Getopt::Std;

getopts("i:o:") or die $!;

$LOGFILE = $opt_i;
$CSVFILE = $opt_o;

open (LOGFILE, $LOGFILE) or die $!;
open (CSVFILE, ">$CSVFILE") or die $!;

print CSVFILE "Host,Date,Time,Packet-size,Sequence,Ping-value,# success, # failure\n";

LINE: while ($line = <LOGFILE>) {

	next LINE if index ($line, "Date/time");

	# Get date-info from 1.line 
	@WorkArr = split ' ', $line;
	$Dato = @WorkArr [2];
	@WorkArrA = split /:/, @WorkArr [3];
	$Tid = @WorkArrA [0]; # Take hour-part of time
	
	$line = <LOGFILE>;
	
	# Get host-IP and packet-size from 3.line 
	$line = <LOGFILE>;
	@WorkArr = split ' ', $line;
	$HostIP = @WorkArr [1];
	$PacketSize = @WorkArr [3];
	
	$line = <LOGFILE>;

	for $i (0..1) { # analyze ping results
	
		$line = <LOGFILE>;	
		
		$key = sprintf "$HostIP,$Dato,$Tid,$PacketSize,%d",$i+1;	# Make key-value
		
		if ($line=~/Reply from.*time=([0-9]+)ms*/) { 
			$ValArr {$key} += $1;
			$CntSuccessArr {$key} += 1;
		}
		else {
			$ValArr {$key} += 0;	# to make sure that content is defined
			$CntFailureArr {$key} += 1;
		}				
	}

	$line = <LOGFILE>;
}

# Write results into output file
foreach $key (sort keys %ValArr) {
	printf CSVFILE "$key,%5.2f,%d,%d\n", ($CntSuccessArr {$key}) ? $ValArr {$key}/$CntSuccessArr {$key} : -1, $CntSuccessArr {$key}, $CntFailureArr {$key};
}

