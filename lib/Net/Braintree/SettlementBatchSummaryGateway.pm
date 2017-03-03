package Net::Braintree::SettlementBatchSummaryGateway;
use Moo;
use Carp qw(confess);

has 'gateway' => (is => 'ro');

sub generate {
  my ($self, $settlement_date, $group_by_custom_field) = @_;
  my $params = {
    settlement_date => $settlement_date
  };
  $params->{group_by_custom_field} = $group_by_custom_field if $group_by_custom_field;

  $self->_make_request("/settlement_batch_summary/", "post", {settlement_batch_summary => $params});
}

sub _make_request {
  my($self, $path, $verb, $params) = @_;
  my $response = $self->gateway->http->$verb($path, $params);
  my $result = Net::Braintree::Result->new(response => $response);
  return $result;
}

__PACKAGE__->meta->make_immutable;
1;
