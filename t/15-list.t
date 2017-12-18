use v6;
use Test;
use Pod::To::BlogspotHTML;

my $pod-counter = 0;
my $html;

=begin pod
The seven suspects are:

=item  Happy
=item  Dopey
=item  Sleepy
=item  Bashful
=item  Sneezy
=item  Grumpy
=item  Keyser Soze
=end pod

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<p>' 'The seven suspects are:' '</p>'
	'<ul>'
		'<li>' 'Happy' '</li>'
		'<li>' 'Dopey' '</li>'
		'<li>' 'Sleepy' '</li>'
		'<li>' 'Bashful' '</li>'
		'<li>' 'Sneezy' '</li>'
		'<li>' 'Grumpy' '</li>'
		'<li>' 'Keyser Soze' '</li>'
	'</ul>'
/, 'one-level list';

=begin pod
=item1  Animal
=item2     Vertebrate
=item2     Invertebrate

=item1  Phase
=item2     Solid
=item2     Liquid
=item2     Gas
=item2     Chocolate
=end pod

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

like $html, /
	'<ul>'
		'<li>' 'Animal' '</li>'
		'<ul>'
			'<li>' 'Vertebrate' '</li>'
			'<li>' 'Invertebrate' '</li>'
		'</ul>'
		'<li>' 'Phase' '</li>'
		'<ul>'
			'<li>' 'Solid' '</li>'
			'<li>' 'Liquid' '</li>'
			'<li>' 'Gas' '</li>'
			'<li>' 'Chocolate' '</li>'
		'</ul>'
	'</ul>'
/, 'nested lists';

#`(
=begin pod
=comment CORRECT...
=begin item1
The choices are:
=end item1
=item2 Liberty
=item2 Death
=item2 Beer
=end pod

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
die $html;

like $html, /
1
/;
)

# XXX Those items are :numbered in S26, but we're waiting with block
# configuration until we're inside Rakudo, otherwise we'll have to
# pretty much implement Pair parsing in gsocmess only to get rid of
# it later.

=begin pod
Let's consider two common proverbs:

=begin item
I<The rain in Spain falls mainly on the plain.>

This is a common myth and an unconscionable slur on the Spanish
people, the majority of whom are extremely attractive.
=end item

=begin item
I<The early bird gets the worm.>

In deciding whether to become an early riser, it is worth
considering whether you would actually enjoy annelids
for breakfast.
=end item

As you can see, folk wisdom is often of dubious value.
=end pod

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
#die $html;

#`( XXX The <p/> around the <i/> shouldn't be there IMO
like $html, /
	'<p>' 'Let\'s consider two common proverbs:' '</p>'
	'<ul>'
		'<li>'
#			'<p>'
				'<i>' 'The rain in Spain falls mainly on the plain.' '</i>'
#			'</p>'
			'<p>' 'This is a common myth and an unconscionable slur on the Spanish people, the majority of whom are extremely attractive.' '</p>'
		'</li>'
		'<li>'
#			'<p>'
				'<i>' 'The early bird gets the worm.' '</i>'
#			'</p>'
			'<p>' 'In deciding whether to become an early riser, it is worth considering whether you would actually enjoy annelids for breakfast.' ''</p>'
		'</li>'
	'</ul>'
	'<p>' 'As you can see, folk wisdom is often of dubious value.' '</p>'
/;
)

done-testing;

# vim: ft=perl6
