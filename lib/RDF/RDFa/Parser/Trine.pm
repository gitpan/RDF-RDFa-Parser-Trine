package RDF::RDFa::Parser::Trine;

use warnings;
use strict;

=head1 NAME

RDF::RDFa::Parser::Trine - Use a RDF::Trine::Model for the returned RDF graph

=head1 VERSION

Version 0.1

=cut

our $VERSION = 0.1;

use RDF::RDFa::Parser;
use RDF::Trine::Model;
use base ("RDF::RDFa::Parser");

sub new {
  my $class = shift;
  my $store = shift;
  my $self  = $class->SUPER::new(@_);
  $self->{NAMED_GRAPH} = undef;
  $self->{RESULTS} = RDF::Trine::Model->new($store);
  $self->set_callbacks(\&_callback_resource, \&_callback_literal);
  bless ($self, $class);
  return $self;
}


=head1 SYNOPSIS

This module inherits all the methods of its superclass, but overrides
the graph method, and will instead return an RDF::Trine::Model.

  $storage = RDF::Trine::Store::DBI->temporary_store;
  $parser = RDF::RDFa::Parser::Trine->new($storage, $xhtml, 'http://example.com/foo');
  $parser->consume;
  my $graph = $parser->graph;


=head1 METHODS

=over

=item $p = RDF::RDFa::Parser::Trine->new($store, $xhtml, $baseuri)

The constructor. Has three parameters. The first is a (single)
RDF::Trine::Store. The others are passed directly to the superclass.

=item $p->graph

Will return an RDF::Trine::Model object containing the full graph. As
per the RDFa specification, it will always return an unnamed graph
containing all the triples of the RDFa document.

=back

=cut


sub named_graph { #TODO
  my ($self, $switch) = @_;
 # $self->{NAMED_GRAPH} = $switch;
 $self->{NAMED_GRAPH} = 0;
}

sub graph {
  my $self = shift;
  return $self->{RESULTS};
}


sub _callback {
  my $parser      = shift;  # A reference to the RDF::RDFa::Parser object
  my $element   = shift;  # A reference to the XML::LibXML element being parsed
  my $subject   = shift;  # Subject URI or bnode
  my $predicate = shift;  # Predicate URI
  my $to        = shift;  # RDF::Trine::Node Resource URI or bnode

  # First, make sure subject and predicates are the right kind of nodes
  my $tp = RDF::Trine::Node::Resource->new($predicate, $parser->{baseuri});
  my $ts;
  if ($subject =~ m/^_:/) {
    $ts = RDF::Trine::Node::Blank->new($subject);
  } else {
    $ts = RDF::Trine::Node::Resource->new($subject, $parser->{baseuri});
  }

  # Add statement to default model.
  my $statement = RDF::Trine::Statement->new($ts, $tp, $to);


  $parser->{RESULTS}->add_statement($statement);
  # If we are configured for it, and graph name can be found, add it.
  if ($parser->{NAMED_GRAPH}) {
    my $graph_name = _find_graph_name($element);
    if ($graph_name) {
      my $statement = RDF::Trine::Statement::Quad->new($ts, $tp, $to, $graph_name);
      $parser->{RESULTS}->add_statement($statement);
    }
  }
}



sub _callback_resource {
  my $parser    = shift;  # A reference to the RDF::RDFa::Parser object
  my $element   = shift;  # A reference to the XML::LibXML element being parsed
  my $subject   = shift;  # Subject URI or bnode
  my $predicate = shift;  # Predicate URI
  my $object    = shift;  # Resource URI or bnode

  # First make sure the object node type is ok.
  my $to;
  if ($object =~ m/^_:/) {
    $to = RDF::Trine::Node::Blank->new($object);
  } else {
    $to = RDF::Trine::Node::Resource->new($object, $parser->{baseuri});
  }

  # Run the common function
  _callback($parser, $element, $subject, $predicate, $to);

}

sub _callback_literal {
  my $parser    = shift;  # A reference to the RDF::RDFa::Parser object
  my $element   = shift;  # A reference to the XML::LibXML element being parsed
  my $subject   = shift;  # Subject URI or bnode
  my $predicate = shift;  # Predicate URI
  my $object    = shift;  # Resource Literal
  my $datatype  = shift;  # Datatype URI (possibly undef or '')
  my $language  = shift;  # Language (possibly undef or '')

  # Now we know there's a literal

  my $to;
  
  if (defined($datatype)) {
    if ($datatype eq 'http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral') {
      $object = $element->childNodes;
      $to = RDF::Trine::Node::Literal::XML->new($object);
    } else {
      $to = RDF::Trine::Node::Literal->new($object, $language, $datatype);
    } 
  } else {
    $to = RDF::Trine::Node::Literal->new($object, $language, undef);
  }

  _callback($parser, $element, $subject, $predicate, $to);
}

sub _find_graph_name {
  return 0;
}


=head1 AUTHOR

Kjetil Kjernsmo, C<< <kjetilk at cpan.org> >>

=head1 TODO

This module does not yet fully support the named graphs of its subclass.

=head1 BUGS

Please report any bugs or feature requests to
C<bug-rdf-rdfa-parser-trine at rt.cpan.org>, or through the web
interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=RDF-RDFa-Parser-Trine>.
I will be notified, and then you'll automatically be notified of
progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc RDF::RDFa::Parser::Trine


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=RDF-RDFa-Parser-Trine>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/RDF-RDFa-Parser-Trine>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/RDF-RDFa-Parser-Trine>

=item * Search CPAN

L<http://search.cpan.org/dist/RDF-RDFa-Parser-Trine/>

=back


=head1 ACKNOWLEDGEMENTS

I would like to thank Toby Inkster for creating Swignition and the
parser module that this module depends on. I would also like to thank
Greg Williams for RDF::Trine.

Finally, I would like to thank the persistently circling dahuts for
their help and encouragement.


=head1 COPYRIGHT & LICENSE

Copyright 2009 Kjetil Kjernsmo.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
