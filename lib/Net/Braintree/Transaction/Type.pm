package Net::Braintree::Transaction::Type;
use strict;

use constant Sale => "sale";
use constant Credit => "credit";

use constant All => (
  Sale,
  Credit,
);

1;
