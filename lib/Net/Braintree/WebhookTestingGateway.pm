package Net::Braintree::WebhookTestingGateway;

use MIME::Base64;
use POSIX qw(strftime);
use Net::Braintree::Digest qw(hexdigest);
use Net::Braintree::WebhookNotification::Kind;
use Moose;

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

  my $dispatch = {
    Net::Braintree::WebhookNotification::Kind::TransactionDisbursed => sub { _transaction_disbursed_sample_xml(@_) },
    Net::Braintree::WebhookNotification::Kind::DisbursementException => sub { _disbursement_exception_sample_xml(@_) },
    Net::Braintree::WebhookNotification::Kind::Disbursement => sub { _disbursement_sample_xml(@_) },
    Net::Braintree::WebhookNotification::Kind::SubMerchantAccountApproved => sub { _merchant_account_approved_sample_xml(@_) },
    Net::Braintree::WebhookNotification::Kind::SubMerchantAccountDeclined => sub { _merchant_account_declined_sample_xml(@_) },
    Net::Braintree::WebhookNotification::Kind::PartnerMerchantConnected => sub { _partner_merchant_connected_sample_xml(@_) },
    Net::Braintree::WebhookNotification::Kind::PartnerMerchantDisconnected => sub { _partner_merchant_disconnected_sample_xml(@_) },
    Net::Braintree::WebhookNotification::Kind::PartnerMerchantDeclined => sub { _partner_merchant_declined_sample_xml(@_) },
    Net::Braintree::WebhookNotification::Kind::DisputeOpened => sub { _dispute_opened_sample_xml(@_) },
    Net::Braintree::WebhookNotification::Kind::DisputeLost => sub { _dispute_lost_sample_xml(@_) },
    Net::Braintree::WebhookNotification::Kind::DisputeWon => sub { _dispute_won_sample_xml(@_) }
  };

  my $templater = $dispatch->{$kind} || sub { _subscription_sample_xml(@_) };

  return $templater->($id);
}

sub _transaction_disbursed_sample_xml {
  my $id = shift;

  return <<XML
    <transaction>
      <id>$id</id>
      <amount>100</amount>
      <disbursement-details>
        <disbursement-date type="date">2013-07-09</disbursement-date>
      </disbursement-details>
    </transaction>
XML
};

sub _dispute_opened_sample_xml {
  my $id = shift;

  return <<XML
    <dispute>
      <amount>250.00</amount>
      <currency-iso-code>USD</currency-iso-code>
      <received-date type="date">2014-03-01</received-date>
      <reply-by-date type="date">2014-03-21</reply-by-date>
      <status>open</status>
      <reason>fraud</reason>
      <id>$id</id>
      <transaction>
        <id>$id</id>
        <amount>250.00</amount>
      </transaction>
    </dispute>
XML
};

sub _dispute_lost_sample_xml {
  my $id = shift;

  return <<XML
    <dispute>
      <amount>250.00</amount>
      <currency-iso-code>USD</currency-iso-code>
      <received-date type="date">2014-03-01</received-date>
      <reply-by-date type="date">2014-03-21</reply-by-date>
      <status>lost</status>
      <reason>fraud</reason>
      <id>$id</id>
      <transaction>
        <id>$id</id>
        <amount>250.00</amount>
      </transaction>
    </dispute>
XML
};

sub _dispute_won_sample_xml {
  my $id = shift;

  return <<XML
    <dispute>
      <amount>250.00</amount>
      <currency-iso-code>USD</currency-iso-code>
      <received-date type="date">2014-03-01</received-date>
      <reply-by-date type="date">2014-03-21</reply-by-date>
      <status>won</status>
      <reason>fraud</reason>
      <id>$id</id>
      <transaction>
        <id>$id</id>
        <amount>250.00</amount>
      </transaction>
    </dispute>
XML
};

sub _disbursement_exception_sample_xml {
  my $id = shift;

  return <<XML
    <disbursement>
      <id>$id</id>
      <transaction-ids type="array">
        <item>afv56j</item>
        <item>kj8hjk</item>
      </transaction-ids>
      <success type="boolean">false</success>
      <retry type="boolean">false</retry>
      <merchant-account>
        <id>merchant_account_token</id>
        <currency-iso-code>USD</currency-iso-code>
        <sub-merchant-account type="boolean">false</sub-merchant-account>
        <status>active</status>
      </merchant-account>
      <amount>100.00</amount>
      <disbursement-date type="date">2014-02-10</disbursement-date>
      <exception-message>bank_rejected</exception-message>
      <follow-up-action>update_funding_information</follow-up-action>
    </disbursement>
XML
};

sub _disbursement_sample_xml {
  my $id = shift;

  return <<XML
    <disbursement>
      <id>$id</id>
      <transaction-ids type="array">
        <item>afv56j</item>
        <item>kj8hjk</item>
      </transaction-ids>
      <success type="boolean">true</success>
      <retry type="boolean">false</retry>
      <merchant-account>
        <id>merchant_account_token</id>
        <currency-iso-code>USD</currency-iso-code>
        <sub-merchant-account type="boolean">false</sub-merchant-account>
        <status>active</status>
      </merchant-account>
      <amount>100.00</amount>
      <disbursement-date type="date">2014-02-10</disbursement-date>
      <exception-message nil="true"/>
      <follow-up-action nil="true"/>
    </disbursement>
XML
};

sub _merchant_account_approved_sample_xml {
  my $id = shift;

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
  my $id = shift;

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
  my $id = shift;

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

sub _partner_merchant_connected_sample_xml {
  return <<XML
        <partner-merchant>
          <merchant-public-id>public_id</merchant-public-id>
          <public-key>public_key</public-key>
          <private-key>private_key</private-key>
          <partner-merchant-id>abc123</partner-merchant-id>
          <client-side-encryption-key>cse_key</client-side-encryption-key>
        </partner-merchant>
XML
}

sub _partner_merchant_disconnected_sample_xml {
  return <<XML
        <partner-merchant>
          <partner-merchant-id>abc123</partner-merchant-id>
        </partner-merchant>
XML
}

sub _partner_merchant_declined_sample_xml {
  return <<XML
        <partner-merchant>
          <partner-merchant-id>abc123</partner-merchant-id>
        </partner-merchant>
XML
}

1;
