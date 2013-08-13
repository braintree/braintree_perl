package Net::Braintree::ErrorCodes::MerchantAccount::ApplicantDetails;
use strict;

use constant AccountNumberIsRequired        => "82614";
use constant CompanyNameIsInvalid           => "82631";
use constant CompanyNameIsRequiredWithTaxId => "82633";
use constant DateOfBirthIsRequired          => "82612";
use constant Declined                       => "82626";
use constant DeclinedMasterCardMatch        => "82622";
use constant DeclinedOFAC                   => "82621";
use constant DeclinedFailedKYC              => "82623";
use constant DeclinedSsnInvalid             => "82624";
use constant DeclinedSsnMatchesDeceased     => "82625";
use constant EmailAddressIsInvalid          => "82616";
use constant FirstNameIsInvalid             => "82627";
use constant FirstNameIsRequired            => "82609";
use constant LastNameIsInvalid              => "82628";
use constant LastNameIsRequired             => "82611";
use constant PhoneIsInvalid                 => "82636";
use constant RoutingNumberIsInvalid         => "82635";
use constant RoutingNumberIsRequired        => "82613";
use constant SsnIsInvalid                   => "82615";
use constant TaxIdIsInvalid                 => "82632";
use constant TaxIdIsRequiredWithCompanyName => "82634";

1;
