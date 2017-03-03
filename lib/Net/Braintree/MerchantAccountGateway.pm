package Net::Braintree::MerchantAccountGateway;
use Moo;
use Carp qw(confess);
use Net::Braintree::Validations qw(verify_params);
use Net::Braintree::Util qw(validate_id);
use Net::Braintree::Result;

has 'gateway' => (is => 'ro');

sub create {
  my ($self, $params) = @_;
  confess "ArgumentError" unless verify_params($params, _detect_signature($params));
  $self->_make_request("/merchant_accounts/create_via_api", "post", {merchant_account => $params});
}

sub update {
	my ($self, $merchant_account_id, $params) = @_;
	confess "ArgumentError" unless verify_params($params, _update_signature());
	$self->_make_request("/merchant_accounts/${merchant_account_id}/update_via_api", "put", {merchant_account => $params});
}

sub find {
  my ($self, $id) = @_;
  confess "NotFoundError" unless validate_id($id);
  my $result = $self->_make_request("/merchant_accounts/$id", "get", undef)->merchant_account;
}

sub _make_request {
  my($self, $path, $verb, $params) = @_;
  my $response = $self->gateway->http->$verb($path, $params);
  my $result = Net::Braintree::Result->new(response => $response);
  return $result;
}

sub _detect_signature {
	my ($params) = @_;
	if (ref($params->{applicant_details}) eq 'HASH') {
		warnings::warnif("deprecated", "[DEPRECATED] Passing applicant_details to create is deprecated. Please use individual, business, and funding.");
		return _deprecated_create_signature();
	} else {
		return _create_signature();
	}
}

sub _deprecated_create_signature{
  return {
    applicant_details => {
      company_name => ".",
      first_name => ".",
      last_name => ".",
      email => ".",
      phone => ".",
      date_of_birth => ".",
      ssn => ".",
      tax_id => ".",
      routing_number => ".",
      account_number => ".",
      address => {
        street_address => ".",
        postal_code => ".",
        locality => ".",
        region => ".",
      }
    },
    tos_accepted => ".",
    master_merchant_account_id => ".",
    id => "."
  };
}

sub _create_signature{
  return {
    individual => {
      first_name => ".",
      last_name => ".",
      email => ".",
      phone => ".",
      date_of_birth => ".",
      ssn => ".",
      address => {
        street_address => ".",
        postal_code => ".",
        locality => ".",
        region => ".",
      }
    },
    business => {
      legal_name => ".",
      dba_name => ".",
      tax_id => ".",
      address => {
        street_address => ".",
        postal_code => ".",
        locality => ".",
        region => ".",
      }
    },
    funding => {
      destination => ".",
      email => ".",
      mobile_phone => ".",
      routing_number => ".",
      account_number => ".",
      descriptor => ".",
    },
    tos_accepted => ".",
    master_merchant_account_id => ".",
    id => "."
  };
}

sub _update_signature{
  return {
    individual => {
      first_name => ".",
      last_name => ".",
      email => ".",
      phone => ".",
      date_of_birth => ".",
      ssn => ".",
      address => {
        street_address => ".",
        postal_code => ".",
        locality => ".",
        region => ".",
      }
    },
    business => {
      legal_name => ".",
      dba_name => ".",
      tax_id => ".",
      address => {
        street_address => ".",
        postal_code => ".",
        locality => ".",
        region => ".",
      }
    },
    funding => {
      destination => ".",
      email => ".",
      mobile_phone => ".",
      routing_number => ".",
      account_number => ".",
      descriptor => ".",
    },
    master_merchant_account_id => ".",
    id => "."
  };
}

__PACKAGE__->meta->make_immutable;
1;
