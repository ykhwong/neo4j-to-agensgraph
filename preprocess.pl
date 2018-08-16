sub main {
	my %unique_import_id;
	while (<>) {
		my $ls = $_;
		next if ($ls =~ /^SCHEMA +AWAIT/i);
		next if ($ls =~ /^(CREATE|DROP) +CONSTRAINT .+UNIQUE +IMPORT/i);
		next if ($ls =~ /^MATCH .+ REMOVE .+/i);

		# Basic change
		$ls =~ s/'/''/g;
		$ls =~ s/\\"([\},])/\\\\'$1/g;
		$ls =~ s/([^\\])(`|")/$1'/g;
		$ls =~ s/\\"/"$1/g;
		$ls =~ s/^\s*BEGIN\s*$/BEGIN;/i;
		$ls =~ s/^\s*COMMIT\s*$/COMMIT;/i;

		if ($ls =~ /CREATE +\(:'(\S+)':'UNIQUE +IMPORT +LABEL' +\{(.+), 'UNIQUE +IMPORT +ID':(\d+)\}\);/i) {
			my $vlabel = $1;
			my $keyval = $2;
			my $id = $3;
			$unique_import_id{$id} = $vlabel . "\t" . $keyval;
			$ls =~ s/CREATE +\(:'(\S+)':'UNIQUE +IMPORT +LABEL' +\{/CREATE (:$1 {/i;
			$ls =~ s/, +'UNIQUE +IMPORT +ID':\d+\}/\}/i;
		}
		if ($ls =~ /^MATCH +\(n1:'UNIQUE +IMPORT +LABEL'(\{'UNIQUE +IMPORT +ID':\d+\})\), +\(n2:'UNIQUE +IMPORT +LABEL'(\{'UNIQUE +IMPORT +ID':\d+\})\)/i) {
			my $n1 = $1;
			my $n2 = $2;
			$ls =~ s/'UNIQUE +IMPORT +LABEL'//ig;
			$ls =~ s/\[r:'(\S+)'\]/[r:$1]/i;
			$ls =~ s/\[:'(\S+)'\]/[:$1]/i;
			if ($n1 =~ /(\d+)/) {
				my $id = $unique_import_id{$1};
				$id =~ s/\t/ {/;
				$id .= '}';
				$ls =~ s/$n1/$id/i;
			}
			if ($n2 =~ /(\d+)/) {
				my $id = $unique_import_id{$1};
				$id =~ s/\t/{/;
				$id .= '}';
				$ls =~ s/$n2/$id/i;
			}
		}
		if ($ls =~ /^CREATE +\(:'(\S+)'/i) {
			$ls =~ s/^CREATE +\(:'(\S+)'/CREATE +(:$1/i;
		}
		if ($ls =~ /^CREATE +INDEX +ON +:/i) {
			$ls =~ s/^CREATE +INDEX +ON +:/CREATE PROPERTY INDEX ON /i;
			$ls =~ s/'//g;
		}
		if ($ls =~ /^CREATE +CONSTRAINT +ON +\(\S+:'(\S+)'\) +ASSERT +\S+\.'(\S+)'/i) {
			$ls =~ s/^CREATE +CONSTRAINT +ON +\(\S+:'(\S+)'\) +ASSERT +\S+\.'(\S+)'/CREATE CONSTRAINT ON $1 ASSERT $2/i;
		}
		if ($ls =~ /^MATCH +\(n1:'(\S+)'/i) {
			$ls =~ s/^MATCH +\(n1:'(\S+)'\s*\{/MATCH (n1:$1 {/i;
			$ls =~ s/ +\(n2:'(\S+)'\s*\{/ (n2:$1 {/i;
			$ls =~ s/\[:'(\S+)'\]/[:$1]/i;
		}

		$ls =~ s/\s*$//;
		printf("%s\n", $ls);
	}
}

main();

