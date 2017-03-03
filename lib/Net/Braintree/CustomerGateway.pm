package Net::Braintree::CustomerGateway;
use Moose;
use Carp qw(confess);
use Net::Braintree::Validations qw(verify_params customer_signature);
use Net::Braintree::Util qw(validate_id);
use Net::Braintree::Result;
use Net::Braintree::Util;

has 'gateway' => (is => 'ro');

sub create {
  my ($self, $params) = @_;
  confess "ArgumentError" unless verify_params($params, customer_signature);
  $self->_make_request("/customers/", 'post', { customer => $params });
}

sub find {
  my ($self, $id) = @_;
  confess "NotFoundError" unless validate_id($id);
  $self->_make_request("/customers/$id", 'get', undef)->customer;
}

sub delete {
  my ($self, $id) = @_;
  $self->_make_request("/customers/$id", "delete", undef);
}

sub update {
  my ($self, $id, $params) = @_;
  confess "ArgumentError" unless verify_params($params, customer_signature);
  $self->_make_request("/customers/$id", 'put', {customer => $params});
}

sub search {
  my ($self, $block) = @_;
  my $search = Net::Braintree::CustomerSearch->new;
  my $params = $block->($search)->to_hash;
  my $response = $self->gateway->http->post("/customers/advanced_search_ids", {search => $params});
  return Net::Braintree::ResourceCollection->new()->init($response, sub {
    $self->fetch_customers($search, shift);
  });
}

sub all {
  my $self = shift;
  my $response = $self->gateway->http->post("/customers/advanced_search_ids");
  return Net::Braintree::ResourceCollection->new()->init($response, sub {
    $self->fetch_customers(Net::Braintree::CustomerSearch->new, shift);
  });
}

sub _make_request {
  my($self, $path, $verb, $params) = @_;
  my $response = $self->gateway->http->$verb($path, $params);
  my $result = Net::Braintree::Result->new(response => $response);
  return $result;
}

sub fetch_customers {
  my ($self, $search, $ids) = @_;
  $search->ids->in($ids);
  my @result = ();
  return [] if scalar @{$ids} == 0;
  my $response = $self->gateway->http->post( "/customers/advanced_search/", {search => $search->to_hash});
  my $attrs = $response->{'customers'}->{'customer'};
  return to_instance_array($attrs, "Net::Braintree::Customer");
}


__PACKAGE__->meta->make_immutable;
1;

