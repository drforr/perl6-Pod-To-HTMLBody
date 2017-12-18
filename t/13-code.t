use v6;
use Test;
use Pod::To::BlogspotHTML;

my $pod-counter = 0;
my $html;

=begin pod
This ordinary paragraph introduces a code block:

    $this = 1 * code('block');
    $which.is_specified(:by<indenting>);

    $which.spans(:newlines);

=end pod

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<p>' 'This ordinary paragraph introduces a code block:' '</p>'
	'<code>' "\$this = 1 * code('block');
\$which.is_specified(:by<indenting>);

\$which.spans(:newlines);" '</code>'
/, 'indented code';

# more fancy code blocks
=begin pod
This is an ordinary paragraph

    While this is not
    This is a code block

    =head1 Mumble mumble

    Suprisingly, this is not a code block
        (with fancy indentation too)

But this is just a text. Again

=end pod

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<p>' 'This is an ordinary paragraph' '</p>'
	'<code>' 'While this is not
This is a code block' '</code>'
	'<h1>' 'Mumble mumble' '</h1>'
	'<p>' 'Suprisingly, this is not a code block (with fancy indentation too)' '</p>'
	'<p>' 'But this is just a text. Again' '</p>'
/, 'mixed block types';

=begin pod

Tests for the feed operators

    ==> and <==
    
=end pod

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

# XXX Check to see if entities need to be decoded here.
like $html, /
	'<p>' 'Tests for the feed operators' '</p>'
	'<code>' '==> and <==' '</code>'
/, 'entities';

=begin pod
Fun comes

    This is code
  Ha, what now?

 one more block of code
 just to make sure it works
  or better: maybe it'll break!
=end pod

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<p>' 'Fun comes' '</p>'
	'<code>' 'This is code' '</code>'
	'<code>' 'Ha, what now?' '</code>'
	'<code>' 'one more block of code
just to make sure it works
 or better: maybe it\'ll break!' '</code>'
/, 'multi-line code block';

=begin pod

=head1 A heading

This is Pod too. Specifically, this is a simple C<para> block

    $this = pod('also');  # Specifically, a code block

=end pod

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

# XXX The code with '$this...' needs to be fixed.
like $html, /:s
	'<h1>' 'A heading' '</h1>'
	'<p>' 'This is Pod too. Specifically, this is a simple'
		'<code>' 'para' '</code>'
		'block'
	'</p>'
	'<code>' # '\$this = pod(\'also\');  # Specifically, a code block' '</code>'
/, 'complex code block';

=begin pod
    this is code

    =for podcast
        this is not

    this is not code either

    =begin itemization
        this is not
    =end itemization

    =begin quitem
        and this is not
    =end quitem

    =begin item
        and this is!
    =end item
=end pod

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

# Note that <li> <code/> </li> is intentional here because of the indent.
like $html, /
	'<code>' 'this is code' '</code>'
	'<section>'
		'<h1>' 'podcast' '</h1>'
		'<p>' 'this is not' '</p>'
	'</section>'
	'<p>' 'this is not code either' '</p>'
	'<section>'
		'<h1>' 'itemization' '</h1>'
		'<p>' 'this is not' '</p>'
	'</section>'
	'<section>'
		'<h1>' 'quitem' '</h1>'
		'<p>' 'and this is not' '</p>'
	'</section>'
	'<ul>'
		'<li>' '<code>' 'and this is!' '</code>' '</li>'
	'</ul>'
/, 'mixed code and one hidden in an item';

=begin code
    foo foo
    =begin code
    =end code
=end code

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /:s
	'<code>'
	'foo foo
    =begin code
    =end code'
	'</code>'
/, 'embedded pseudo-pod';

done-testing;

# vim: ft=perl6
