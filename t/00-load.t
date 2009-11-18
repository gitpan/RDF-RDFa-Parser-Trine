#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'RDF::RDFa::Parser::Trine' );
}

diag( "Testing RDF::RDFa::Parser::Trine $RDF::RDFa::Parser::Trine::VERSION" );
