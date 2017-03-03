package Net::Braintree::CreditCardVerificationGateway;
use Moo;
use Net::Braintree::CreditCardVerificationSearch;
use Net::Braintree::Util;
use Carp qw(confess);

has 'gateway' => (is => 'ro');

sub find {
  my ($self, $id) = @_;
  confess "NotFoundError" unless validate_id($id);
  my $response = $self->gateway->http->get("/verifications/$id");
  return Net::Braintree::CreditCardVerification->new($response->{'verification'});
}

sub search {
  my ($self, $block) = @_;
  my $search = Net::Braintree::CreditCardVerificationSearch->new;
  my $params = $block->($search)->to_hash;
  my $response = $self->gateway->http->post("/verifications/advanced_search_ids", {search => $params});
  return Net::Braintree::ResourceCollection->new()->init($response, sub {
    $self->fetch_verifications($search, shift);
  });
}

sub all {
  my $self = shift;
  my $response = $self->gateway->http->post("/verifications/advanced_search_ids");
  return Net::Braintree::ResourceCollection->new()->init($response, sub {
    $self->fetch_verifications(Net::Braintree::CreditCardVerificationSearch->new, shift);
  });
}

sub fetch_verifications {
  my ($self, $search, $ids) = @_;
  $search->ids->in($ids);
  return [] if scalar @{$ids} == 0;
  my $response = $self->gateway->http->post("/verifications/advanced_search/", {search => $search->to_hash});
  my $attrs = $response->{'credit_card_verifications'}->{'verification'};
  return to_instance_array($attrs, "Net::Braintree::CreditCardVerification");
}

__PACKAGE__->meta->make_immutable;
1;
