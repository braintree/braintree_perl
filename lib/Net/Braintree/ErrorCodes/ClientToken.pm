package Net::Braintree::ErrorCodes::ClientToken;
use strict;

use constant CustomerDoesNotExist                            => "92804";
use constant FailOnDuplicatePaymentMethodRequiresCustomerId  => "92803";
use constant MakeDefaultRequiresCustomerId                   => "92801";
use constant ProxyMerchantDoesNotExist                       => "92805";
use constant VerifyCardRequiresCustomerId                    => "92802";
use constant UnsupportedVersion                              => "92806";

1;
