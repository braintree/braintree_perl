package Net::Braintree::TransactionSearch;
use Moose;
use Net::Braintree::AdvancedSearch qw(search_to_hash);
my $meta = __PACKAGE__->meta();

my $field = Net::Braintree::AdvancedSearchFields->new(metaclass => $meta);

$field->text("billing_company");
$field->text("billing_country_name");
$field->text("billing_extended_address");
$field->text("billing_first_name");
$field->text("billing_last_name");
$field->text("billing_locality");
$field->text("billing_postal_code");
$field->text("billing_region");
$field->text("billing_street_address");
$field->text("credit_card_cardholder_name");
$field->text("currency");
$field->text("customer_company");
$field->text("customer_email");
$field->text("customer_fax");
$field->text("customer_first_name");
$field->text("customer_id");
$field->text("customer_last_name");
$field->text("customer_phone");
$field->text("customer_website");
$field->text("id");
$field->text("order_id");
$field->text("payment_method_token");
$field->text("paypal_payment_id");
$field->text("paypal_authorization_id");
$field->text("paypal_payer_email");
$field->text("processor_authorization_code");
$field->text("settlement_batch_id");
$field->text("shipping_company");
$field->text("shipping_country_name");
$field->text("shipping_extended_address");
$field->text("shipping_first_name");
$field->text("shipping_last_name");
$field->text("shipping_locality");
$field->text("shipping_postal_code");
$field->text("shipping_region");
$field->text("shipping_street_address");

$field->equality("credit_card_expiration_date");

$field->partial_match("credit_card_number");

$field->multiple_values("created_using", Net::Braintree::Transaction::CreatedUsing::FullInformation, Net::Braintree::Transaction::CreatedUsing::Token);
$field->multiple_values("credit_card_card_type", @{Net::Braintree::CreditCard::CardType::All()});
$field->multiple_values("credit_card_customer_location", Net::Braintree::CreditCard::Location::International, Net::Braintree::CreditCard::Location::US);
$field->multiple_values("ids");
$field->multiple_values("merchant_account_id");
$field->multiple_values("status", Net::Braintree::Transaction::Status::All);
$field->multiple_values("source", @{Net::Braintree::Transaction::Source::All()});
$field->multiple_values("type", @{Net::Braintree::Transaction::Type::All()});

$field->key_value("refund");

$field->range("amount");
$field->range("created_at");
$field->range("disbursement_date");
$field->range("dispute_date");
$field->range("authorization_expired_at");
$field->range("authorized_at");
$field->range("failed_at");
$field->range("gateway_rejected_at");
$field->range("processor_declined_at");
$field->range("settled_at");
$field->range("submitted_for_settlement_at");
$field->range("voided_at");

sub to_hash {
  Net::Braintree::AdvancedSearch->search_to_hash(shift);
}

1;
