package GeneList;
use strict;

sub new {
	my $class = shift;
	my %args  = @_;

	my $self = bless {}, $class;

	foreach my $key ( keys %args ) {
		$self->{$key} = $args{$key};
	}
	
	## Process the file for all the gene sets and store them
	# Initialize a variables for the unique/common gene sets
	my ( $file1HashRef, $file2HashRef, %allGenes, %uniqueFile1, %uniqueFile2 ) = ();
	my $file1 = $self->{'-gene_list_one'};
	my $file2 = $self->{'-gene_list_two'};
	
	# Process the files by storing their gene expression in a hash for each gene
	$file1HashRef = _processFile($file1);
	$file2HashRef = _processFile($file2);
	my %file1Hash = %{$file1HashRef};
	my %file2Hash = %{$file2HashRef};
	
	# Find the unique/common gene sets
	foreach my $gene ( sort keys %file1Hash ) {
		if ( !defined $file2Hash{$gene} ) {
			$uniqueFile1{$gene} = $file1Hash{$gene};
		}
		else {
			$allGenes{$gene} = $file1Hash{$gene};
		}
	}
	foreach my $gene ( sort keys %file2Hash ) {
		if ( !defined $file1Hash{$gene} ) {
			$uniqueFile2{$gene} = $file2Hash{$gene};
		}
		else {
			my @tmpArray = split( '\t', $file2Hash{$gene} );
			$allGenes{$gene} .= "\t" . $tmpArray[1];
		}
	}
	
	# Store the gene sets in the class
	$self->{"-CommonList"} = \%allGenes;
	$self->{"-Unique1List"} = \%uniqueFile1;
	$self->{"-Unique2List"} = \%uniqueFile2;
	
	return $self;
}

#========================================================================Methods
sub getCommonList {
	my $self = shift;
	return $self->{"-CommonList"};
}

sub getUnique1List {
	my $self = shift;	
	return $self->{"-Unique1List"};

}

sub getUnique2List {
	my $self = shift;
	return $self->{"-Unique2List"};
}

sub _processFile {
	# Open the given file and initialize the variables
	my $tmpFile = $_[0];
	open( FILE, "<$tmpFile" ) or die "Cannot open $tmpFile for processing!\n";
	my @fileLines = grep /\S/, <FILE>;
	my %fileHash = ();

	# Split each line by tab, save the gene as a key in the hash, and save the
	# expression as the value in the hash. Except if it's the first line, then
	# save the group names.
	for ( my $i = 0 ; $i <= $#fileLines ; $i++ ) {
		chomp( $fileLines[$i] );
		my @tmpArray = split( '\t', $fileLines[$i] );
		if ( $i != 0 ) {
			if ( !defined @fileHash{ $tmpArray[0] } ) {
				$fileHash{ $tmpArray[0] } = $tmpArray[1] . "\t" . $tmpArray[2];
			}
			else {
				die "Duplicate gene in the input file, $tmpFile\n!";
			}
		}

	}

	return \%fileHash;
}
1;
