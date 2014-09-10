package Net::Braintree::Transaction::Status;
use strict;

use constant AuthorizationExpired => 'authorization_expired';
use constant Authorizing => 'authorizing';
use constant Authorized => 'authorized';
use constant GatewayRejected => 'gateway_rejected';
use constant Failed => 'failed';
use constant ProcessorDeclined => 'processor_declined';
use constant Settled => 'settled';
use constant Settling => 'settling';
use constant SubmittedForSettlement => 'submitted_for_settlement';
use constant SettlementDeclined => 'settlement_declined';
use constant SettlementPending => 'settlement_pending';
use constant Voided => 'voided';

use constant All => (
  AuthorizationExpired,
  Authorizing,
  Authorized,
  GatewayRejected,
  Failed,
  ProcessorDeclined,
  Settled,
  SettlementDeclined,
  SettlementPending,
  Settling,
  SubmittedForSettlement,
  Voided,
);

1;
