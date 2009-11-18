use Test::More tests => 15;
BEGIN { 
  use_ok('RDF::RDFa::Parser::Trine'); 
  use_ok('RDF::Trine');
  use_ok('RDF::Trine::Store');
  use_ok('RDF::Trine::Node::Literal::XML');
};
use RDF::RDFa::Parser::Trine;
use RDF::Trine;
use RDF::Trine::Store;
use RDF::Trine::Node::Literal::XML;

my $xhtml = <<EOF;
<html xmlns:foaf="http://xmlns.com/foaf/0.1/">
	<body xmlns:dc="http://purl.org/dc/elements/1.1/">
		<div rel="foaf:primaryTopic" rev="foaf:page">
			<h1 about="#topic" typeof="foaf:Person" property="foaf:name" 
                datatype="http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral"><strong>Albert Einstein</strong></h1>
		</div>
	</body>
</html>
EOF

my $storage = RDF::Trine::Store::->temporary_store;

my $parser = RDF::RDFa::Parser::Trine->new($storage, $xhtml, 'http://example.com/einstein');

ok(lc($parser->dom->documentElement->tagName) eq 'html', 'DOM Tree returned OK.');

ok($parser->consume, "Parse OK");

ok(my $graph = $parser->graph, "Graph retrieved");

isa_ok($graph, 'RDF::Trine::Model');

ok($graph->count_statements == 4, "There are 4 triples in the model");

my $stream = $graph->get_statements(
	     RDF::Trine::Node::Resource->new('http://example.com/einstein#topic'),  
	     RDF::Trine::Node::Resource->new('http://xmlns.com/foaf/0.1/name'), undef, undef
				   );
ok(my $row = $stream->next, "got a row for resource");

ok($row->subject->uri eq 'http://example.com/einstein#topic' , 'RDFa graph looks OK (tested a resource).');


my $expected = RDF::Trine::Node::Literal::XML->new('<strong>Albert Einstein</strong>');

isa_ok($row->object, 'RDF::Trine::Node::Literal::XML');


ok($row->object->literal_value eq '<strong>Albert Einstein</strong>', "The literal value is identical");
ok($row->object->literal_datatype eq 'http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral', "The literal datatype is identical");


ok($row->object->equal($expected), "The expected object is equal");
