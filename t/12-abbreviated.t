use v6;
use Test;
use Pod::To::BlogspotHTML;

my $pod-counter = 0;
my $html;

=foo

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<section>'
		'<h1>' 'foo' '</h1>'
	'</section>'
/, 'hanging block';

=foo some text

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<section>'
		'<h1>' 'foo' '</h1>'
		'<p>' 'some text' '</p>'
	'</section>'
/, 'hanging block with paragraph';

=foo some text
and some more

# Yes, 'some text' and 'and some more' are in the same paragraph block, no
# way to know if they've been broken up.
#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<section>'
		'<h1>' 'foo' '</h1>'
		'<p>' 'some text and some more' '</p>'
	'</section>'
/, 'hanging block with paragraph';

=begin pod

=got Inside
got

=bidden Inside
bidden

Outside blocks
=end pod

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<section>'
		'<h1>' 'got' '</h1>'
		'<p>' 'Inside got' '</p>'
	'</section>'
	'<section>'
		'<h1>' 'bidden' '</h1>'
		'<p>' 'Inside bidden' '</p>'
	'</section>'
	'<p>' 'Outside blocks' '</p>'
/, 'multiple blocks';

# mixed blocks
=begin pod
    =begin one
    one, delimited block
    =end one
    =two two,
    paragraph block
    =for three
    three, still a parablock

    =begin four
    four, another delimited one
    =end four
    =head1 And just for the sake of having a working =head1 :)
=end pod

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<section>'
		'<h1>' 'one' '</h1>'
		'<p>' 'one, delimited block' '</p>'
	'</section>'
	'<section>'
		'<h1>' 'two' '</h1>'
		'<p>' 'two, paragraph block' '</p>'
	'</section>'
	'<section>'
		'<h1>' 'three' '</h1>'
		'<p>' 'three, still a parablock' '</p>'
	'</section>'
	'<section>'
		'<h1>' 'four' '</h1>'
		'<p>' 'four, another delimited one' '</p>'
	'</section>'
	'<h1>' 'And just for the sake of having a working =head1 :)' '</h1>'
/, 'mixed contents';

=begin foo
and so,  all  of  the  villages chased
Albi,   The   Racist  Dragon, into the
very   cold   and  very  scary    cave

and it was so cold and so scary in
there,  that  Albi  began  to  cry

    =bold Dragon Tears!

Which, as we all know...

    =bold Turn
          into
          Jelly
          Beans!
=end foo

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<section>'
		'<h1>' 'foo' '</h1>'
		'<p>' 'and so, all of the villages chased Albi, The Racist Dragon, into the very cold and very scary cave' '</p>'
		'<p>' 'and it was so cold and so scary in there, that Albi began to cry' '</p>'
		'<section>'
			'<h1>' 'bold' '</h1>'
			'<p>' 'Dragon Tears!' '</p>'
		'</section>'
		'<p>' 'Which, as we all know...' '</p>'
		'<section>'
			'<h1>' 'bold' '</h1>'
			'<p>' 'Turn into Jelly Beans!' '</p>'
		'</section>'
	'</section>'
/, 'nested paragraphs';

# from S26
=table_not
    Constants 1
    Variables 10
    Subroutines 33
    Everything else 57

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<section>'
		'<h1>' 'table_not' '</h1>'
		'<p>' 'Constants 1 Variables 10 Subroutines 33 Everything else 57' '</p>'
	'</section>'
/, 'not a table';

=head3
Heading level 3

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<h3>' 'Heading level 3' '</h3>'
/, 'heading';

done-testing;

# vim: ft=perl6
