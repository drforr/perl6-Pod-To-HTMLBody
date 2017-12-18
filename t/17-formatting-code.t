use v6;
use Test;
use Pod::To::BlogspotHTML;

my $pod-counter = 0;
my $html;

=pod
B<I am a formatting code>

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<b>' 'I am a formatting code' '</b>'
/, 'inline bold';

=pod
The basic C<ln> command is: C<ln> B<R<source_file> R<target_file>>

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /:s
	'The basic'
	'<code>' 'ln' '</code>'
	'command is:'
	'<code>' 'ln' '</code>'
	'<b>'
		'<var>' 'source_file' '</var>'
		'<var>' 'target_file' '</var>'
	'</b>'
/, 'inline code';

=pod
L<C<b>|a>
L<C<b>|a>

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /:s
	'<a href="a">' '<code>' 'b' '</code>' '</a>'
	'<a href="a">' '<code>' 'b' '</code>' '</a>'
/, 'links';

=begin pod

=head1 A heading

This is Pod too. Specifically, this is a simple C<para> block

    $this = pod('also');  # Specifically, a code block

=end pod

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

#`( XXX Should be a quick fix...
like $html, /:s
	'<h1>' 'A heading' '</h1>'
	'<p>' 'This is Pod too. Specifically, this is a simple'
		'<code>' 'para' '</code>'
		'block'
	'</p>'
	'<code>'
		'\$this = pod(\'also\');  # Specifically, a code block'
	'</code>'
/, 'mixture';
)

=pod V<C<boo> B<bar> asd>

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

#`( XXX V<> is NYI yet, apparently.
like $html, /
1
/;
)

# RT #114510
=pod C< infix:<+> >
=pod C<< infix:<+> >>

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;
my $html2 = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html2;

#`( XXX Needs to be translated.
like $html, /
<code>infix:<+> </code>
/;
)

done-testing;

# vim: ft=perl6
