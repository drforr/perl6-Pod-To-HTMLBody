use v6;
use Test;
use Pod::To::BlogspotHTML;

my $pod-counter = 0;
my $html;

=begin table
        The Shoveller   Eddie Stevens     King Arthur's singing shovel
        Blue Raja       Geoffrey Smith    Master of cutlery
        Mr Furious      Roy Orson         Ticking time bomb of fury
        The Bowler      Carol Pinnsler    Haunted bowling ball
=end table

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<table>'
		'<tr>'
			'<td>' 'The Shoveller' '</td>'
			'<td>' 'Eddie Stevens' '</td>'
			'<td>' 'King Arthur\'s singing shovel' '</td>'
		'</tr>'
		'<tr>'
			'<td>' 'Blue Raja' '</td>'
			'<td>' 'Geoffrey Smith' '</td>'
			'<td>' 'Master of cutlery' '</td>'
		'</tr>'
		'<tr>'
			'<td>' 'Mr Furious' '</td>'
			'<td>' 'Roy Orson' '</td>'
			'<td>' 'Ticking time bomb of fury' '</td>'
		'</tr>'
		'<tr>'
			'<td>' 'The Bowler' '</td>'
			'<td>' 'Carol Pinnsler' '</td>'
			'<td>' 'Haunted bowling ball' '</td>'
		'</tr>'
	'</table>'
/, 'simple table';

#`(
=table
    Constants           1
    Variables           10
    Subroutines         33
    Everything else     57

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
die $html;

like $html, /
1
/;
)

#`(
=for table
    mouse    | mice
    horse    | horses
    elephant | elephants

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
die $html;

like $html, /
1
/;
)

#`(
=table
    Animal | Legs |    Eats
    =======================
    Zebra  +   4  + Cookies
    Human  +   2  +   Pizza
    Shark  +   0  +    Fish

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
die $html;

like $html, /
1
/;
)

#`(
=table
        Superhero     | Secret          |
                      | Identity        | Superpower
        ==============|=================|================================
        The Shoveller | Eddie Stevens   | King Arthur's singing shovel

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
die $html;

like $html, /
1
/;
)

#`(
=begin table

                        Secret
        Superhero       Identity          Superpower
        =============   ===============   ===================
        The Shoveller   Eddie Stevens     King Arthur's
                                          singing shovel

        Blue Raja       Geoffrey Smith    Master of cutlery

        Mr Furious      Roy Orson         Ticking time bomb
                                          of fury

        The Bowler      Carol Pinnsler    Haunted bowling ball

=end table

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
die $html;

like $html, /
1
/;
)

#`(
=table
    X | O |
   ---+---+---
      | X | O
   ---+---+---
      |   | X

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
die $html;

like $html, /
1
/;
)

#`(
# test for:
#   RT #126740 - Pod::Block::Table node caption property is not populated properly
# Note that the caption property is just one of the table's %config key/value
# pairs so any tests for other config keys in a single table are usually the same as testing
# multiple tables, each for one caption test.
=begin table :caption<foo> :bar(0)

foo
bar

=end table

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
die $html;

like $html, /
1
/;
)

done-testing;

# vim: ft=perl6
