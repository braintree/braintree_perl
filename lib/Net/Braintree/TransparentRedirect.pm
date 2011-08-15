package Net::Braintree::TransparentRedirect;
use Moose;

sub confirm {
  my($class, $query_string) = @_;
  $class->gateway->transparent_redirect->confirm($query_string);
}

sub transaction_data {
  my ($class, $params) = @_;
  $class->gateway->transparent_redirect->transaction_data($params);
}

sub create_customer_data {
  my ($class, $params) = @_;
  $class->gateway->transparent_redirect->create_customer_data($params);
}

sub update_customer_data {
  my ($class, $params) = @_;
  $class->gateway->transparent_redirect->update_customer_data($params);
}

sub create_credit_card_data {
  my ($class, $params) = @_;
  $class->gateway->transparent_redirect->create_credit_card_data($params);
}

sub update_credit_card_data {
  my ($class, $params) = @_;
  $class->gateway->transparent_redirect->update_credit_card_data($params);
}

sub url {
  my $class = shift;
  $class->gateway->transparent_redirect->url;
}

sub gateway {
  Net::Braintree->configuration->gateway;
}

1;
