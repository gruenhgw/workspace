#!/usr/bin/perl

# import proper Perl modules and Classes
use strict;
use DBI;

# setup database connection variables
my $user = "gruenhgw";
my $password = "bio466";
my $host = 'localhost';
my $driver = "mysql";

# connect to database
my $dsn = "DBI:$driver:database=$user;host=$host";
my $dbh = DBI->connect($dsn, $user, $password);

# create a table for human genes
my $humanGene="create table humanGene (GeneID VARCHAR(100) NOT NULL, Name VARCHAR(100), Biotype VARCHAR(100), Chromosome VARCHAR(10), Start VARCHAR(100), End VARCHAR(100), Strand VARCHAR(3), PRIMARY KEY (GeneID))";
my $query_handle =$dbh->prepare($humanGene);
$query_handle->execute();

# create a table for human transcripts
my $humanTranscript="create table humanTranscript (TranscriptID VARCHAR(100) NOT NULL, Name VARCHAR(100), Biotype VARCHAR(100), ParentGene VARCHAR(100), Chromosome VARCHAR(10), Start VARCHAR(100), End VARCHAR(100), Strand VARCHAR(3), PRIMARY KEY (TranscriptID))";
$query_handle =$dbh->prepare($humanTranscript);
$query_handle->execute();

# create a table for chimp genes
my $chimpGene="create table chimpGene (GeneID VARCHAR(100) NOT NULL, Name VARCHAR(100), Biotype VARCHAR(100), Chromosome VARCHAR(10), Start VARCHAR(100), End VARCHAR(100), Strand VARCHAR(3), PRIMARY KEY (GeneID))";
$query_handle =$dbh->prepare($chimpGene);
$query_handle->execute();

# create a table for chimp transcripts
my $chimpTranscript="create table chimpTranscript (TranscriptID VARCHAR(100) NOT NULL, Name VARCHAR(100), Biotype VARCHAR(100), ParentGene VARCHAR(100), Chromosome VARCHAR(10), Start VARCHAR(100), End VARCHAR(100), Strand VARCHAR(3), PRIMARY KEY (TranscriptID))";
$query_handle =$dbh->prepare($chimpTranscript);
$query_handle->execute();