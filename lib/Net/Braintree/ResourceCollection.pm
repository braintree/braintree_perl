package Net::Braintree::ResourceCollection;
use Moose;
extends "Net::Braintree::ResultObject";

has 'response' => (is => 'rw');
has 'ids' => (is => 'rw');
has 'page_size' => (is => 'rw');
has 'callback' => (is => 'rw');

sub init {
  my ($self, $response, $callback) = @_;
  $self->response($response);
  $self->ids($response->{search_results}->{ids});
  $self->page_size($response->{search_results}->{page_size});
  $self->callback($callback);
  return $self;
}

sub is_success {
  my $self = shift;
  return 1 unless $self->response->{'api_error_response'};
  return 0;
}

sub first {
  my $self = shift;
  return undef if $self->is_empty;
  my $first_id = $self->ids->[0];
  return $self->callback->([$first_id])->[0];
}

sub is_empty {
  my $self = shift;
  $self->maximum_size == 0;
}

sub maximum_size {
  my $self = shift;
  return (scalar @{$self->ids});
}

sub each {
  my ($self, $block) = @_;
  my @page = ();

  for(my $count = 0; $count < $self->maximum_size; $count++) {
    push(@page, $self->ids->[$count]);
    if((scalar @page) == $self->page_size) {
      $self->execute_block_for_page($block, @page);
      @page = ();
    }
  }

  $self->execute_block_for_page($block, @page) if(scalar(@page) > 0);
}

sub execute_block_for_page {
  my ($self, $block, @page) = @_;
  my $resources = $self->callback->([@page]);
  for my $resource (@$resources) {
    $block->($resource);
  }
}

1;
