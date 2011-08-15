package Net::Braintree::ResultObject;
use Net::Braintree::Util qw(is_array is_hash);
use Moose;

my $meta = __PACKAGE__->meta;

sub set_attributes_from_hash {
  my ($self, $target, $attributes) = @_;
  while(my($attribute, $value) = each(%$attributes)) {
    $meta->add_attribute($attribute, is => 'rw');
    $target->$attribute($self->set_attr_value($value));
  }
}

sub set_attr_value {
  my ($self, $value) = @_;

  if(is_hash($value)) {
    return Hash::Inflator->new($value);
  } elsif(is_array($value)) {
    my $new_array = [];
    foreach(@$value) {
      push(@$new_array, $self->set_attr_value($_));
    }
    return $new_array;
  } else {
    return $value;
  }
}

sub setup_sub_objects {
  my($self, $target, $params, $sub_objects) = @_;
  while(my($attribute, $class) = each(%$sub_objects)) {
    $meta->add_attribute($attribute, is => 'rw');
    if (is_array($params->{$attribute})) {
      my $new_array = [];
      foreach my $element (@{$params->{$attribute}}) {
        push(@$new_array, $class->new($element)) if is_hash($element);
      }
      $target->$attribute($new_array);
    } else {
      push(@{$target->$attribute}, $class->new($params->{$attribute})) if is_hash($params->{$attribute});
    }
    delete($params->{$attribute});
  }
}

1;
