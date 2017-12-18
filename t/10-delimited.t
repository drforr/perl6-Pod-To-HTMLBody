use v6;
use Test;
use Pod::To::BlogspotHTML;

my $pod-counter = 0;
my $html;

=begin foo
=end foo

#die $=pod[$pod-counter];
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<section>'
		'<h1>' 'foo' '</h1>'
	'</section>'
/, 'bare block';

=begin foo
some text
=end foo

#die $=pod[$pod-counter];
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<section>'
		'<h1>' 'foo' '</h1>'
		'<p>' 'some text' '</p>'
	'</section>'
/, 'with text';

=begin foo
some
spaced   text
=end foo

#die $=pod[$pod-counter];
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<section>'
		'<h1>' 'foo' '</h1>'
		'<p>' 'some spaced text' '</p>'
	'</section>'
/, 'two lines';

=begin foo
paragraph one

paragraph
two
=end foo

#die $=pod[$pod-counter];
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<section>'
		'<h1>' 'foo' '</h1>'
		'<p>' 'paragraph one' '</p>'
		'<p>' 'paragraph two' '</p>'
	'</section>'
/, 'two paragraphs';

=begin something
    =begin somethingelse
    toot tooot!
    =end somethingelse
=end something

#die $=pod[$pod-counter];
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<section>'
		'<h1>' 'something' '</h1>'
		'<section>'
			'<h1>' 'somethingelse' '</h1>'
			'<p>' 'toot tooot!' '</p>'
		'</section>'
	'</section>'
/, 'nested section';

=begin foo
and so,  all  of  the  villages chased
Albi,   The   Racist  Dragon, into the
very   cold   and  very  scary    cave

and it was so cold and so scary in
there,  that  Albi  began  to  cry

    =begin bar
    Dragon Tears!
    =end bar

Which, as we all know...

    =begin bar
    Turn into Jelly Beans!
    =end bar
=end foo

#die $=pod[$pod-counter];
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
/, 'Mixed sections and paragraphs';

=begin something
    =begin somethingelse
    toot tooot!
    =end somethingelse
=end something

#die $=pod[$pod-counter];
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<section>'
		'<h1>' 'something' '</h1>'
		'<section>'
			'<h1>' 'somethingelse' '</h1>'
			'<p>' 'toot tooot!' '</p>'
		'</section>'
	'</section>'
/, 'regression test';

=begin pod

someone accidentally left a space
 
between these two paragraphs

=end pod

#die $=pod[$pod-counter];
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<p>' 'someone accidentally left a space' '</p>'
	'<p>' 'between these two paragraphs' '</p>'
/, 'paragraph break';

# various things which caused the spectest to fail at some point

=begin kwid

= DESCRIPTION
bla bla

foo
=end kwid

#die $=pod[$pod-counter];
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<section>'
		'<h1>' 'kwid' '</h1>'
		'<p>' '= DESCRIPTION bla bla' '</p>'
		'<p>' 'foo' '</p>'
	'</section>'
/, 'broken meta tag';

=begin more-discussion-needed

XXX: chop(@array) should return an array of chopped strings?
XXX: chop(%has)   should return a  hash  of chopped strings?

=end more-discussion-needed

#die $=pod[$pod-counter];
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<section>'
		'<h1>' 'more-discussion-needed' '</h1>'
		'<p>' 'XXX: chop(@array) should return an array of chopped strings? XXX: chop(%has) should return a hash of chopped strings?' '</p>'
	'</section>'
/, 'playing with line breaks';

=begin pod
    =head1 This is a heading block

    This is an ordinary paragraph.
    Its text  will   be     squeezed     and
    short lines filled. It is terminated by
    the first blank line.

    This is another ordinary paragraph.
    Its     text    will  also be squeezed and
    short lines filled. It is terminated by
    the trailing directive on the next line.
        =head2 This is another heading block

        This is yet another ordinary paragraph,
        at the first virtual column set by the
        previous directive
=end pod

#die $=pod[$pod-counter];
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<h1>' 'This is a heading block' '</h1>'
	'<p>' 'This is an ordinary paragraph. Its text will be squeezed and short lines filled. It is terminated by the first blank line.' '</p>'
	'<p>' 'This is another ordinary paragraph. Its text will also be squeezed and short lines filled. It is terminated by the trailing directive on the next line.' '</p>'
	'<h2>' 'This is another heading block' '</h2>'
	'<p>' 'This is yet another ordinary paragraph, at the first virtual column set by the previous directive' '</p>'
/, 'headings with indentations';

done-testing;

# vim: ft=perl6
