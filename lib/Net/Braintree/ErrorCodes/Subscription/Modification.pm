package Net::Braintree::ErrorCodes::Subscription::Modification;
use strict;

use constant AmountCannotBeBlank                          => "92003";
use constant AmountIsInvalid                              => "92002";
use constant AmountIsTooLarge                             => "92023";
use constant CannotEditModificationsOnPastDueSubscription => "92022";
use constant CannotUpdateAndRemove                        => "92015";
use constant ExistingIdIsIncorrectKind                    => "92020";
use constant ExistingIdIsInvalid                          => "92011";
use constant ExistingIdIsRequired                         => "92012";
use constant IdToRemoveIsIncorrectKind                    => "92021";
use constant IdToRemoveIsInvalid                          => "92025";
use constant IdToRemoveIsNotPresent                       => "92016";
use constant InconsistentNumberOfBillingCycles            => "92018";
use constant InheritedFromIdIsInvalid                     => "92013";
use constant InheritedFromIdIsRequired                    => "92014";
use constant Missing                                      => "92024";
use constant NumberOfBillingCyclesCannotBeBlank           => "92017";
use constant NumberOfBillingCyclesIsInvalid               => "92005";
use constant NumberOfBillingCyclesMustBeGreaterThanZero   => "92019";
use constant QuantityCannotBeBlank                        => "92004";
use constant QuantityIsInvalid                            => "92001";
use constant QuantityMustBeGreaterThanZero                => "92010";

1;
