#!/usr/bin/perl
use strict;
my $fa = $ARGV[0];#each contrast cds.fasta
my $out = "transfer.".$fa;
open(FA, "$fa") or die "$!";
open(OUT, ">$out") or die "$!";
while(my $line = <FA>){
	chomp($line);
	if($line =~ /^>(\S+)/){
		my $id = $1;
		print OUT ">$id\n"
	}else{
		$line =~ s/[a|A]/E/ig; $line =~ s/[t|T]/F/ig; $line =~ s/[c|C]/P/ig; $line =~ s/[g|G]/Q/ig;
		$line =~ s/E/T/ig; $line =~ s/F/A/ig; $line =~ s/P/G/ig; $line =~ s/Q/C/ig;	
		print OUT "$line\n";
	}
}
close FA;