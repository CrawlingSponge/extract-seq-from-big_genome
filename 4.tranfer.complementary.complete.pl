#!/usr/bin/perl
use strict;
my $fa = $ARGV[0];#each contrast cds.fasta
my $out = "transfer.".$fa;
open(FA, "$fa") or die "$!";
open(OUT, ">$out") or die "$!";
while(my $line = <FA>){
	chomp($line);
	if($line =~ /^>(\S+)/){
		print OUT "$id\n"
	}else{
		$line =~ s/[a|A]/T/ig;
		$line =~ s/[t|T]/A/ig;
		$line =~ s/[c|C]/C/ig;
		$line =~ s/[g|G]/G/ig;
		print OUT "$line\n";
	}
}
close FA;