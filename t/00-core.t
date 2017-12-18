use v6;
use Pod::To::BlogspotHTML;
use Test;

=begin pod
Lorem ipsum
=end pod

ok Pod::To::BlogspotHTML.render( $=pod[0] );

done-testing;

# vim: ft=perl6
