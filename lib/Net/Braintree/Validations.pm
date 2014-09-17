package Net::Braintree::Validations;
use strict;

use Net::Braintree::Util;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS );
use Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(verify_params address_signature client_token_signature_with_customer_id client_token_signature_without_customer_id credit_card_signature customer_signature transaction_signature clone_transaction_signature merchant_account_signature transaction_search_results_signature);

sub verify_params {
  my ($params, $white_list) = @_;
  foreach(keys %$params) {
    my $key = $_;
    my $sub_white_list = $white_list-> {$key};
    return 0 unless($sub_white_list);
    if (is_hashref($sub_white_list)) {
      return 0 unless verify_params($params->{$key}, $sub_white_list);
    } elsif (is_hashref($params->{$key})) {
      return 0 if $sub_white_list ne "_any_key_";
    }
  }
  return 1;
}

sub search_results_signature {
  return {
    page_size => ".",
    ids => "."
  };
}

sub transaction_search_results_signature {
  return {
    search_results => search_results_signature
  };
}

sub address_signature {
  return {
    company => ".", country_code_alpha2 => ".", country_code_alpha3 => ".", country_code_numeric => ".",
    country_name => ".", extended_address => ".", first_name => ".",
    options => { update_existing => "." },
    last_name => ".", locality => ".", postal_code => ".", region => ".", street_address => "."
  };
}

sub client_token_signature_with_customer_id {
  return {
    customer_id => ".",
    proxy_merchant_id => ".",
    version => ".",
    options => {
      make_default => ".",
      fail_on_duplicate_payment_method => ".",
      verify_card => "."
    },
    merchant_account_id => "."
  };
}

sub client_token_signature_without_customer_id {
  return {
    proxy_merchant_id => ".",
    version => ".",
    merchant_account_id => "."
  };
}

sub credit_card_signature {
  return {
    customer_id => ".",
    billing_address_id => ".", cardholder_name => ".", cvv => ".", expiration_date => ".",
    expiration_month => ".", expiration_year => ".", number => ".", token => ".",
    venmo_sdk_payment_method_code => ".",
    payment_method_nonce => ".",
    device_session_id => ".",
    device_data => ".",
    fraud_merchant_id => ".",
    options => {
      make_default => ".",
      verification_merchant_account_id => ".",
      verify_card => ".",
      update_existing_token => ".",
      fail_on_duplicate_payment_method => ".",
      venmo_sdk_session => "."
    },
    billing_address => address_signature
  };
}

sub customer_signature {
  return {
    company => ".", email => ".", fax => ".", first_name => ".", id => ".", last_name => ".", phone => ".", website => ".", device_data => ".",
    device_session_id => ".", fraud_merchant_id => ".",
    credit_card => credit_card_signature,
    payment_method_nonce => ".",
    custom_fields => "_any_key_"
  };
}

sub clone_transaction_signature {
  return { amount => ".", "channel" => ".", options => { submit_for_settlement => "." } };
}

sub transaction_signature{
  return {
    amount => ".", customer_id => ".", merchant_account_id => ".", order_id => ".", channel => ".", payment_method_token => ".",
    "payment_method_nonce" => ".", "device_session_id" => ".", "device_data" => ".", fraud_merchant_id => ".", billing_address_id => ".",
    purchase_order_number => ".", recurring => ".", shipping_address_id => ".", type => ".", tax_amount => ".", tax_exempt => ".",
    credit_card => {token => ".", cardholder_name => ".", cvv => ".", expiration_date => ".", expiration_month => ".", expiration_year => ".", number => "."},
    customer => {id => ".", company => ".", email => ".", fax => ".", first_name => ".", last_name => ".", phone => ".", website => "."} ,
    billing => address_signature,
    shipping => address_signature,
    options => {
      store_in_vault => ".",
      store_in_vault_on_success => ".",
      submit_for_settlement => ".",
      add_billing_address_to_payment_method => ".",
      store_shipping_address_in_vault => ".",
      venmo_sdk_session => ".",
      hold_in_escrow => ".",
      payee_email => "."
    },
    paypal_account => {
      payee_email => "."
    },
    custom_fields => "_any_key_",
    descriptor => {name => ".", phone => ".", url => "."},
    subscription_id => ".",
    venmo_sdk_payment_method_code => ".",
    service_fee_amount => ".",
    three_d_secure_token => "."
  };
}

1;
