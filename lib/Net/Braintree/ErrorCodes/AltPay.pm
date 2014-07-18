package Net::Braintree::ErrorCodes::AltPay;
use strict;

use constant PayPalAccountCannotHaveBothAccessTokenAndConsentCode   => "82903";
use constant PayPalAccountCannotVaultOneTimeUsePayPalAccount        => "82902";

use constant PayPalAccountConsentCodeOrAccessTokenIsRequired        => "82901";
use constant PayPalAccountCustomerIdIsRequiredForVaulting           => "82905";
use constant PayPalAccountPaymentMethodNonceConsumed                => "92907";
use constant PayPalAccountPaymentMethodNonceLocked                  => "92909";
use constant PayPalAccountPaymentMethodNonceUnknown                 => "92908";
use constant PayPalAccountPayPalAccountSAreNotAccepted              => "82904";
use constant PayPalAccountPayPalCommunicationError                  => "92910";
use constant PayPalAccountTokenIsInUse                              => "92906";

use constant SepaBankAccountAccountHolderNameIsRequired             => "93003";
use constant SepaBankAccountBicIsRequired                           => "93002";
use constant SepaBankAccountIbanIsRequired                          => "93001";

use constant SepaMandateAccountHolderNameIsRequired                 => "83301";
use constant SepaMandateBicInvalidCharacter                         => "83306";
use constant SepaMandateBicIsRequired                               => "83302";
use constant SepaMandateBicLengthIsInvalid                          => "83307";
use constant SepaMandateBicUnsupportedCountry                       => "83308";
use constant SepaMandateBillingAddressConflict                      => "93312";
use constant SepaMandateBillingAddressIdIsInvalid                   => "93313";
use constant SepaMandateIbanInvalidCharacter                        => "83305";
use constant SepaMandateIbanInvalidFormat                           => "83310";
use constant SepaMandateIbanIsRequired                              => "83303";
use constant SepaMandateIbanUnsupportedCountry                      => "83309";
use constant SepaMandateLocaleIsUnsupported                         => "93311";
use constant SepaMandateTypeIsRequired                              => "93304";

1;
