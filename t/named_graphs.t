# Tests from RDF::RDFa::Parser adapted for RDF::RDFa::Parser::Trine

use Test::More tests => 10;
BEGIN { use_ok('RDF::RDFa::Parser::Trine') };
use Data::Dumper;
use RDF::Trine;
use RDF::RDFa::Parser::Trine;

my $xhtml = <<EOF;
<html xmlns:dc="http://purl.org/dc/terms/" xmlns:foaf="http://xmlns.com/foaf/0.1/" xml:lang="en">
	<head>
		<title property="dc:title">This is the title</title>
	</head>
	<body xmlns:dc="http://purl.org/dc/elements/1.1/">
		<div rel="foaf:primaryTopic" rev="foaf:page" xml:lang="de">
			<h1 about="#topic" typeof="foaf:Person" property="foaf:name">Albert Einstein</h1>
		</div>
		<address rel="foaf:maker dc:creator" rev="foaf:made" xmlns:g="http://example.com/graphing">
			<a g:graph="#JOE" about="#maker" property="foaf:name" rel="foaf:homepage" href="joe">Joe Bloggs</a>
		</address>
	</body>
</html>
EOF

my $storage = RDF::Trine::Store::DBI->temporary_store;

my $parser = RDF::RDFa::Parser::Trine->new($storage, $xhtml, 'http://example.com/einstein');

$parser->named_graphs('http://example.com/graphing', 'graph');
ok($parser->consume, "Graph consumed");



#warn Dumper($parser);

ok(my $graph  = $parser->graph, "Graph returned");

{
  my $joe = $parser->graph('http://example.com/einstein#JOE');  
  ok($joe->count_statements == 2, "The other graph has two statements");
}




my $graphs = $parser->graphs;

{
  my @got = keys(%$graphs);
  my @expected = ('_:RDFaDefaultGraph',
			   'http://example.com/einstein#JOE');
  is_deeply(\@got, \@expected, "Graph names are correct");
}


ok($graph->count_statements == 
     $graphs->{'http://example.com/einstein#JOE'}->count_statements + 
     $graphs->{'_:RDFaDefaultGraph'}->count_statements,
     "The full graph has the same number of statements as its parts");

my $other = $graphs->{'http://example.com/einstein#JOE'};
isa_ok($other, 'RDF::Trine::Model');
ok($other->count_statements == 2, "The other graph has two statements");
my $stream = $other->get_statements(
        RDF::Trine::Node::Resource->new('http://example.com/einstein#maker'),  
	RDF::Trine::Node::Resource->new('http://xmlns.com/foaf/0.1/name'), undef, undef);
ok(my $row = $stream->next, "got a row for a literal");

my $expected = RDF::Trine::Node::Literal->new('Joe Bloggs', 'en');
ok($row->object->equal($expected) , 'RDFa graph looks OK (tested a literal).');


