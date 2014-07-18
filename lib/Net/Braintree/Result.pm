package Net::Braintree::Result;
use Moose;
use Hash::Inflator;
use Net::Braintree::Util;
use Net::Braintree::ValidationErrorCollection;
use Net::Braintree::CreditCardVerification;

my $meta = __PACKAGE__->meta;

my $response_objects = {
  address => "Net::Braintree::Address",
  credit_card => "Net::Braintree::CreditCard",
  customer => "Net::Braintree::Customer",
  merchant_account => "Net::Braintree::MerchantAccount",
  payment_method => {
    credit_card => "Net::Braintree::CreditCard",
    paypal_account => "Net::Braintree::PayPalAccount"
  },
  settlement_batch_summary => "Net::Braintree::SettlementBatchSummary",
  subscription => "Net::Braintree::Subscription",
  transaction => "Net::Braintree::Transaction",
};

has response => ( is => 'ro' );

sub _get_response {
  my $self = shift;
  return $self->response->{'api_error_response'} || $self->response;
}

sub patch_in_response_accessors {
  my $field_rules = shift;
  while (my($key, $rule) = each(%$field_rules)) {
    if (ref($rule) eq "HASH") {
      $meta->add_method($key, sub {
        my $self = shift;
        my $response = $self->_get_response();
        while (my($subkey, $subrule) = each(%$rule)) {
          my $field_value = $self->$subkey;
          if ($field_value) {
            keys %$rule;
            return $field_value;
          }
        }

        return undef;
      });

      patch_in_response_accessors($rule);
    } else {
      $meta->add_method($key, sub {
        my $self = shift;
        my $response = $self->_get_response();
        if (!$response->{$key}) {
          return undef;
        }

        return $rule->new($response->{$key});
      });
    }
  }
}

patch_in_response_accessors($response_objects);

sub is_success {
  my $self = shift;
  return 1 unless $self->response->{'api_error_response'};
  return 0;
}

sub api_error_response {
  my $self = shift;
  return $self->response->{'api_error_response'};
}

sub message {
  my $self = shift;
  return $self->api_error_response->{'message'} if $self->api_error_response;
  return "";
}

sub errors {
  my $self = shift;
  return Net::Braintree::ValidationErrorCollection->new($self->api_error_response->{errors});
}

sub credit_card_verification {
  my $self = shift;
  return Net::Braintree::CreditCardVerification->new($self->api_error_response->{verification});
}

1;
