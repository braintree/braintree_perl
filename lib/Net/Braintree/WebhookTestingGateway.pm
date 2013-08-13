package Net::Braintree::WebhookTestingGateway;

use MIME::Base64;
use POSIX qw(strftime);
use Net::Braintree::Digest qw(hexdigest);
use Net::Braintree::WebhookNotification::Kind;
use Moose;
use Switch;

has 'gateway' => (is => 'ro');

sub sample_notification {
  my ($self, $kind, $id) = @_;

  my $sample_xml = $self->_sample_xml($kind, $id);
  my $payload = encode_base64($sample_xml);
  my $signature = $self->gateway->config->public_key . "|" . hexdigest($self->gateway->config->private_key, $payload);

  return ($signature, $payload);
}

sub _sample_xml {
  my ($self, $kind, $id) = @_;
  my $subject_sample_xml = $self->_subject_sample_xml($kind, $id);
  my $timestamp = strftime("%Y-%m-%dT%H:%M:%SZ", gmtime());

  return <<XML
    <notification>
      <timestamp type="datetime">$timestamp</timestamp>
      <kind>$kind</kind>
      <subject>$subject_sample_xml</subject>
    </notification>
XML
}

sub _subject_sample_xml {
  my ($self, $kind, $id) = @_;

  switch ($kind) {
   case Net::Braintree::WebhookNotification::Kind::TransactionDisbursed { return $self->_transaction_disbursed_sample_xml($id) }
   case Net::Braintree::WebhookNotification::Kind::SubMerchantAccountApproved { return $self->_merchant_account_approved_sample_xml($id) }
   case Net::Braintree::WebhookNotification::Kind::SubMerchantAccountDeclined { return $self->_merchant_account_declined_sample_xml($id) }
   else { return $self->_subscription_sample_xml($id) }
  }
}

sub _transaction_disbursed_sample_xml {
  my ($self, $id) = @_;

  return <<XML
    <transaction>
      <id>$id</id>
      <amount>100</amount>
      <disbursement-details>
        <disbursement-date type="datetime">2013-07-09T18:23:29Z</disbursement-date>
      </disbursement-details>
    </transaction>
XML
};

sub _merchant_account_approved_sample_xml {
  my ($self, $id) = @_;

  return <<XML
    <merchant_account>
      <id>$id</id>
      <master_merchant_account>
        <id>master_ma_for_$id</id>
        <status>active</status>
      </master_merchant_account>
      <status>active</status>
    </merchant_account>
XML
};

sub _merchant_account_declined_sample_xml {
  my ($self, $id) = @_;

  return <<XML
        <api-error-response>
            <message>Credit score is too low</message>
            <errors>
                <errors type="array"/>
                    <merchant-account>
                        <errors type="array">
                            <error>
                                <code>82621</code>
                                <message>Credit score is too low</message>
                                <attribute type="symbol">base</attribute>
                            </error>
                        </errors>
                    </merchant-account>
                </errors>
                <merchant-account>
                    <id>$id</id>
                    <status>suspended</status>
                    <master-merchant-account>
                        <id>master_ma_for_$id</id>
                        <status>suspended</status>
                    </master-merchant-account>
                </merchant-account>
        </api-error-response>
XML
};

sub _subscription_sample_xml {
  my ($self, $id) = @_;

  return <<XML
    <subscription>
      <id>$id</id>
      <transactions type="array">
      </transactions>
      <add_ons type="array">
      </add_ons>
      <discounts type="array">
      </discounts>
    </subscription>
XML
}

1;
