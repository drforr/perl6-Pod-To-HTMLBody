use v6;
use Test;
use Pod::To::BlogspotHTML;

my $pod-counter = 0;
my $html;

# includes tests for fixes for RT bugs:
#   124403 - incorrect table parse:
#   128221 - internal error
#   129862 - uneven rows
#   132341 - pad rows to add empty cells to ensure all rows have same number of cells
#   132348 - handle inline Z<> comments on table rows

# test fix for RT #124403 - incorrect table parse:
=table
+-----+----+---+
|   a | b  | c |
+-----+----+---+
| foo | 52 | Y |
| bar | 17 | N |
|  dz | 9  | Y |
+-----+----+---+

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

# Check out the raw pod if you don't believe me, this is a set of single
# rows.
#
like $html, /
	'<table>'
		'<tr>' '<td>' '+-----+----+---+' '</td>' '</tr>'
		'<tr>' '<td>' '| a | b | c |'    '</td>' '</tr>'
		'<tr>' '<td>' '+-----+----+---+' '</td>' '</tr>'
		'<tr>' '<td>' '| foo | 52 | Y |' '</td>' '</tr>'
		'<tr>' '<td>' '| bar | 17 | N |' '</td>' '</tr>'
		'<tr>' '<td>' '| dz | 9 | Y |'   '</td>' '</tr>'
		'<tr>' '<td>' '+-----+----+---+' '</td>' '</tr>'
	'</table>'
/, 'single rows';

#`( XXX This bug has moved to NQP.
# test fix for RT #128221
#       This test, with a '-r0c0' entry in
#       the single table row, column 0,
#       caused an exception.
=begin table
-r0c0  r0c1
=end table

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
die $html;

like $html, /
1
/;
)

#`( XXX And this breaks with P6Opaque.
# an expanded test (per Zoffix) for issue #128221
# note expected results have been corrected from that time
=begin table
-Col 1 | -Col 2 | _Col 3 | =Col 4
=======+========+========+=======
r0Col 1  | -r0Col 2 | _r0Col 3 | =r0Col 4
-------|--------|--------|-------
r1Col 1  | -r1Col 2 | _r1Col 3 | =r1Col 4
r1       |  r1Col 2 | _r1Col 3 | =r1Col 4
-------|--------|--------|-------
r2Col  1 | r2Col 2  |  r2Col 3 |  r2Col 4
=end table

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
die $html;

like $html, /
1
/;
)

# test fix for issue RT #129862
# uneven rows
=begin table
a | b | c
l | m | n
x | y
=end table

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<table>'
		'<tr>'
			'<td>' 'a' '</td>'
			'<td>' 'b' '</td>'
			'<td>' 'c' '</td>'
		'</tr>'
		'<tr>'
			'<td>' 'l' '</td>'
			'<td>' 'm' '</td>'
			'<td>' 'n' '</td>'
		'</tr>'
		'<tr>'
			'<td>' 'x' '</td>'
			'<td>' 'y' '</td>'
		'</tr>'
	'</table>'
/, 'short row';

# test fix for RT #132341
# also tests fix for RT #129862
=table
    X   O
   ===========
        X   O
   ===========
            X

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<table>'
		'<tr>'
			'<td>' 'X' '</td>'
			'<td>' 'O' '</td>'
		'</tr>'
		'<tr>'
			'<td>' '</td>'
			'<td>' 'X' '</td>'
			'<td>' 'O' '</td>'
		'</tr>'
		'<tr>'
			'<td>' '</td>'
			'<td>' '</td>'
			'<td>' 'X' '</td>'
		'</tr>'
	'</table>'
/, 'RT #132341 regression';

#`( # XXX Pod::TreeWalker may be suppressing Z<> comments.
# test fix for RT #132348 (allow inline Z comments)
# also tests fix for RT #129862
=begin table
a | b | c
l | m | n
x | y      Z<a comment> Z<another comment>
=end table

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
die $html;

like $html, /
1
/;
)

# a single column table, no headers
=begin table
a
=end table

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<table>'
		'<tr>'
			'<td>' 'a' '</td>'
		'</tr>'
	'</table>'
/, 'single-cell table';

# a single column table, with header
=begin table
b
-
a
=end table

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<table>'
		'<th>'
			'<td>' 'b' '</td>'
		'</th>'
		'<tr>'
			'<td>' 'a' '</td>'
		'</tr>'
	'</table>'
/, 'table with header';

# test fix for rakudo repo issue #1282:
# need to handle table cells with char column separators as data
# example table from <https://docs.perl6.org/language/regexes>
# WITHOUT the escaped characters (results in an extra, unwanted, incorrect column)
=begin table

    Operator  |  Meaning
    ==========+=========
     +        |  set union
     |        |  set union
     &        |  set intersection
     -        |  set difference (first minus second)
     ^        |  symmetric set intersection / XOR

=end table

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

#`( XXX '&' needs to be escaped, among others probably.
like $html, /
	'<table>'
		'<th>'
			'<td>' 'Operator' '</td>'
			'<td>' 'Meaning' '</td>'
		'</th>'
		'<tr>'
			'<td>' '+' '</td>'
			'<td>' 'set union' '</td>'
		'</tr>'
		'<tr>'
			'<td>' '</td>'
			'<td>' '</td>'
			'<td>' 'set union' '</td>'
		'</tr>'
		'<tr>'
			'<td>' '&' '</td>'
			'<td>' 'set intersection' '</td>'
		'</tr>'
		'<tr>'
			'<td>' '-' '</td>'
			'<td>' 'set difference (first minus second)' '</td>'
		'</tr>'
		'<tr>'
			'<td>' '^' '</td>'
			'<td>' 'symmetric set intersection / XOR' '</td>'
		'</tr>'
	'</table>'
/, 'Table with header and gaps';
)

# WITHOUT the escaped characters and without the non-breaking spaces
# (results in the desired table)
=begin table

    Operator  |  Meaning
    ==========+=========
    +       |  set union
    |       |  set union
    &       |  set intersection
    -       |  set difference (first minus second)
    ^       |  symmetric set intersection / XOR

=end table

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<table>'
		'<th>'
			'<td>' 'Operator' '</td>'
			'<td>' 'Meaning' '</td>'
		'</th>'
		'<tr>'
			'<td>' '+ &' '</td>'
			'<td>' 'set union set intersection' '</td>'
			'<td>' 'set union' '</td>'
		'</tr>'
		'<tr>'
			'<td>' '^' '</td>'
			'<td>' 'symmetric set intersection / XOR' '</td>'
		'</tr>'
	'</table>'
/, 'escaped characters';

# WITH the escaped characters (results in the desired table)
=begin table

    Operator  |  Meaning
    ==========+=========
     \+        |  set union
     \|        |  set union
     &        |  set intersection
     -        |  set difference (first minus second)
     ^        |  symmetric set intersection / XOR

=end table

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<table>'
		'<th>'
			'<td>' 'Operator' '</td>'
			'<td>' 'Meaning' '</td>'
		'</th>'
		'<tr>'
			'<td>' '\\+' '</td>'
			'<td>' 'set union' '</td>'
		'</tr>'
		'<tr>'
			'<td>' '\\|' '</td>'
			'<td>' 'set union' '</td>'
		'</tr>'
		'<tr>'
			'<td>' '&' '</td>'
			'<td>' 'set intersection' '</td>'
		'</tr>'
		'<tr>'
			'<td>' '-' '</td>'
			'<td>' 'set difference (first minus second)' '</td>'
		'</tr>'
		'<tr>'
			'<td>' '^' '</td>'
			'<td>' 'symmetric set intersection / XOR' '</td>'
		'</tr>'
	'</table>'
/, 'escaped, and some non-breaking spaces';

# WITH the escaped characters but without the non-breaking spaces
# (results in the desired table)

=begin table

    Operator  |  Meaning
    ==========+=========
    \+       |  set union
    \|       |  set union
    &       |  set intersection
    -       |  set difference (first minus second)
    ^       |  symmetric set intersection / XOR

=end table

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<table>'
		'<th>'
			'<td>' 'Operator' '</td>'
			'<td>' 'Meaning' '</td>'
		'</th>'
		'<tr>'
			'<td>' '\\+ \\| &' '</td>'
			'<td>' 'set union set union set intersection' '</td>'
		'</tr>'
		'<tr>'
			'<td>' '^' '</td>'
			'<td>' 'symmetric set intersection / XOR' '</td>'
		'</tr>'
	'</table>'
/, 'escaped, no non-breaking spaces';

done-testing;

# vim: ft=perl6
