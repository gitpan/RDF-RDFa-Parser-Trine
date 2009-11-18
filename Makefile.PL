use inc::Module::Install;

name     'RDF-RDFa-Parser-Trine';
all_from 'lib/RDF/RDFa/Parser/Trine.pm';
author   'Kjetil Kjernsmo <kjetilk@cpan.org>';
license  'perl';


test_requires		'Test::More'				=> '0.61';
test_requires		'Test::Exception'			=> 0;

include                 'Test::Signature';

requires 'RDF::Trine' => 0.111;
requires 'RDF::RDFa::Parser' => 0.04;

auto_install;

sign;
WriteAll;

