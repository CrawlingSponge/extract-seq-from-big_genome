#!/usr/bin/perl
use strict;
# the whole idea is about that we choose the blast results (matched chros and the specific ranges), then cut the sequences from genomes

## follow the last step: got the blast results, then manually cheaked
## change into your own data
my $main = "/DATA_DISK/yuanjq/works/run_blast";# use your own path
my $cut_genome = "$ARGV[0]";
my $genome = "GWHANVS00000000.genome.fasta";
##

opendir(FADIR, "$main/$cut_genome/$genome.Chrs") or die "$!";
my @fas = grep(/\.fasta$/, readdir(FADIR));
close FADIR;

#=pod
# deal chro. fasta seqs (suit for the single genome, multiple genome you need slightly changed the paramaters or maybe not)
my $id; my %seqs;
foreach my $fa (@fas){
	if($fa =~ m/Scaffold/ig){next;}# this part we choose to drop this cause the results with no match with chr_scaffold, you also can "#" this based on your own situation!
	print "FASTA: $fa\n";
	open(FA, "$main/$cut_genome/$genome.Chrs/$fa") or die "$!";
	$/ = ">";
	while(my $line = <FA>){
		chomp($line);
		my @arr = split(/\n/, $line);
		my $id = shift(@arr); my $seq = join "", @arr;
		$seqs{$id} = $seq;
	}
	close FA;
	$/ = "\n";
}
print "Finished and stored the read genome (chromosomes)!\n\n";
# store the fasta
#=cut

# deal blast.results
my $new_blast = "manually.blast.gene.m8";
open(BL, "$main/$cut_genome/$new_blast") or die "$!";
my %blast;
while(my $line = <BL>){
	chomp($line);
	#print "$line\n";
	my @arr = split(/\s+/, $line);
	my $match = $arr[0]."_".$arr[1]."_".$arr[8]."_".$arr[9];
	print "BLAST: $match\n";
	$blast{$match} = 1;
}
close BL;
print "Finished and stored the read blast (chromosomes)!\n\n";
# source the blast.results

# match the last two files
open(PURC, ">$main/$cut_genome/whole.gene.selected.complete.seq.fasta") or die "$!";
open(PUR, ">$main/$cut_genome/whole.gene.selected.purpose.seq.fasta") or die "$!";
foreach my $match (sort(keys %blast)){
	print "match: $match\n";
	my @a = split(/\_/, $match); my $query = $a[0]; my $obj = $a[1]; 	
	print "query: $query \t obj: $obj\n";
	my $len = length($seqs{$obj}); print "len: $len\n";
	#$seqs{$obj} =~ s/(\w{100})/$1\n/ig;

	my $start = $a[2]-1;
	if($a[3] <= $a[2]){$start = $a[3]-1;}
	my $step = abs($a[3]-$a[2])+1;
	my $start_p = $start - 500-1; my $step_p = $step + 1000; ##cut the former or following 500bp	
	print "start: $start\tstep: $step\nstart_p: $start_p\tstep_p: $step_p\n";
	
	my $complete = substr($seqs{$obj}, $start, $step); ## select the complete (at least in blast results) matched ones
	my $purpose_seq = substr($seqs{$obj}, $start_p, $step_p); ##select the complete (at least in blast results) matched ones
	if($a[3]<$a[2]){
		$complete = reverse($complete);	$purpose_seq = reverse($purpose_seq);
	}
	print PURC ">$match\n$complete\n"; print PUR ">$match\n$purpose_seq\n";
}
close PURC; close PUR; 
print "\n***ALL DONE!***\n";