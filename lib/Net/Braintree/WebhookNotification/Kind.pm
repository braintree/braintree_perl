package Net::Braintree::WebhookNotification::Kind;
use strict;

use constant SubscriptionCanceled => "subscription_canceled";
use constant SubscriptionChargedSuccessfully => "subscription_charged_successfully";
use constant SubscriptionChargedUnsuccessfully => "subscription_charged_unsuccessfully";
use constant SubscriptionExpired => "subscription_expired";
use constant SubscriptionTrialEnded => "subscription_trial_ended";
use constant SubscriptionWentActive => "subscription_went_active";
use constant SubscriptionWentPastDue => "subscription_went_past_due";

use constant All => (
  SubscriptionCanceled,
  SubscriptionChargedSuccessfully,
  SubscriptionChargedUnsuccessfully,
  SubscriptionExpired,
  SubscriptionTrialEnded,
  SubscriptionWentActive,
  SubscriptionWentPastDue,
);

1;
