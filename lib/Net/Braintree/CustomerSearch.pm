package Net::Braintree::CustomerSearch;
use Moose;
use Net::Braintree::AdvancedSearch qw(search_to_hash);
my $meta = __PACKAGE__->meta();

my $field = Net::Braintree::AdvancedSearchFields->new(metaclass => $meta);
$field->text("address_country_name");
$field->text("address_extended_address");
$field->text("address_first_name");
$field->text("address_last_name");
$field->text("address_locality");
$field->text("address_postal_code");
$field->text("address_region");
$field->text("address_street_address");
$field->text("cardholder_name");
$field->text("company");
$field->text("email");
$field->text("fax");
$field->text("first_name");
$field->text("id");
$field->text("last_name");
$field->text("payment_method_token");
$field->text("phone");
$field->text("website");

$field->is("payment_method_token_with_duplicates");
$field->equality("credit_card_expiration_date");
$field->partial_match("credit_card_number");
$field->multiple_values("ids");
$field->range("created_at");

sub to_hash {
  Net::Braintree::AdvancedSearch->search_to_hash(shift);
}

1;

