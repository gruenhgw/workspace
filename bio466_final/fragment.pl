#!/usr/bin/perl -w
# Code to break up a large text file.

## File to brek up
#print "File: ";
#$file = <>;
#chomp($file);
#open( INPUT, "<$file" ) or die "Can't open file: $file\n";
#open( my $fh, '>', "1"."$file");
#
## Lines to keep
#$keep = 10000;
#$i = 0;
#while (<INPUT>) {
#    if ($i >= $keep) {last;}
#    print {$fh} $_;
#    $i++;
#}

# Code to remove the lines that are exons or cds

# File to brek up
print "File: ";
$file = <>;
chomp($file);
open( INPUT, "<$file" ) or die "Can't open file: $file\n";
open( my $fh, '>', "2"."$file");


while (<INPUT>) {
	@tmpArray = split('\t', $_);
    if ($#tmpArray > 2 && ($tmpArray[2] =~ /gene/ || $tmpArray[2] =~ /RNA/ || $tmpArray[2] =~ /transcript/)) {
    	print {$fh} $_;
    }
}