#!/usr/bin/perl
use strict;
print "1. you need mkdir an new work directory \"\$main\" as your main work place!\n";
print "2. you need prepare the genome file at this main directory!\n";
print "3. you need mkdir \"scripts\" file, and prepare the scripts into this directory!\n\n\n";
## before this step, you need check the genome chro_ids using the first perl script: \$main\/scripts\/1-cheak_chromosome_infor.pl, and then change it into proper name; 
## and check the size of chromosome, then split it into proper size for the following blast program

# split chromosomes;
my $main = "/DATA_DISK/yuanjq/works/run_blast";## you need change this path into your work path

opendir(IND, "$main") or die "$!";
my @infiles = grep(/\.genome.fasta$/, readdir(IND));# correct based on your own file name
close IND;

my $outtop = "split_species";
unless(-e "$outtop"){system("mkdir -p $outtop");}

#=pod 
foreach my $fas (@infiles){
	open(INF, "$main/$fas") or die "$!";
	my $id; my %hash;
	while(my $line = <INF>){
		chomp($line);
		if($line =~ m/^>(\S+)\s+/){
			$id = $1;
			$hash{$id} = "";
			print "From: Ori_id:$id\n";
		}else{
			$hash{$id} .= $line;
		}
	}
	close INF;
	print "Finish the source\n\n";
	
	my $outdir = $fas.".Chrs";
	unless(-e $outdir){system("mkdir -p $outtop/$outdir");}
	
	my @sort = sort(keys %hash);
	my $chr;
	foreach my $each (@sort){
		my $ori_num = $each; $ori_num =~ s/^\D+//; $ori_num =~ s/^0+//;# absolute chro number for judge
		print "Ori_num:$ori_num\t";
		# change into the actual chromosome num based on true chromosomes
		my $act_num;
		if($ori_num<= 8){#change this part based on your own data
			$act_num=$ori_num+9;
		}elsif(($ori_num>8) and ($ori_num<=17)){
			$act_num=$ori_num-8;
		}else{$act_num=$ori_num;}
		#
		my $chr = $act_num; 
		if($act_num<18){#cause if it is more than two digitals, we cannot standard it into two digitals
			$chr = sprintf("%02d", $chr);# standard chro number for print
		}
		#
		my $out; my $new_id;
		my $len = length($hash{$each}); my $scale = 2.5*1000*1000*1000; my $unit = 2*1000*1000*1000;# if the chro more 2.5GB, split with 2GB as unit
		print "Actual_num:$act_num\tChro_num:$chr\tLength:$len\tScale:4GB\t";
		
		if($len >= $scale){## chromosome length more than ##GB, blast or blast+ counld not bulid the datebase, split with 2GB as the unit
			#$hash{$each} =~ s/[\n|\r]//g;
			my $seq_len = length($hash{$each});

			my $r = 0; my $start; my $end; my $new_line; my $new_len;
			for (my $i=0;$i<$seq_len;$i+=$unit){## rounds
				$r++;
				$start = $i;
				#$end = $i+$unit;
				if($end >= $seq_len){$end=$seq_len;}
				$new_line = substr($hash{$each}, $start, $unit);
				$new_len = length($new_line);
				print "New_len:$new_len\t";
				
				$new_id = "PAN.Chr".$chr."-".$r;
				$out = $new_id.".fasta";
				print "New_id:$new_id\t";
				
				open(OUT, ">$outtop/$outdir/$out") or die "$!";
				print OUT ">$new_id\n$new_line";
				close OUT;
				print "New_id:$new_id\tOri_id:$each\t";
			}
			print "\n\n";
		}else{
			if($act_num >= 18){# scaffolds
				$out = "PAN.Scaffold";
				$new_id = $out."$chr";
				$out = $out.".fasta";
				open(OUT, ">>$outtop/$outdir/$out") or die "$!";# this part about the scaffold you need delete the former run results for adding edit: ">>"
				print OUT ">$new_id\n$hash{$each}";
				close OUT;
			}else{
				$out = "PAN.Chr".$chr;
				$new_id = $out;
				$out = $out.".fasta";
				open(OUT, ">$outtop/$outdir/$out") or die "$!";
				print OUT ">$new_id\n$hash{$each}";
				close OUT;
			}# chromosomes
			print "New_id:$new_id\tOri_id:$each\n\n";
		}
	}
}
print "\nthe split finnished\n\n";
sleep(10);
#=cut

#=pod
## run formatdb && blastall
my $query = "$main/query.fasta";
opendir(SPDIR, "$main/$outtop") or "$!";
my @sp_genomes = grep(/\.fasta\.Chrs$/, readdir(SPDIR));
close SPDIR;

foreach my $sp (@sp_genomes){
	opendir(SP, "$main/$outtop/$sp") or die "$!";
	my @chros = grep(/\.fasta$/, readdir(SP));
	close SP;
	
	my $evalue = 1e-5;
	foreach my $fa (@chros){
		my $db = $fa; 
		#$db =~ s/\.fasta$//; 
		my $out = "$db.m8";
		open(PARA, ">>$main/2-ParaFly.blast.txt") or die "$!";
		#system("cd "$main/$outtop/$sp" && makeblastdb -in $main/$outtop/$sp/$fa -dbtype nucl -parse_seqids -out $main/$outtop/$sp/$db -max_file_sz 4GB && blastn -query $query -out $main/$outtop/$sp/$out -db $db -evalue $evalue -outfmt 6 -num_threads 8\n");
		#print PARA "cd $main/$outtop/$sp && makeblastdb -in $main/$outtop/$sp/$fa -dbtype nucl -parse_seqids -out $main/$outtop/$sp/$db -max_file_sz 4GB && blastn -query $query -out $main/$outtop/$sp/$out -db $db -evalue $evalue -outfmt 6 -num_threads 8\n"
		#close PARA;
		
		#system("cd "$main/$outtop/$sp" && makeblastdb -in $fa -dbtype nucl -parse_seqids -out $db -max_file_sz 4GB && blastn -query $query -out $out -db $db -evalue $evalue -outfmt 6 -num_threads 8\n");
		#print PARA "cd $main/$outtop/$sp && makeblastdb -in $fa -dbtype nucl -parse_seqids -out $db -max_file_sz 4GB && blastn -query $query -out $out -db $db -evalue $evalue -outfmt 6 -num_threads 8\n";
		print PARA "cd $main/$outtop/$sp && formatdb -i $fa -p F && blastall -p blastn -e $evalue -i $query -d $db -o $out -m 8 -b 200000 -v 200000 \n";
		close PARA;
	}
}
sleep(5);

chdir $main;
system("ParaFly -c $main/2-ParaFly.blast.txt -CPU 64");
print "all done!\n";
#=cut