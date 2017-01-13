#!/usr/bin/perl
use strict;
use warnings;

my $cutoff = 70;

#my @trees = glob("families/RAxML_bipartitions.*");
my @trees = glob("families.wgd-test/RAxML_bipartitions.*");

my $count = 0;
my $total = 0;
foreach my $tree (@trees) {
	$total++;

	my $tree_txt;
	my %translate;
	my $in_translate;

	open(my $tree_file, "<", $tree);
	chomp($tree_txt = <$tree_file>);
	close($tree_file);

	# (cotton_0:0.06999656494744935231,(cotton_1:0.10527302054577349077,dig_1:0.04711637131397500289)100:0.03520700899877695494,dig_0:0.04611529662240381605);
	$tree_txt =~ s/:\d+(\.\d+)?//g;
	print $tree_txt,"\n";

	my $counted = 0;
	#while ($tree_txt =~ /\(dig_\d,cotton_\d\)/g || $tree_txt =~ /\(cotton_\d,dig_\d\)/g) {
	#while ($tree_txt =~ /\(dig_\d,cotton_\d\)(\d+)/g) {
	#while ($tree_txt =~ /\(dombeya_\d,dombeya_\d\)(\d+)/g) {
	while ($tree_txt =~ /\(firmiana.evigene_\d,dombeya.evigene_\d\)(\d+)/g) {
		my $support = $1;
		if ($support >= $cutoff) {
			$count++;
			$counted++;
		}
	}
	#while ($tree_txt =~ /\(cotton_\d,dig_\d\)(\d+)/g) {
	#while ($tree_txt =~ /\(dombeya_\d,dombeya_\d\)(\d+)/g) {
	while ($tree_txt =~ /\(dombeya.evigene_\d,firmiana.evigene_\d\)(\d+)/g) {
		my $support = $1;
		if ($support >= $cutoff && !$counted) {
			$count++;
		}
	}

#	while ($tree_txt =~ /(\[.*?\])/g) {
#		my $comment = $1;
#		if ($comment !~ /\[.*?percent\)="(\d+)".*?\]/) {
#			$tree_txt =~ s/\Q$comment\E//;
#		}
#	}
#
#	#$tree_txt =~ s/\[.*?\]//g;
#	#$tree_txt =~ s/\[.*?percent\)="(\d+)".*?\]/[meow]/g;
#	$tree_txt =~ s/\[.*?percent\)="(\d+)".*?\]/[$1]/g;
#	$tree_txt =~ s/(\d)\[\d+\]/$1/g;
#	$tree_txt =~ s/\[(\d+)\]/$1/g;
#
#	$tree_txt =~ s/:.*?,/,/g;
#	$tree_txt =~ s/:.*?\)/)/g;
#
#	foreach my $num (keys %translate) {
#		my $name = $translate{$num};
#		$tree_txt =~ s/\($num,/($name,/;
#		$tree_txt =~ s/\($num\(/($name(/;
#		$tree_txt =~ s/,$num,/,$name,/;
#		$tree_txt =~ s/,$num\)/,$name)/;
#	}

#	print $tree,"\n";
#	print $tree_txt,"\n";
#	#if ($tree_txt =~ /seq_semperviren.*\(seq_semperviren/ || $tree_txt =~ /seq_semperviren.*\)seq_semperviren/) {
#	#while ($tree_txt =~ /seq_semperviren(.*?)seq_semperviren/g) {
#	while ($tree_txt =~ /seq_semperviren(.*?)seq_semperviren(.*?\))/g) {
#		my $space = $1;
#		my $end = $2;
#		foreach my $num (keys %translate) {
#			my $name = $translate{$num};
#			next if ($name eq "seq_sempervirens");
#			
#			if ($space =~ /$name/) {
#				print "WOAH THERE COWBOY\n";
#				last;
#			}
#		#	if ($end =~ /\($name.*seq_semperviren/) {
#		#		print "WOAH THERE COWBOY\n";
#		#		last;
#		#	}
#		}
#		#print "WOAH THERE COWBOY\n";
#	}
	print "\n";

}

print "$count of $total\n";
