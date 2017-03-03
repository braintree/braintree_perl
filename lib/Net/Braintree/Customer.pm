package Net::Braintree::Customer;
use Moo;
extends 'Net::Braintree::ResultObject';


sub BUILD {
  my ($self, $attributes) = @_;
  my $sub_objects = {
    credit_cards => "Net::Braintree::CreditCard",
    addresses => "Net::Braintree::Address",
    paypal_accounts => "Net::Braintree::PayPalAccount"
  };

  $self->setup_sub_objects($self, $attributes, $sub_objects);
  $self->set_attributes_from_hash($self, $attributes);
}

sub payment_methods {
  my $self = shift;
  my @pmt_methods;
  if (defined($self->credit_cards)) {
    foreach my $credit_card (@{$self->credit_cards}) {
      push @pmt_methods, $credit_card;
    }
  }

  if (defined($self->paypal_accounts)) {
    foreach my $paypal_account (@{$self->paypal_accounts}) {
      push @pmt_methods, $paypal_account;
    }
  }

  return \@pmt_methods;
}

sub create {
  my ($class, $params) = @_;
  $class->gateway->customer->create($params);
}

sub find {
  my($class, $id) = @_;
  $class->gateway->customer->find($id);
}

sub delete {
  my ($class, $id) = @_;
  $class->gateway->customer->delete($id);
}

sub update {
  my ($class, $id, $params) = @_;
  $class->gateway->customer->update($id, $params);
}

sub search {
  my ($class, $block) = @_;
  $class->gateway->customer->search($block);
}

sub all {
  my ($class) = @_;
  $class->gateway->customer->all;
}

sub gateway {
  return Net::Braintree->configuration->gateway;
}

1;
