{
  package Net::Braintree::AdvancedSearchNodes;
  use Moo;
}

{
  package Net::Braintree::SearchNode;
  use Moo;

  has 'searcher' => (is => 'rw');
  has 'name' => (is => 'rw');

  has 'criteria' => (is => 'rw', default => sub {shift->default_criteria()});

  sub default_criteria {
    return {};
  }

  sub active {
    my $self = shift;
    return %{$self->criteria};
  }

  sub add_node {
    my ($self, $operator, $operand) = @_;
    $self->criteria->{$operator} = $operand;
    return $self->searcher;
  }

  1;
}

{
  package Net::Braintree::IsNode;
  use Moo;
  extends ("Net::Braintree::SearchNode");

  sub is {
    my ($self, $operand) = @_;
    return $self->add_node("is", $operand);
  }
  1;
}

{
  package Net::Braintree::EqualityNode;
  use Moo;
  extends ("Net::Braintree::IsNode");

  sub is_not {
    my ($self, $operand) = @_;
    return $self->add_node("is_not", $operand);
  }
  1;
}

{
  package Net::Braintree::KeyValueNode;
  use Moo;
  extends ("Net::Braintree::SearchNode");

  sub default_criteria {
    return "";
  }

  sub active {
    my $self = shift;
    return $self->criteria;
  }

  sub is {
    my ($self, $operand) = @_;
    $self->criteria($operand);
    return $self->searcher;
  }
  1;
}

{
  package Net::Braintree::PartialMatchNode;
  use Moo;
  extends ("Net::Braintree::EqualityNode");

  sub starts_with {
    my ($self, $operand) = @_;
    return $self->add_node("starts_with", $operand);
  }

  sub ends_with {
    my ($self, $operand) = @_;
    return $self->add_node("ends_with", $operand);
  }
  1;
}

{
  package Net::Braintree::TextNode;
  use Moo;
  extends ("Net::Braintree::PartialMatchNode");

  sub contains {
    my ($self, $operand) = @_;
    return $self->add_node("contains", $operand);
  }
  1;
}

{
  package Net::Braintree::RangeNode;
  use Moo;
  extends ("Net::Braintree::EqualityNode");

  use overload ( '>=' => 'min', '<=' => 'max');

  sub min {
    my ($self, $operand) = @_;
    return $self->add_node("min", $operand);
  }

  sub max {
    my ($self, $operand) = @_;
    return $self->add_node("max", $operand);
  }

  sub between {
    my ($self, $min, $max) = @_;
    $self->max($max);
    $self->min($min);
  }

  1;
}

{
  package Net::Braintree::MultipleValuesNode;
  use Carp;
  use Moo;
  use Net::Braintree::Util;
  extends ("Net::Braintree::SearchNode");

  has 'allowed_values' => (is => 'rw');

  sub default_criteria {
    return [];
  }

  sub active {
    my $self = shift;
    return @{$self->criteria};
  }

  sub is {
    shift->in(@_);
  }

  sub _args_to_array {
    my $self = shift;
    my @args;
    if (ref($_[0]) eq 'ARRAY') {
      @args = @{$_[0]};
    } else {
      @args = @_;
    }
    return @args;
  }

  sub in {
    my $self = shift;
    my @values = $self->_args_to_array(@_);

    my $bad_values = difference_arrays(\@values, $self->allowed_values);

    if (@$bad_values && $self->allowed_values)  {
      croak "Invalid Argument(s) for " . $self->name . ": " . join(", ", @$bad_values);
    }

    @{$self->criteria} = @values;
    return $self->searcher;
  }

  1;
}
