package Net::Braintree::Xml;
use XML::Simple;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS );
use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(hash_to_xml xml_to_hash array collect_from_array);
our @EXPORT_OK = qw();
use Net::Braintree::Util;
use DateTime::Format::Atom;
use XML::LibXML;

sub hash_to_xml {
  my $hash = shift;
  my $doc = XML::LibXML::Document->createDocument('1.0', 'UTF-8');
  my $root_key = (keys %$hash)[0];
  my $element = XML::LibXML::Element->new($root_key);

  my $value = $hash->{$root_key};
  my $node = add_node($element, $value);
  $doc->setDocumentElement($element);

  return $doc->toString(1);
}

sub add_node {
  my ($parent, $value) = @_;
  if(is_hash($value)){
    build_from_hash($parent, $value);
  } elsif(is_array($value)){
    build_from_array($parent, $value);
  } else {
    $parent->appendText($value) if $value;
  }
}

sub build_from_hash {
  my($parent, $value) = @_;
  while(my($key, $child_value) = each(%$value)) {
    build_node($key, $child_value, $parent);
  }
}

sub build_from_array {
  my($parent, $value) = @_;
  $parent->setAttribute('type', 'array');
  foreach my $child_value (@$value) {
    build_node('item', $child_value, $parent);
  }
}

sub build_node {
  my($node_name, $child_value, $parent) = @_;
  my $child = XML::LibXML::Element->new($node_name);
  add_node($child, $child_value);
  $parent->appendChild($child);
}

sub xml_to_hash {
  my $return = XMLin(shift, KeyAttr => [], KeepRoot => 1);
  my $scrubbed = scrubbed($return);
  return $scrubbed;
}

sub scrubbed {
  my $tree = shift;
  if (is_hash($tree)) {
    return collect_from_hash($tree);
  }
  if (is_array($tree)) {
    return collect_from_array($tree);
  }
  return $tree;
}

sub collect_from_array {
  my ($tree) = @_;
  my @new_array = ();
  foreach my $value (@$tree) {
    push(@new_array, scrubbed($value));
  }
  return \@new_array;
}

my @types = qw(array boolean integer datetime date);

sub collect_from_hash {
  my ($tree) = @_;
  my $new_hash = {};
  foreach my $type (@types) {
    return &$type($tree) if is_of_type($type, $tree);
  }
  return $tree->{'content'} if exists($tree->{'content'});
  return undef if is_nil($tree);
  while(my ($key, $subtree) = each(%$tree)) {
    $new_hash->{sub_dashes($key)} = scrubbed($subtree);
  }
  return $new_hash;
}

sub is_of_type {
  my ($type, $tree) = @_;
  no warnings;
  return 0 unless $tree->{'type'};
  return $tree->{'type'} eq $type;
}

sub is_nil {
  my $tree = shift;
  return 0 unless $tree->{'nil'};
  return $tree->{'nil'} eq "true";
}

sub boolean {
  return shift->{'content'} eq 'true' ? 1 : 0;
}

sub integer {
  return shift->{'content'};
}

my $f = DateTime::Format::Atom->new();

sub datetime {
  my $dt = $f->parse_datetime(shift->{'content'});
}

sub date {
  my $date = shift->{'content'};
  $date .= 'T00:00:00Z';
  my $dt = $f->parse_datetime($date);
}

sub array {
  my $tree = shift;

  delete $tree->{type};
  my $subtree = (values %$tree)[0];
  if (ref $subtree eq 'HASH') {
    return [scrubbed($subtree)];
  } elsif (ref $subtree eq 'ARRAY') {
    return scrubbed(force_array($subtree));
  } else {
    return [];
  }

}


sub sub_dashes {
  my $string = shift;
  $string =~ s/-/_/g;
  return $string;
}

sub force_array {
  my $subtree = shift;
  return $subtree if(is_array($subtree));
  return [$subtree];
}

1;
