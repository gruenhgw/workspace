#!/usr/bin/perl -w
use strict;
use DBI;
use CGI;

# open a file to print error messages in
open( my $fh, '>', "error.txt");
print {$fh} "hello\n";

# setup database connection variables
my $user = "gruenhgw";
my $password = "bio466";
my $host = "localhost";
my $driver = "mysql";

# connect to database
print {$fh} "connecting to server\n";
my $dsn = "DBI:$driver:database=gruenhgw;host=$host";
my $dbh = DBI->connect($dsn, $user, $password);
print {$fh} "connected to server\n";

# setup CGI handle
my $cgi = new CGI;

print {$fh} "using cgi->param()\n";
my @params = $cgi->param();
print {$fh} "Reached Line 28\n";

# Initialize variables
my ($sql, $sql2, $species) = ("", "", "");
my (@values, @rows, @rows2, $field, $rowsref);

# Get the values for each parameter passed to the program
foreach my $param (@params) {
	push @values, $cgi->param($param);
	print {$fh} "$param = ".$cgi->param($param)."\n";
}

# Determine the query field (i.e. ID or Name)
if (substr($values[1], 0, 3) eq "ENS" ) {
	$field = "$values[0]"."ID";
}
else {
	$field = "Name";
}
print {$fh} "$field\n";

# start HTML
print $cgi->header;
print $cgi->start_html('Results');
print {$fh} "HTML has been started\n";

# Create sql statements by selecting the correct tables
my $table = $values[0]; # organism still needs to be specified
if ($values[2] eq "Human") {
	$sql = "select * from gruenhgw.human".$table." where $field = '".$values[1]."'";
	$species = "Human\n";
}
else {
	if ($values[2] eq "Both") {
		$sql2 = "select * from gruenhgw.human".$table." where $field = '".$values[1]."'";
		$species = "Both";
	}
	$sql = "select * from gruenhgw.chimp".$table." where $field = '".$values[1]."'";
}
print {$fh} "created sql statements\n";

# Get a list of all the rows
print {$fh} $sql."\t".$values[1]."\n";
$rowsref = $dbh->selectall_arrayref($sql) || die $dbh->errstr;
@rows = @{$rowsref};
print {$fh} "created rows\n";

# If both tables were desired to be searched in, get the rows from both tables
if ($sql2 ne "") {
	print {$fh} $sql2."\t".$values[1]."\n";
	my $rowsref = $dbh->selectall_arrayref($sql2) || die $dbh->errstr;
	push @rows2, @{$rowsref};
	
	print {$fh} "created rows for both\n";
}

# Print the results
print "<h1>Results</h1>";
if ($values[2] eq "Both") 	{	print "<h3>Chimp $table"."s</h3></br>";				}
else 						{	print "<h3>".$values[2]." ".$table."s</h3></br>";	}
if ($#rows>=0) {
  	print "<table border=1 cellspacing=0 cellpadding=3><tr>";
  
	if ($table eq "Transcript")	{	
		print 	"<th>TranscriptID</th><th>Name</th><th>Biotype</th><th>ParentGene</th>".
				"<th>Chromosome</th><th>Start</th><th>End</th><th>Strand</th></tr>";
	}
	else {
		print 	"<th>TranscriptID</th><th>Name</th><th>Biotype</th>".
		"<th>Chromosome</th><th>Start</th><th>End</th><th>Strand</th></tr>";
	}
  
  	print {$fh} "Results found";
  
  	for (my $i=0; $i<=$#rows; $i++) {
    	my @row=@{$rows[$i]};
    	print "<tr>";
    	for (my $j=0; $j<=$#row; $j++) {
     		print "<td>$row[$j]</td>";
    	}
    	print "</tr>";
  	}
 	print "</table>\n";
}
else {
  print "<i>No matches found</i>\n";
  print {$fh} "No matches found\n";
}

# Only if both species databases should be queried
if ($values[2] eq "Both") {
	print "<h3>Human $table"."s </h3></br>";
	
	if ($#rows2>=0) {
	  print "<table border=1 cellspacing=0 cellpadding=3><tr>";
	  if ($table eq "Transcript")	{	
	  	print 	"<th>TranscriptID</th><th>Name</th><th>Biotype</th><th>ParentGene</th>".
	  			"<th>Chromosome</th><th>Start</th><th>End</th><th>Strand</th></tr>";
	  }
	  else {
	  	print 	"<th>TranscriptID</th><th>Name</th><th>Biotype</th>".
	  			"<th>Chromosome</th><th>Start</th><th>End</th><th>Strand</th></tr>";
	  }
	                
	  print {$fh} "Results found";
	  
	  for (my $i=0; $i<=$#rows2; $i++) {
	    my @row=@{$rows2[$i]};
	    print "<tr>";
	    for (my $j=0; $j<=$#row; $j++) {
	     print "<td>$row[$j]</td>";
	    }
	    print "</tr>";
	  }
	  print "</table>\n";
	}
	else {
	  print "<i>No matches found</i>\n";
	  print {$fh} "No matches found\n";
	}
	
}
print <<MERFORM;
	<!-- CSS -->	
	<style type="text/css">
	html, 
	body {
		height: 100%;
	}

	body {
		background-image: url(background_color5.png);
		background-repeat: no-repeat;
		background-size: cover;
    	background-attachment: fixed;
	}
	</style>
	<h1>Search</h1>
    <form action="search_db.pl" method="GET">
    Query (ID or Name):  	<select name="type">
							<option>Gene</option>
							<option>Transcript</option>
							</select>
							<input type="text" name="query" /><br />
    Annotations to Search: 	<select name="table">
							<option>Both</option>
							<option>Human</option>
							<option>Chimp</option>
							</select><br />
    <input type="submit" name="submit" value="Submit" />
    </form>
MERFORM
print $cgi->end_html();
$dbh->disconnect();

