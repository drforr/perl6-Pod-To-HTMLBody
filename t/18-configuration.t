use v6;
use Test;
use Pod::To::BlogspotHTML;

my $pod-counter = 0;
my $html;
my $r;

=begin pod
    =begin code :allow<B>
    =end code
=end pod

#die $=pod[$pod-counter].perl;
$r = $=pod[$pod-counter];
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

is $r.contents[0].config<allow>, 'B'; # XXX May not need to test this...
like $html, /
	'<code>'
	'</code>'
/, 'code with configuration';

=begin pod
    =config head2  :like<head1> :formatted<I>
=end pod

#die $=pod[$pod-counter].perl;
$r = $=pod[$pod-counter];
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;
#die "[$html]";
#die $r;

# XXX may not be appropriate...
is $r.contents[0].type, 'head2';
is $r.contents[0].config<like>, 'head1';
is $r.contents[0].config<formatted>, 'I';
ok !$html, 'no actual HTML';
#like $html, /
#	''
#/;

=begin pod
    =for pod :number(42) :zebras :!sheep :feist<1 2 3 4>
=end pod

#die $=pod[$pod-counter].perl;
$r = $=pod[$pod-counter];
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

# RT#127085
is $r.contents[0].config<number>, 42;
is $r.contents[0].config<zebras>, True;
is $r.contents[0].config<sheep>, False;
ok !$html, 'no HTML, just configuration';
#like $html, /
#1
#/;

=begin pod
=for DESCRIPTION :title<presentation template>
=                :author<John Brown> :pubdate(2011)
=end pod

#die $=pod[$pod-counter].perl;
$r = $=pod[$pod-counter];
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $r;
#die $html;

#`( XXX HTML has gone missing...
is $r.contents[0].config<title>, 'presentation template';
is $r.contents[0].config<author>, 'John Brown';
is $r.contents[0].config<pubdate>, 2011;
like $html, /
1
/;
)

=begin pod
=for table :caption<Table of contents>
    foo bar
=end pod

#die $=pod[$pod-counter].perl;
$r = $=pod[$pod-counter];
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $r;
#die $html;

#`( XXX missing HTML here again
is $r.contents[0].config<caption>, 'Table of contents';
like $html, /
1
/;
)

=begin pod
    =begin code :allow<B>
    These words have some B<importance>.
    =end code
=end pod

#die $=pod[$pod-counter].perl;
$r = $=pod[$pod-counter];
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $r;
#die $html;

like $html, /:s
	'<code>'
		'These words have some'
		'<b>' 'importance' '</b>'
		'.'
	'</code>'
/, 'Adjective';

isa-ok $r.contents[0].contents[1], Pod::FormattingCode;

done-testing;

# vim: ft=perl6
