sub main {
	my %unique_import_id;
	while (<>) {
		my $ls = $_;
		next if ($ls =~ /^SCHEMA AWAIT/);
		next if ($ls =~ /^(CREATE|DROP) +CONSTRAINT/);
		next if ($ls =~ /^MATCH .+ REMOVE .+/);

		# Basic change
		$ls =~ s/(`|")/'/g;
		$ls =~ s/^\s*BEGIN\s*$/BEGIN;/;
		$ls =~ s/^\s*COMMIT\s*$/COMMIT;/;

		if ($ls =~ /CREATE \(:'(\S+)':'UNIQUE IMPORT LABEL' \{(.+), 'UNIQUE IMPORT ID':(\d+)\}\);/) {
			my $vlabel = $1;
			my $keyval = $2;
			my $id = $3;
			$unique_import_id{$id} = $vlabel . "\t" . $keyval;
			$ls =~ s/CREATE \(:'(\S+)':'UNIQUE IMPORT LABEL' \{/CREATE (:$1 {/;
			$ls =~ s/, 'UNIQUE IMPORT ID':\d+\}/\}/;
		}
		if ($ls =~ /^MATCH \(n1:'UNIQUE IMPORT LABEL'(\{'UNIQUE IMPORT ID':\d+\})\), +\(n2:'UNIQUE IMPORT LABEL'(\{'UNIQUE IMPORT ID':\d+\})\)/) {
			my $n1 = $1;
			my $n2 = $2;
			$ls =~ s/'UNIQUE IMPORT LABEL'//g;
			$ls =~ s/\[r:'(\S+)'\]/[r:$1]/;
			if ($n1 =~ /(\d+)/) {
				my $id = $unique_import_id{$1};
				$id =~ s/\t/ {/;
				$id .= '}';
				$ls =~ s/$n1/$id/;
			}
			if ($n2 =~ /(\d+)/) {
				my $id = $unique_import_id{$1};
				$id =~ s/\t/{/;
				$id .= '}';
				$ls =~ s/$n2/$id/;
			}
		}
		$ls =~ s/\s*$//;
		printf("%s\n", $ls);
	}
}

main();

