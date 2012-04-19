use lib qw(lib t/lib);
use Net::Braintree;
use Test::More;
use Test::Moose;
use Net::Braintree::TestHelper;

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

done_testing();
