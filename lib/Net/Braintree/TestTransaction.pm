package Net::Braintree::TestTransaction;

use strict;
use warnings;

use Moose;
extends 'Net::Braintree::Transaction';

sub settle {
  my $class = shift;
  $class->gateway->testing->settle(shift);
}

sub settlement_confirm {
  my $class = shift;
  $class->gateway->testing->settlement_confirm(shift);
}

sub settlement_decline {
  my $class = shift;
  $class->gateway->testing->settlement_decline(shift);
}

sub settlement_pending {
  my $class = shift;
  $class->gateway->testing->settlement_pending(shift);
}

1;
