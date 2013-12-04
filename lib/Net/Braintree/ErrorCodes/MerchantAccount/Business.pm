package Net::Braintree::ErrorCodes::MerchantAccount::Business;
use strict;

use constant DbaNameIsInvalid             => "82646";
use constant TaxIdIsInvalid               => "82647";
use constant TaxIdIsRequiredWithLegalName => "82648";
use constant LegalNameIsRequiredWithTaxId => "82669";
use constant TaxIdMustBeBlank             => "82672";
use constant LegalNameIsInvalid           => "82677";

1;
