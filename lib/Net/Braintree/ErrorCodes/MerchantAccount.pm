package Net::Braintree::ErrorCodes::MerchantAccount;
use strict;

use constant IdIsNotAllowed                         => "82605";
use constant IdIsTooLong                            => "82602";
use constant IdFormatIsInvalid                      => "82603";
use constant MasterMerchantAccountIdIsInvalid       => "82607";
use constant IdIsInUse                              => "82604";
use constant MasterMerchantAccountIdIsRequired      => "82606";
use constant MasterMerchantAccountMustBeActive      => "82608";
use constant TosAcceptedIsRequired                  => "82610";
use constant IdCannotBeUpdated                      => "82675";
use constant MasterMerchantAccountIdCannotBeUpdated => "82676";
use constant CannotBeUpdated                        => "82674";
use constant Declined                               => "82626";
use constant DeclinedMasterCardMatch                => "82622";
use constant DeclinedOFAC                           => "82621";
use constant DeclinedFailedKYC                      => "82623";
use constant DeclinedSsnInvalid                     => "82624";
use constant DeclinedSsnMatchesDeceased             => "82625";

1;
