package Net::Braintree::CreditCardNumbers::CardTypeIndicators;
use strict;

use constant Prepaid           => "4111111111111210";
use constant Commercial        => "4111111111131010";
use constant Payroll           => "4111111114101010";
use constant Healthcare        => "4111111510101010";
use constant DurbinRegulated   => "4111161010101010";
use constant Debit             => "4117101010101010";
use constant Unknown           => "4111111111112101";
use constant No                => "4111111111310101";
use constant IssuingBank       => "4111111141010101";
use constant CountryOfIssuance => "4111111111121102";
use constant Fraud             => "4000111111111511";

1;
