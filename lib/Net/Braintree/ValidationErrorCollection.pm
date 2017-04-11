package Net::Braintree::ValidationErrorCollection;

use Moo;
use Net::Braintree::Util;
use Net::Braintree::ValidationError;

has 'deep_errors' => (is => 'ro', lazy => 1, builder => '_deep_errors');

sub BUILD {
  my ($self, $args) = @_;

  $self->{_errors} = [ map { Net::Braintree::ValidationError->new($_) } @{$args->{errors}} ];
  $self->{_nested} = {};

  while (my ($key, $value) = each %$args) {
    next if $key eq 'errors';
    $self->{_nested}->{$key} = __PACKAGE__->new($value);
  }
}

sub _deep_errors {
  my $self = shift;
  my @nested = map { @{$_->deep_errors} } values %{$self->{_nested}};
  return [ @{$self->{_errors}}, @nested ];
}

sub for {
  my ($self, $target) = @_;
  return $self->{_nested}->{$target};
}

sub on {
  my ($self, $attribute) = @_;
  return [ grep { $_->attribute eq $attribute } @{$self->{_errors}} ]
}

1;
