#!/usr/bin/perl -w
use strict;

# Generate a gff3 file that has all the differences between the annotations
# for human and chimpanzee.
findDifAndCount("chimp", "chimp.gff3", "human.gff3", "dif.gff3");
findDifAndCount("human", "human.gff3", "chimp.gff3", "dif.gff3");


#===================================================================>Subroutines
sub findDifAndCount {
	my $org = shift; 	# query organism name
	my $file1 = shift; 	# query organism file
	my $file2 = shift; 	# target organism file
	my $file3 = shift; 	# annotation difference file
	
	my $geneCount = 0;
	my $tranCount = 0;
	
	open( INPUT1, "<$file1" ) or die "Can't open file: $file1\n";
	open( INPUT2, "<$file2" ) or die "Can't open file: $file2\n";
	open( my $fh, '>>', "$file3");
	while (my $data = <INPUT1>) {
		
		my @fields = split ("\t", $data);
		my @attributes = split (";", $fields[$#fields]);
		my $ID = "";
		if ($attributes[0] =~ /gene/) {
			$ID = "$attributes[0]";
			$geneCount++;
		}
		elsif ($attributes[0] =~ /gene/) {
			$ID = "$attributes[0]";
			$tranCount++;
		}
		
		# Look to see if the ID is found in the other organism. If the ID is
		# not found in the other organism. Add the gene to a file that records
		# all the difference between the annotations of the 2 organisms.
		my $found = 0;
		while (my $line = <INPUT2>) {
			my @fields = split ("\t", $data);
			my @attributes = split (";", $fields[$#fields]);
			if ($attributes[0] eq $ID) {
				$found = 1;
				last;
			}
		}
		
		if ($found = 0) {
			print {$fh} $data."\t".$org; # print the line and the organism that the line came from
		}
	}
	
	return ($geneCount, $tranCount);
}
