package Net::Braintree::SubscriptionSearch;
use Moose;
use Net::Braintree::AdvancedSearch qw(search_to_hash);

my $field = Net::Braintree::AdvancedSearchFields->new(metaclass => __PACKAGE__->meta);

$field->text("id");
$field->text("transaction_id");
$field->text("plan_id");

$field->multiple_values("in_trial_period");
$field->multiple_values("status", Net::Braintree::Subscription::Status::All);
$field->multiple_values("merchant_account_id");
$field->multiple_values("ids");

$field->range("price");
$field->range("days_past_due");
$field->range("billing_cycles_remaining");
$field->range("next_billing_date");

sub to_hash {
  Net::Braintree::AdvancedSearch->search_to_hash(shift);
}

__PACKAGE__->meta->make_immutable;
1;
