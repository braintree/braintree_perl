package Net::Braintree::Transaction::EscrowStatus;
use strict;

use constant HoldPending => 'hold_pending';
use constant Held => 'held';
use constant ReleasePending => 'release_pending';
use constant Released => 'released';
use constant Refunded => 'refunded';

use constant All => (
  HoldPending,
  Held,
  ReleasePending,
  Released,
  Refunded
);

1;
