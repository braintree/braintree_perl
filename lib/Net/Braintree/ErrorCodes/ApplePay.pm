package Net::Braintree::ErrorCodes::ApplePay;
use strict;

use constant ApplePayCardsAreNotAccepted                      => "83501";
use constant CustomerIdIsRequiredForVaulting                  => "83502";
use constant TokenIsInUse                                     => "93503";
use constant PaymentMethodNonceConsumed                       => "93504";
use constant PaymentMethodNonceUnknown                        => "93505";
use constant PaymentMethodNonceLocked                         => "93506";
use constant PaymentMethodNonceCardTypeIsNotAccepted          => "83518";
use constant CannotUpdateApplePayCardUsingPaymentMethodNonce  => "93507";
use constant NumberIsRequired                                 => "93508";
use constant ExpirationMonthIsRequired                        => "93509";
use constant ExpirationYearIsRequired                         => "93510";
use constant CryptogramIsRequired                             => "93511";
use constant DecryptionFailed                                 => "83512";
use constant Disabled                                         => "93513";
use constant MerchantNotConfigured                            => "93514";
use constant MerchantKeysAlreadyConfigured                    => "93515";
use constant MerchantKeysNotConfigured                        => "93516";
use constant CertificateInvalid                               => "93517";

1;
