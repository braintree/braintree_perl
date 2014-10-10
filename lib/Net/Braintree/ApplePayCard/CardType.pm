package Net::Braintree::ApplePayCard::CardType;
use strict;

use constant AmericanExpress => "Apple Pay - American Express";
use constant MasterCard => "Apple Pay - MasterCard";
use constant Visa => "Apple Pay - Visa";

use constant All => [
  AmericanExpress,
  MasterCard,
  Visa
];

1;
