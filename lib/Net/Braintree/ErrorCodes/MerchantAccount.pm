package Net::Braintree::ErrorCodes::MerchantAccount;
use strict;

use constant IdIsNotAllowed                    => "82605";
use constant IdIsTooLong                       => "82602";
use constant IdFormatIsInvalid                 => "82603";
use constant MasterMerchantAccountIdIsInvalid  => "82607";
use constant IdIsInUse                         => "82604";
use constant MasterMerchantAccountIdIsRequired => "82606";
use constant MasterMerchantAccountMustBeActive => "82608";
use constant TosAcceptedIsRequired             => "82610";

1;
