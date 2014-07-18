package Net::Braintree::ErrorCodes::PayPalAccount;
use strict;

use constant CannotCloneTransactionWithPayPalAccount => "91573";
use constant CannotVaultOneTimeUsePayPalAccount      => "82902";
use constant CannotHaveBothAccessTokenAndConsentCode => "82903";
use constant ConsentCodeOrAccessTokenIsRequired      => "82901";
use constant CustomerIdIsRequiredForVaulting         => "82905";
use constant PaymentMethodNonceConsumed              => "92907";
use constant PaymentMethodNonceLocked                => "92909";
use constant PaymentMethodNonceUnknown               => "92908";
use constant PayPalAccountsAreNotAccepted            => "82904";
use constant PayPalCommunicationError                => "92910";
use constant TokenIsInUse                            => "92906";

1;




