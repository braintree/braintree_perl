use lib qw(lib t/lib);
use Test::More;
use Test::Moose;
use Net::Braintree;
use Net::Braintree::TestHelper;
use Net::Braintree::MerchantAccount;
use Net::Braintree::ErrorCodes::MerchantAccount::ApplicantDetails;

subtest 'verify' => sub {
  my $verification_string = Net::Braintree::WebhookNotification->verify("verification_token");
  is $verification_string, "integration_public_key|c9f15b74b0d98635cd182c51e2703cffa83388c3";
};

subtest 'sample_notification creates a parsable signature and payload', sub {
  my ($signature, $payload) = Net::Braintree::WebhookTesting->sample_notification(
    Net::Braintree::WebhookNotification::Kind::SubscriptionWentPastDue,
    "my_id"
  );
  my $webhook_notification = Net::Braintree::WebhookNotification->parse($signature, $payload);

  is $webhook_notification->kind, Net::Braintree::WebhookNotification::Kind::SubscriptionWentPastDue;
  isnt $webhook_notification->timestamp, undef;
  is $webhook_notification->subscription->id, "my_id";
};

subtest 'sample_notification throws InvalidSignature error if the signature is modified', sub {
  should_throw("InvalidSignature", sub {
    my ($signature, $payload) = Net::Braintree::WebhookTesting->sample_notification(
      Net::Braintree::WebhookNotification::Kind::SubscriptionWentPastDue,
      "my_id"
    );
    my $webhook_notification = Net::Braintree::WebhookNotification->parse($signature . "bad", $payload);
  }, "signature is invalid");
};

subtest 'sample_notification throws InvalidSignature error the public key is modified', sub {
  should_throw("InvalidSignature", sub {
    my ($signature, $payload) = Net::Braintree::WebhookTesting->sample_notification(
      Net::Braintree::WebhookNotification::Kind::SubscriptionWentPastDue,
      "my_id"
    );
    my $webhook_notification = Net::Braintree::WebhookNotification->parse("bad" . $signature, $payload);
  }, "signature is invalid");
};

subtest 'sample_notification throws InvalidSignature error if the signature is invalid', sub {
  should_throw("InvalidSignature", sub {
    my ($signature, $payload) = Net::Braintree::WebhookTesting->sample_notification(
      Net::Braintree::WebhookNotification::Kind::SubscriptionWentPastDue,
      "my_id"
    );
    my $webhook_notification = Net::Braintree::WebhookNotification->parse("bad", $payload);
  }, "signature is invalid");
};

subtest 'sample_notification creates a sample notification for an approved merchant account via webhook', sub {
  my ($signature, $payload) = Net::Braintree::WebhookTesting->sample_notification(
    Net::Braintree::WebhookNotification::Kind::SubMerchantAccountApproved,
    "my_id"
  );
  my $webhook_notification = Net::Braintree::WebhookNotification->parse($signature, $payload);

  is $webhook_notification->kind, Net::Braintree::WebhookNotification::Kind::SubMerchantAccountApproved;
  is $webhook_notification->merchant_account->id, "my_id";
  is $webhook_notification->merchant_account->status, Net::Braintree::MerchantAccount::Status::Active;
  is $webhook_notification->merchant_account->master_merchant_account->id, "master_ma_for_my_id";
  is $webhook_notification->merchant_account->master_merchant_account->status, Net::Braintree::MerchantAccount::Status::Active;
};

subtest 'sample_notification builds a sample notification for a merchant account declined webhook', sub {
  my ($signature, $payload) = Net::Braintree::WebhookTesting->sample_notification(
    Net::Braintree::WebhookNotification::Kind::SubMerchantAccountDeclined,
    "my_id"
  );

  my $webhook_notification = Net::Braintree::WebhookNotification->parse($signature, $payload);

  is $webhook_notification->kind, Net::Braintree::WebhookNotification::Kind::SubMerchantAccountDeclined;
  is $webhook_notification->merchant_account->id, "my_id";
  is $webhook_notification->merchant_account->status, Net::Braintree::MerchantAccount::Status::Suspended;
  is $webhook_notification->merchant_account->master_merchant_account->id, "master_ma_for_my_id";
  is $webhook_notification->merchant_account->master_merchant_account->status, Net::Braintree::MerchantAccount::Status::Suspended;
  is $webhook_notification->message, "Credit score is too low";
  is $webhook_notification->errors->for('merchant_account')->on('base')->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::ApplicantDetails::DeclinedOFAC;
};

subtest 'sample_notification builds a sample notification for disbursed transaction', sub {
  my ($signature, $payload) = Net::Braintree::WebhookTesting->sample_notification(
    Net::Braintree::WebhookNotification::Kind::TransactionDisbursed,
    "my_id"
  );

  my $webhook_notification = Net::Braintree::WebhookNotification->parse($signature, $payload);

  is $webhook_notification->kind, Net::Braintree::WebhookNotification::Kind::TransactionDisbursed;
  is $webhook_notification->transaction->id, "my_id";
  is $webhook_notification->transaction->amount, 100;
  isnt $webhook_notification->transaction->disbursement_details->disbursement_date, undef;
};

subtest 'sample_notification builds a sample notification for partner merchant connected', sub {
  my ($signature, $payload) = Net::Braintree::WebhookTesting->sample_notification(
    Net::Braintree::WebhookNotification::Kind::PartnerMerchantConnected,
    "my_id"
  );

  my $webhook_notification = Net::Braintree::WebhookNotification->parse($signature, $payload);

  is $webhook_notification->kind, Net::Braintree::WebhookNotification::Kind::PartnerMerchantConnected;
  is $webhook_notification->partner_merchant->partner_merchant_id, "abc123";
  is $webhook_notification->partner_merchant->merchant_public_id, "public_id";
  is $webhook_notification->partner_merchant->public_key, "public_key";
  is $webhook_notification->partner_merchant->private_key, "private_key";
  is $webhook_notification->partner_merchant->client_side_encryption_key, "cse_key";
};

subtest 'sample_notification builds a sample notification for partner merchant disconnected', sub {
  my ($signature, $payload) = Net::Braintree::WebhookTesting->sample_notification(
    Net::Braintree::WebhookNotification::Kind::PartnerMerchantDisconnected,
    "my_id"
  );

  my $webhook_notification = Net::Braintree::WebhookNotification->parse($signature, $payload);

  is $webhook_notification->kind, Net::Braintree::WebhookNotification::Kind::PartnerMerchantDisconnected;
  is $webhook_notification->partner_merchant->partner_merchant_id, "abc123";
};

subtest 'sample_notification builds a sample notification for partner merchant declined', sub {
  my ($signature, $payload) = Net::Braintree::WebhookTesting->sample_notification(
    Net::Braintree::WebhookNotification::Kind::PartnerMerchantDeclined,
    "my_id"
  );

  my $webhook_notification = Net::Braintree::WebhookNotification->parse($signature, $payload);

  is $webhook_notification->kind, Net::Braintree::WebhookNotification::Kind::PartnerMerchantDeclined;
  is $webhook_notification->partner_merchant->partner_merchant_id, "abc123";
};

done_testing();
