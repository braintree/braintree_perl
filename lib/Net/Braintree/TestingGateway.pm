package Net::Braintree::TestingGateway;

use strict;
use warnings;

use Moose;
use Carp qw/confess/;

extends 'Net::Braintree::TransactionGateway';

sub settle {
  my $self = shift;
  $self->check_environment;
  my $id = shift;
  $self->_make_request("/transactions/$id/settle", "put", undef);
}

sub settlement_confirm {
  my $self = shift;
  $self->check_environment;
  my $id = shift;
  $self->_make_request("/transactions/$id/settlement_confirm", "put", undef);
}

sub settlement_decline {
  my $self = shift;
  $self->check_environment;
  my $id = shift;
  $self->_make_request("/transactions/$id/settlement_decline", "put", undef);
}

sub settlement_pending {
  my $self = shift;
  $self->check_environment;
  my $id = shift;
  $self->_make_request("/transactions/$id/settlement_pending", "put", undef);
}

sub check_environment {
  my $self = shift;
  confess 'TestOperationPerformedInProduction'
    if $self->gateway->config->environment eq 'production';
}

1;
