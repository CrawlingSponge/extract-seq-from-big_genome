#!/usr/bin/perl
use strict;

my $main= "/DATA_DISK/yuanjq/works/run_blast";
opendir(FADIR, "$main") or die "$!";
my @fasdir = grep(/\.genome\.fasta$/, readdir(FADIR));
close FADIR;

foreach my $file (@fasdir){
	print "$file\n";
	my $out = $file.".id_infor.txt";
	system(`grep ">" $main/$file >$main/$out`);# few minitus
}