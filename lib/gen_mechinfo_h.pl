#!/usr/bin/env perl

# Copyright (c) 2018 Mastercard

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#   http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

use warnings;

my @lines;

for $file(@ARGV) {
    open (FILE, $file) or die;
    while(<FILE>) {
	chomp;
	if( /^#define CKM_([[:word:]]+)[[:space:]]+(0x[[:xdigit:]]+)/ ) {
	    # $1 contains the attribute name,
	    # $2 contains the hex code
	    # $3 contains the original line
	    # $4 contains the originating file name
	    push @lines, [${1}, ${2}, $_, $file ]
	}
    }
    close FILE;
}

# uniquify array

my %seen;
my @uniq;

foreach $item (@lines) {
    push(@uniq, $item) unless $seen{$item->[1] }++;
}

# sort. The key for CKM is the hex code.

my @sorted = sort { $a->[1] cmp $b->[1] } @uniq;

#print Dumper(@sorted);

for $line(@sorted) {
    print "#if !defined(CKM_$line->[0])\n"; 
    print " $line->[2]\n";
    print " /* from $line->[3] */\n";
    print "#endif /* CKM_$line->[0] */\n";
    print "\n";
}

for $line(@sorted) {
    print "{ CKM_$line->[0], \"CKM_$line->[0]\" }, /* from $line->[3] */\n"; 
}


