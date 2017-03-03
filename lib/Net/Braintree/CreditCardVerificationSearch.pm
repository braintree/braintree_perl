package Net::Braintree::CreditCardVerificationSearch;
use Moo;
use Net::Braintree::CreditCard::CardType;
use Net::Braintree::AdvancedSearch qw(search_to_hash);
my $meta = __PACKAGE__->meta();

my $field = Net::Braintree::AdvancedSearchFields->new(metaclass => $meta);
$field->text("id");
$field->text("credit_card_cardholder_name");
$field->equality("credit_card_expiration_date");
$field->partial_match("credit_card_number");
$field->multiple_values("ids");

$field->multiple_values("credit_card_card_type", @{Net::Braintree::CreditCard::CardType::All()});

$field->range("created_at");

sub to_hash {
  Net::Braintree::AdvancedSearch->search_to_hash(shift);
}

1;
