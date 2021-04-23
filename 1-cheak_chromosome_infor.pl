#!/usr/bin/perl
use strict;

my $main= "./";
my $cut_genome = "cut_genome_2g";
opendir(FADIR, "$main/$cut_genome_2g") or die "$!";
my @fasdir = grep(/\.genome\.fasta$/, readdir(FADIR));
close FADIR;

foreach my $file (@fasdir){
	print "$file\n";
	my $out = $file.".id_infor.txt";
	system(`grep ">" $main/$file >$main/$out`);# few minitus
}