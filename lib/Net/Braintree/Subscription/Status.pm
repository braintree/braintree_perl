package Net::Braintree::Subscription::Status;
use strict;

use constant Active => 'Active';
use constant Canceled => 'Canceled';
use constant Expired => 'Expired';
use constant PastDue => 'Past Due';
use constant Pending => 'Pending';

use constant All => (
  Active,
  Canceled,
  Expired,
  PastDue,
  Pending
);

1;
