#! /usr/bin/perl

use Time::Local;
use CGI qw/:all/;

$q = new CGI;

$url = url(-path_info=>1);
$url =~ s|^.*\.cgi/||;
@components = split("/", $url);

$station_id = $components[0];

@elements   = split("%2C", $components[1]);

@times      = split("%2C", $components[2]);


$first = substr($times[0], 0, 10);
$last  = substr($times[1], 0, 10);
$vars  = join(",", @elements);

print $q->header('text/xml');
printf("<mugl>\n");
printf("<data>\n");
printf("<values>\n");
$ncdcurl = "http://www.ncdc.noaa.gov/crn/xmldata2?data=$station_id:$vars&first=$first&last=$last";
open(WGET, "wget -q -O - '$ncdcurl' |");
while (<WGET>) {
    chomp;
    if (/<data/) {
	($time0) = /first="(\d+)"/;
	$time0 = YYYYMMDDHHmm_to_time($time0);
	($timestep) = /timestep="(\d+)"/;
	$timestep /= 1000.0;
    } elsif (/^\d/) {
	@fields = split(/,/);
	$YYYYMMDDHHmm = time_to_YYYYMMDDHHmm($time0 + $fields[0] * $timestep);
	@outvars = ($YYYYMMDDHHmm);
	shift(@fields);
	while (@fields) {
	    shift(@fields);
	    $val = shift(@fields);
	    if ($val eq "M") { $val = 0; }
	    $val =~ s/F//g;
	    push(@outvars, $val);
	}
	print join(",", @outvars) . "\n";
    }
}
printf("</values>\n");
printf("</data>\n");
printf("</mugl>\n");

exit;

sub YYYYMMDDHHmm_to_time {
	my $YYYYMMDDHHmm = shift;
	my $YYYY = substr($YYYYMMDDHHmm, 0, 4);
	my $MM   = substr($YYYYMMDDHHmm, 4, 2);
	my $DD   = substr($YYYYMMDDHHmm, 6, 2);
	my $HH   = substr($YYYYMMDDHHmm, 8, 2);
	my $mm   = substr($YYYYMMDDHHmm, 10, 2);
	return timegm(0,$mm,$HH,$DD,$MM-1,$YYYY-1900);
}

sub time_to_YYYYMMDDHHmm {
    my $time = shift;
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime($time);
    return sprintf("%04d%02d%02d%02d%02d",
		   $year+1900, $mon+1, $mday, $hour, $min);
}
