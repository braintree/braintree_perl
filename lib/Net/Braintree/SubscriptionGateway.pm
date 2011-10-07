package Net::Braintree::SubscriptionGateway;
use Net::Braintree::Util;

use Moose;

has 'gateway' => (is => 'ro');

sub create {
  my ($self, $params) = @_;
  my $result = $self->_make_request("/subscriptions/", "post", {subscription => $params});
  return $result;
}

sub find {
  my ($self, $id) = @_;
  my $result = $self->_make_request("/subscriptions/$id", "get", undef)->subscription;
}

sub update {
  my ($self, $id, $params) = @_;
  my $result = $self->_make_request("/subscriptions/$id", "put", {subscription => $params});
}

sub cancel {
  my ($self, $id) = @_;
  my $result = $self->_make_request("/subscriptions/$id/cancel", "put", undef);
}

sub _make_request {
  my($self, $path, $verb, $params) = @_;
  my $response = $self->gateway->http->$verb($path, $params);
  my $result = Net::Braintree::Result->new(response => $response);
  return $result;
}

sub search {
  my ($self, $block) = @_;
  my $search = Net::Braintree::SubscriptionSearch->new;
  my $params = $block->($search)->to_hash;
  my $response = $self->gateway->http->post("/subscriptions/advanced_search_ids", {search => $params});
  return Net::Braintree::ResourceCollection->new()->init($response, sub {
    $self->fetch_subscriptions($search, shift);
  });
}

sub all {
  my $self = shift;
  my $response = $self->gateway->http->post("/subscriptions/advanced_search_ids");
  return Net::Braintree::ResourceCollection->new()->init($response, sub {
    $self->fetch_subscriptions(Net::Braintree::SubscriptionSearch->new, shift);
  });
}

sub fetch_subscriptions {
  my ($self, $search, $ids) = @_;
  $search->ids->in($ids);
  return [] if scalar @{$ids} == 0;
  my $response = $self->gateway->http->post("/subscriptions/advanced_search/", {search => $search->to_hash});
  my $attrs = $response->{'subscriptions'}->{'subscription'};
  return to_instance_array($attrs, "Net::Braintree::Subscription");
}
1;
