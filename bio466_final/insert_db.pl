#!/usr/bin/perl -w
use strict;
use DBI;
#use Bio::Tools::GFF;

# File names
my $fileH = "human.gff3";
my $fileC = "chimp.gff3";

# setup database connection variables
my $user = "gruenhgw";
my $password = "bio466";
my $host = "localhost";
my $driver = "mysql";
      
# connect to database
my $dsn = "DBI:$driver:database=gruenhgw;host=$host";
my $dbh = DBI->connect($dsn, $user, $password);

print "Adding human rows...\n";
parser($fileH, "human");

print "Adding chimp rows...\n";
parser($fileC, "chimp");

print time - $^T."\n";

#===================================================================>Subroutines
sub parser {
	my $file = shift;
	my $org = shift;
	
	open( INPUT, "<$file" ) or die "Can't open file: $file\n";
	while (my $data = <INPUT>) {
		my ($ID, $name, $biotype) = ("", "", "");
		my @fields = split ("\t", $data);
		my @attributes = split (";", $fields[$#fields]);
		my $sql;
		my $offset = 0;
		
		if ($attributes[0] =~ /gene/) {
			$ID = substr($attributes[0], 8);
			
			if ($attributes[1] =~ /Name/)	{	$name = substr($attributes[1], 5);	}
			else							{	$offset++;							}
			
			if ($attributes[2-$offset] =~ /biotype/)	{	$biotype = substr($attributes[2-$offset], 8);	}
			
			my @param = ($ID, $name, $biotype, $fields[0], $fields[3], $fields[4], $fields[6]);
			
			$sql = "INSERT INTO gruenhgw.$org"."Gene (GeneID, Name, Biotype, Chromosome, Start, End, Strand) ". 
				   "values (?, ?, ?, ?, ?, ?, ?)";	   
			
#			print "gene\n";
			my $query_handle = $dbh->prepare($sql);
			$query_handle->execute(@param);
		}
		elsif ($attributes[0] =~ /transcript/) {
			$ID = substr($attributes[0], 14);
			my $parentGene = substr($attributes[1], 12);
			
			if ($attributes[2] =~ /Name/)	{	$name = substr($attributes[2], 5);	}
			else 							{	$offset++							}
			
			if ($attributes[3-$offset] =~ /biotype/)	{	$biotype = substr($attributes[3-$offset], 8);	}
			
			my @param = ($ID, $name, $biotype, $parentGene, $fields[0], $fields[3], $fields[4], $fields[6]);
			$sql = "INSERT INTO gruenhgw.$org"."Transcript (TranscriptID, Name, Biotype, ParentGene, Chromosome, Start, End, Strand) ". 
				   "values (?, ?, ?, ?, ?, ?, ?, ?)";
			
#			print "transcript\n";
			my $query_handle = $dbh->prepare($sql);
			$query_handle->execute(@param);
		}

	}
}
