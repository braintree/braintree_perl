{
  package Net::Braintree::AdvancedSearchFields;
  use Carp;
  use Moose;

  has "metaclass" => (is => 'rw');

  sub field {
    my ($self, $name, $node) = @_;
    $self->metaclass->add_attribute($name, is => 'rw', default => $node);
  }

  sub is {
    my ($self, $name) = @_;
    $self->field($name, sub {
      return Net::Braintree::IsNode->new(searcher => shift, name => $name);
    });
  }

  sub equality {
    my ($self, $name) = @_;
    $self->field($name, sub {
      return Net::Braintree::EqualityNode->new(searcher => shift, name => $name);
    });
  }

  sub text {
    my ($self, $name) = @_;
    $self->field($name, sub {
      return Net::Braintree::TextNode->new(searcher => shift, name => $name);
    });
  }

  sub key_value {
    my ($self, $name) = @_;
    $self->field($name, sub {
      return Net::Braintree::KeyValueNode->new(searcher => shift, name => $name);
    });
  }

  sub range {
    my ($self, $name) = @_;
    $self->field($name, sub {
      return Net::Braintree::RangeNode->new(searcher => shift, name => $name);
    });
  }

  sub multiple_values {
    my ($self, $name, @allowed_values) = @_;
    my $node = sub {
      return Net::Braintree::MultipleValuesNode->new(
        searcher => shift,
        name => $name,
        allowed_values => @allowed_values ? [@allowed_values] : undef)
    };
    $self->field($name, $node);
  }

  sub partial_match {
    my ($self, $name) = @_;
    $self->field($name, sub {
      return Net::Braintree::PartialMatchNode->new(searcher => shift, name => $name);
    });
  }

__PACKAGE__->meta->make_immutable;
  1;
}
