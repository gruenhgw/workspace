#!/usr/bin/perl -w
use Venn::Chart;

if ( $#ARGV != 0 ) {
	die "Wrong parameter!\nUsage: perl gruenhgw_a2.pl File\n";
}
$file = $ARGV[0];

# open the input files
open( FILE, "<$file" ) or die "Cannot open $file for processing!\n";
@fileLines = <FILE>;    # save the tab-delimited file into array line by line
%allgenes = (); # a hash for all expressed genes in all three groups (deleted expressed?)
%group1genes = ();    # a hash for all expressed genes in group 1
%group2genes = ();    # a hash for all expressed genes in group 2
%group3genes = ();    # a hash for all expressed genes in group 3
($uniqueGroup12, $uniqueGroup13, $uniqueGroup23) = (0, 0, 0);
$sharedToAll = 0;

# process the content of FILE1
# get 3 group names for FILE1
( $file1group1name, $file1group2name, $file1group3name ) = ( '', '', '' );

for ( $i = 0 ; $i <= $#fileLines ; $i++ ) {    # skip the first line
	chomp( $fileLines[$i] );

	#	print "($i)($fileLines[$i])\n";
	@tmpArray = split( '\t', $fileLines[$i] );

	#	print "($tmpArray[0]) ($tmpArray[1]) ($tmpArray[2]) ($tmpArray[3])\n";
	if ( $i == 0 ) {
		$file1group1name = substr( $tmpArray[1], 3, 1 );
		$file1group2name = substr( $tmpArray[2], 3, 1 );
		$file1group3name = substr( $tmpArray[3], 3, 1 );

		#		print "($file1group1name)($file1group2name)($file1group3name)\n";
	}
	else {
	   #		print "==>($tmpArray[0])($tmpArray[1])($tmpArray[2])($tmpArray[3])\n";
		if ( !defined $allgenes{ $tmpArray[0] } ) {
			$allgenes{ $tmpArray[0] } = $tmpArray[1] . ':' . $tmpArray[2] . ':' . $tmpArray[3];
		}
		else {
			die "Duplicate gene in the input file\n!";
		}
		if ( $tmpArray[1] != 0 ) {
			$group1genes{$gene} = $tmpArray[1];
		}
		if ( $tmpArray[2] != 0 ) {
			$group2genes{$gene} = $tmpArray[2];
		}
		if ( $tmpArray[3] != 0 ) {
			$group3genes{$gene} = $tmpArray[3];
		}
	}
}

print "[1] Individual Genes\n";
foreach my $gene ( keys %allgenes ) {
#	print "$gene ($allgenes{$gene})\n";
	( $reg12, $reg13, $reg23 ) = ( '', '', '' );
	@expression = split( ':', $allgenes{$gene} );

	# Compare Group 1 to Group 2
	if ( $expression[0] == 0 && $expression[1] == 0 ) 		{ $reg12 = "no expression"; }
	elsif ( $expression[0] == 0 && $expression[1] != 0 ) 	{ $reg12 = $file1group2name; }
	elsif ( $expression[0] != 0 && $expression[1] == 0 ) 	{ $reg12 = $file1group1name; }
	elsif ( $expression[1] / $expression[0] >= 2 )   { $reg12 = "+"; }
	elsif ( $expression[1] / $expression[0] <= 0.5 ) { $reg12 = "-"; }
	else                                             { $reg12 = "."; }

	# Compare Group 1 to Group 3
	if ( $expression[0] == 0 && $expression[2] == 0 ) 		{ $reg13 = "no expression"; }
	elsif ( $expression[0] == 0 && $expression[2] != 0 ) 	{ $reg13 = $file1group3name; }
	elsif ( $expression[0] != 0 && $expression[2] == 0 ) 	{ $reg13 = $file1group1name; }
	elsif ( $expression[2] / $expression[0] >= 2 )   { $reg13 = "+"; }
	elsif ( $expression[2] / $expression[0] <= 0.5 ) { $reg13 = "-"; }
	else                                             { $reg13 = "."; }

	# Compare Group 2 to Group 3
	if ( $expression[1] == 0 && $expression[2] == 0 ) 		{ $reg23 = "no expression"; }
	elsif ( $expression[1] == 0 && $expression[2] != 0 ) 	{ $reg23 = $file1group3name; }
	elsif ( $expression[1] != 0 && $expression[2] == 0 ) 	{ $reg23 = $file1group2name; }
	elsif ( $expression[2] / $expression[1] >= 2 )   { $reg23 = "+"; }
	elsif ( $expression[2] / $expression[1] <= 0.5 ) { $reg23 = "-"; }
	else                                             { $reg23 = "."; }
	
	print "$gene ($file1group1name vs $file1group2name: $reg12) ";
	print "($file1group1name vs $file1group3name: $reg13) ";
	print "($file1group2name vs $file1group3name: $reg23)\n";
}

print "[2] Gene set unique to a single group\n";
foreach my $gene ( keys %group1Genes ) {
	print "$gene $group1Genes{$gene}";
}
foreach my $gene ( keys %group2Genes ) {
	print "$gene $group2Genes{$gene}";
}
foreach my $gene ( keys %group3Genes ) {
	print "$gene $group3Genes{$gene}";
}

print "[3] Gene set unique to only two groups\n";
foreach my $gene ( keys %allgenes ) {
	@expression = split( ':', $allgenes{$gene} );
	if ($expression[0] != 0 && $expression[1] != 0 && $expression[2] == 0) {
		print "$gene (expresses only in both $file1group1name and $file1group2name)\n";
	}
	if ($expression[0] != 0 && $expression[1] == 0 && $expression[2] != 0) {
		print "$gene (expresses only in both $file1group1name and $file1group3name)\n";
	}
	if ($expression[0] == 0 && $expression[1] != 0 && $expression[2] != 0) {
		print "$gene (expresses only in both $file1group1name and $file1group2name)\n";
	}
}
# get three hashes for three groups, with the gene ID as the hash key and expression count as the hash value
#     make sure that gene with expressed count >0 will be considered.

# navigate each gene in the %allgenes
#     determine up-regulated, down-regulated status

# navigate each gene in %group1genes, %group2genes, %groupd3genes
#     find common genes in pair-wise comparison, you can use
#     if (defined $group1gene{$gene}) to make sure whether a gene exist(or expressed) within a group
#     if (! defined $group1gene{$gene}}) to make sure a gene does not expressed within a group

=begin
1. Read File and save to hash
2. Navigate hash

=cut
