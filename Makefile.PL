use inc::Module::Install;

name     'RDF-RDFa-Parser-Trine';
all_from 'lib/RDF/RDFa/Parser/Trine.pm';
author   'Kjetil Kjernsmo <kjetilk@cpan.org>';
license  'perl';

build_requires 'Test::More';

requires 'RDF::Trine' => 0;
requires 'RDF::RDFa::Parser' => 0.04;

auto_install;

sign;
WriteAll;

