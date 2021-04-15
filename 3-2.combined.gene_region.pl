#!/usr/bin/perl
use strict;
#use Bio::SeqIO; use Bio::Seq;
# the whole idea is about that we choose the blast results (matched chros and the specific ranges), then cut the sequences from genomes

## follow the last step: got the blast results, then manually cheaked
my $main = "/DATA_DISK/yuanjq/works/run_blast";# use your own path
my $genome = "GWHANVS00000000.genome.fasta";

## cat the blast results into one file
my $blast = "manually.blast.gene.m8";

# deal blast.results
open(BL, "$main/$blast") or die "$!";
my %blast; my %chrs;
while(my $line = <BL>){
	chomp($line);
	my @arr = split(/\s+/, $line);
	my $match = $arr[0]."_".$arr[1]."_".$arr[8]."_".$arr[9];
	print "BLAST: $match\n";
	$blast{$match} = 1; $chrs{$arr[1]} = 1;
}
close BL;
print "Finished and stored the read blast (chromosomes)!\n\n";
# source the blast.results

# read obj fasta
my $id; my %seqs;
foreach my $chr (sort(keys %chrs)){
	print "obj_fasta: $chr\n";
	open(FA, "$main/split_species/$genome.Chrs/$chr.fasta") or die "$!";
	while(my $line = <FA>){
		chomp($line);
		if($line =~ /^>(\S+)/){
			$id = $1;
		}else{$seqs{$id} .= $line;}
	}
	my $len = length($seqs{$id});
	print "len: $len\nfasta: $id\n\n";
	close FA;
}
=pod
$/ = ">"; my $id; my %seqs;
foreach my $chr (sort(keys %chrs)){
	print "obj_fasta: $chr\n";
	open(FA, "$main/split_species/$genome.Chrs/$chr.fasta") or die "$!";
	my $count = 0;
	while(my $line = <FA>){
		chomp($line); 
		$count++; next if $count==1;
		my @arr = split(/\n/, $line);
		my $id = shift(@arr); my $seq = join("\n", @arr);
		$seqs{$id} = $seq;
		my $len = length($seq);
		print "len: $len\nfasta: $id\n\n";
	}
	close FA;
}
$/ = "\n";
=cut
print "Finished and stored the read fasta (only obj)!\n\n";
# store obj fasta

# match the last two files
open(PURC, ">$main/whole.gene.selected.complete.seq.fasta") or die "$!";
open(PUR, ">$main/whole.gene.selected.purpose.seq.fasta") or die "$!";
foreach my $match (sort(keys %blast)){
	print "match: $match\n";
	my @a = split(/\_/, $match); my $query = $a[0]; my $obj = $a[1]; 	
	print "query: $query \t obj: $obj\n";
	#$seqs{$obj} =~ s/(\w{100})/$1\n/ig;
	my $start = $a[2]-1;
	if($a[3] <= $a[2]){$start = $a[3]-1;}
	my $step = abs($a[3]-$a[2])+1;
	my $start_p = $start - 500-1; my $step_p = $step + 1000; ##cut the former or following 500bp	
	print "start: $start\tstep: $step\nstart_p: $start_p\tstep_p: $step_p\n";
	
	my $complete = substr($seqs{$obj}, $start, $step); ## select the complete (at least in blast results) matched ones
	my $purpose_seq = substr($seqs{$obj}, $start_p, $step_p); ##select the complete (at least in blast results) matched ones
	if($a[3]<$a[2]){
		$complete = reverse($complete); $complete =~ s/(\w{100})/$1\n/ig;
		$purpose_seq = reverse($purpose_seq); $purpose_seq =~ s/(\w{100})/$1\n/ig;
	}
	print PURC ">$match\n$complete\n"; print PUR ">$match\n$purpose_seq\n";
}
close PURC; close PUR; 
print "\n***ALL DONE!***\n";