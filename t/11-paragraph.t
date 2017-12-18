use v6;
use Test;
use Pod::To::BlogspotHTML;

my $pod-counter = 0;
my $html;

=for foo

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<section>'
		'<h1>' 'foo' '</h1>'
	'</section>'
/, 'hanging block';

=for foo
some text

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<section>'
		'<h1>' 'foo' '</h1>'
		'<p>' 'some text' '</p>'
	'</section>'
/, 'paragraph with body';

=for foo
some
spaced   text

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<section>'
		'<h1>' 'foo' '</h1>'
		'<p>' 'some spaced text' '</p>'
	'</section>'
/, 'spacing';

=begin pod

=for got
Inside got

    =for bidden
    Inside bidden

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
/, 'nested blocks';

# mixed blocks
=begin pod
=begin one
one, delimited block
=end one
=for two
two, paragraph block
=for three
three, still a parablock

=begin four
four, another delimited one
=end four
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
/, 'multiple blocks';

# tests without Albi would still be tests, but definitely very, very sad
# also, Albi without paragraph blocks wouldn't be the happiest dragon
# either
=begin foo
and so,  all  of  the  villages chased
Albi,   The   Racist  Dragon, into the
very   cold   and  very  scary    cave

and it was so cold and so scary in
there,  that  Albi  began  to  cry

    =for bar
    Dragon Tears!

Which, as we all know...

    =for bar
    Turn into Jelly Beans!
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
			'<h1>' 'bar' '</h1>'
			'<p>' 'Dragon Tears!' '</p>'
		'</section>'
		'<p>' 'Which, as we all know...' '</p>'
		'<section>'
			'<h1>' 'bar' '</h1>'
			'<p>' 'Turn into Jelly Beans!' '</p>'
		'</section>'
	'</section>'
/, 'nested blocks';

#`(
# RT#131400
=for pod
=for nested
=for para :nested(1)
E<a;b>E<a;b;c>
♥♥♥

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
die $html;

like $html, /
1
/;
)

done-testing;

# vim: ft=perl6
