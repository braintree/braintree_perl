package Net::Braintree::Configuration;

use Net::Braintree::Gateway;
use Moose;

has merchant_id => (is => 'rw');
has partner_id => (is => 'rw');
has public_key  => (is => 'rw');
has private_key => (is => 'rw');
has gateway => (is  => 'ro', lazy => 1, default => sub { Net::Braintree::Gateway->new({config => shift})});

has environment => (
  is => 'rw',
  trigger => sub {
    my ($self, $new_value, $old_value) = @_;
    if ($new_value !~ /integration|development|sandbox|production|qa/) {
      warn "Assigned invalid value to Net::Braintree::Configuration::environment";
    }
    if ($new_value eq "integration") {
      $self->public_key("integration_public_key");
      $self->private_key("integration_private_key");
      $self->merchant_id("integration_merchant_id");
    }
  }
);

sub base_merchant_path {
  my $self = shift;
  return "/merchants/" . $self->merchant_id;
}

sub base_merchant_url {
  my $self = shift;
  return $self->protocol . "://" . $self->server . ':' . $self->port . $self->base_merchant_path;
}

sub port {
  my $self = shift;
  if($self->environment =~ /integration|development/) {
    return $ENV{'GATEWAY_PORT'} || "3000"
  } else {
    return "443";
  }
}

sub server {
  my $self = shift;
  return "localhost" if $self->environment eq 'integration';
  return "localhost" if $self->environment eq 'development';
  return "sandbox.braintreegateway.com" if $self->environment eq 'sandbox';
  return "www.braintreegateway.com" if $self->environment eq 'production';
  return "qa-master.braintreegateway.com" if $self->environment eq 'qa';
}

sub ssl_enabled {
  my $self = shift;
  return ($self->environment !~ /integration|development/);
}

sub protocol {
  my $self = shift;
  return $self->ssl_enabled ? 'https' : 'http';
}

sub api_version {
  return "3";
}

1;
