package Net::Braintree::MockHTTP;

use Moose;

has method => (is => 'rw' );
has result => ( is => 'rw' );
has path => ( is => 'rw');
has params => ( is => 'rw' );

sub post {
  my $self = shift;
  $self->path(shift);
  $self->params(shift);
  $self->method('post');
  return $self -> result;
}

sub put {
  my $self = shift;
  $self->path(shift);
  $self->params(shift);
  $self->method("put");
  return $self -> result;
}

sub get {
  my $self = shift;
  $self->path(shift);
  $self->params(shift);
  $self->method("get");
  return $self -> result;
}

sub delete {
  my $self = shift;
  $self->path(shift);
  $self->params(shift);
  $self->method("delete");
  return $self -> result;
}

1;
