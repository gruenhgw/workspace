use Venn::Chart;

if ($#ARGV!=0) {
	die "Wrong parameter!\nUsage: perl gruenhgw_a2.pl File\n";
}
print "BLAH!";
$file=$ARGV[0];

# open the input files
open (FILE, "<$file") or die "Cannot open $file for processing!\n";
@fileLines=<FILE>;   # save the tab-delimited file into array line by line
%allgenes=();        # a hash for all expressed genes in all three groups
%group1genes=();     # a hash for all expressed genes in group 1
%group2genes=();     # a hash for all expressed genes in group 2

# process the content of FILE1
# get two group names for FILE1
($file1group1name,$file1group2name)=('','');

for ($i=0; $i<=$#fileLines; $i++) {  # skip the first line
	chomp($fileLines[$i]);
	print "($i)($fileLines[$i])\n";
	@tmpArray=split('\t',$fileLines[$i]);
	print "($tmpArray[0]) ($tmpArray[1]) ($tmpArray[2])\n";
	if ($i==0) {
		$file1group1name=substr($tmpArray[1],3,1);
		$file1group2name=substr($tmpArray[2],3,1);
		print "($file1group1name)($file1group2name)\n";
	}
	else {  
       print "==>($tmpArray[0])($tmpArray[1])($tmpArray[2])\n";
       if (! defined $allgenes{$tmpArray[0]}) {
       	    $allgenes{$tmpArray[0]}=$tmpArray[1].':'.$tmpArray[2];
       }
       else {
       	  die "Duplicate gene in the input file\n!";
       }
	}
}

foreach my $gene (keys %allgenes) {
	print "$gene ($allgenes{$gene})\n";
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