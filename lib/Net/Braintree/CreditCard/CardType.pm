package Net::Braintree::CreditCard::CardType;
use strict;

use constant AmericanExpress => "American Express";
use constant CarteBlanche => "Carte Blanche";
use constant ChinaUnionPay => "China UnionPay";
use constant DinersClub => "Diners Club";
use constant Discover => "Discover";
use constant JCB => "JCB";
use constant Laser => "Laser";
use constant Maestro => "Maestro";
use constant MasterCard => "MasterCard";
use constant Solo => "Solo";
use constant Switch => "Switch";
use constant Visa => "Visa";
use constant Unknown => "Unknown";

use constant All => [
  AmericanExpress,
  CarteBlanche,
  ChinaUnionPay,
  DinersClub,
  Discover,
  JCB,
  Laser,
  Maestro,
  MasterCard,
  Solo,
  Switch,
  Visa,
  Unknown
];
1;
