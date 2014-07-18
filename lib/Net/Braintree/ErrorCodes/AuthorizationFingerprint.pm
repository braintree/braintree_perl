package Net::Braintree::ErrorCodes::AuthorizationFingerprint;
use strict;

use constant InvalidCreatedAt                  => "93204";
use constant InvalidFormat                     => "93202";
use constant InvalidPublicKey                  => "93205";
use constant InvalidSignature                  => "93206";
use constant MissingFingerprint                => "93201";
use constant OptionsNotAllowedWithoutCustomer  => "93207";
use constant SignatureRevoked                  => "93203";

1;
