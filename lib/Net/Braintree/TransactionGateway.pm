package Net::Braintree::TransactionGateway;
use Moose;
use Carp qw(confess);
use Net::Braintree::Util qw(validate_id);
use Net::Braintree::Validations qw(verify_params transaction_signature clone_transaction_signature transaction_search_results_signature refund_signature);
use Net::Braintree::Util;

has 'gateway' => (is => 'ro');

sub create {
  my ($self, $params) = @_;
  confess "ArgumentError" unless verify_params($params, transaction_signature);
  $self->_make_request("/transactions/", "post", {transaction => $params});
}

sub find {
  my ($self, $id) = @_;
  confess "NotFoundError" unless validate_id($id);
  $self->_make_request("/transactions/$id", "get", undef);
}

sub retry_subscription_charge {
  my ($self, $subscription_id, $amount) = @_;
  my $params = {
    subscription_id => $subscription_id,
    amount => $amount,
    type => "sale"
  };

  $self->create($params);
}

sub submit_for_settlement {
  my ($self, $id, $params) = @_;
  $self->_make_request("/transactions/$id/submit_for_settlement", "put", {transaction => $params});
}

sub void {
  my ($self, $id) = @_;
  $self->_make_request("/transactions/$id/void", "put", undef);
}

sub refund {
  my ($self, $id, $params) = @_;
  confess 'ArgumentError' unless verify_params($params, refund_signature);
  $self->_make_request("/transactions/$id/refund", "post", {transaction => $params});
}

sub clone_transaction {
  my ($self, $id, $params) = @_;
  confess "ArgumentError" unless verify_params($params, clone_transaction_signature);
  $self->_make_request("/transactions/$id/clone", "post", {transaction_clone => $params});
}

sub search {
  my ($self, $block) = @_;
  my $search = Net::Braintree::TransactionSearch->new;
  my $params = $block->($search)->to_hash;
  my $response = $self->gateway->http->post("/transactions/advanced_search_ids", {search => $params});
  confess "DownForMaintenanceError" unless (verify_params($response, transaction_search_results_signature));
  return Net::Braintree::ResourceCollection->new()->init($response, sub {
    $self->fetch_transactions($search, shift);
  });
}

sub hold_in_escrow {
  my ($self, $id) = @_;
  $self->_make_request("/transactions/$id/hold_in_escrow", "put", undef);
}

sub release_from_escrow {
  my ($self, $id) = @_;
  $self->_make_request("/transactions/$id/release_from_escrow", "put", undef);
}

sub cancel_release {
  my ($self, $id) = @_;
  $self->_make_request("/transactions/$id/cancel_release", "put", undef);
}

sub all {
  my $self = shift;
  my $response = $self->gateway->http->post("/transactions/advanced_search_ids");
  return Net::Braintree::ResourceCollection->new()->init($response, sub {
    $self->fetch_transactions(Net::Braintree::TransactionSearch->new, shift);
  });
}

sub _make_request {
  my($self, $path, $verb, $params) = @_;
  my $response = $self->gateway->http->$verb($path, $params);
  return Net::Braintree::Result->new(response => $response);
}

sub fetch_transactions {
  my ($self, $search, $ids) = @_;
  $search->ids->in($ids);
  return [] if scalar @{$ids} == 0;
  my $response = $self->gateway->http->post("/transactions/advanced_search/", {search => $search->to_hash});
  my $attrs = $response->{'credit_card_transactions'}->{'transaction'};
  return to_instance_array($attrs, "Net::Braintree::Transaction");
}

1;
