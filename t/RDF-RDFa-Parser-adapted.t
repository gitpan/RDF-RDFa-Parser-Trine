# These are the RDF-RDFa-Parser tests adapted to running for
# RDF::RDFa::Parser::Trine

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl RDF-RDFa-Parser-adapted.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 11;
BEGIN { 
  use_ok('RDF::RDFa::Parser::Trine'); 
  use_ok('RDF::Trine::Store::DBI');
  use_ok('RDF::Trine::Node::Resource');
};

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

use RDF::RDFa::Parser;
use RDF::Trine::Store::DBI;
use RDF::Trine::Node::Resource;

my $xhtml = <<EOF;
<html xmlns:dc="http://purl.org/dc/terms/" xmlns:foaf="http://xmlns.com/foaf/0.1/" xml:lang="en">
	<head>
		<title property="dc:title">This is the title</title>
	</head>
	<body xmlns:dc="http://purl.org/dc/elements/1.1/">
		<div rel="foaf:primaryTopic" rev="foaf:page" xml:lang="de">
			<h1 about="#topic" typeof="foaf:Person" property="foaf:name">Albert Einstein</h1>
		</div>
		<address rel="foaf:maker dc:creator" rev="foaf:made">
			<a about="#maker" property="foaf:name" rel="foaf:homepage" href="joe">Joe Bloggs</a>
		</address>
	</body>
</html>
EOF
$storage = RDF::Trine::Store::DBI->temporary_store;
$parser = RDF::RDFa::Parser::Trine->new($storage, $xhtml, 'http://example.com/einstein');

ok(lc($parser->dom->documentElement->tagName) eq 'html', 'DOM Tree returned OK.');
ok($parser->consume, "Graph consumed");
ok(my $graph = $parser->graph, "Graph returned");

ok($graph->count_statements == 10, "There are 10 triples in the model");
my $stream = $graph->get_statements(
	     RDF::Trine::Node::Resource->new('http://example.com/einstein'),  
	     RDF::Trine::Node::Resource->new('http://purl.org/dc/elements/1.1/creator'), undef, undef
				   );
ok(my $row = $stream->next, "got a row for resource");

ok($row->object->uri eq 'http://example.com/einstein#maker' , 'RDFa graph looks OK (tested a resource).');

my $stream2 = $graph->get_statements(
	     RDF::Trine::Node::Resource->new('http://example.com/einstein#topic'),  
	     RDF::Trine::Node::Resource->new('http://xmlns.com/foaf/0.1/name'), undef, undef
				   );
ok(my $row2 = $stream2->next, "got a row for a literal");

my $expected = RDF::Trine::Node::Literal->new('Albert Einstein', 'de');

ok($row2->object->equal($expected) , 'RDFa graph looks OK (tested a literal).');
