#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Net::Braintree' ) || print "Bail out!\n";
}

diag( "Testing Net::Braintree $Net::Braintree::VERSION, Perl $], $^X" );
