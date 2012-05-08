package Net::Braintree::ValidationError;
use Moose;

has 'attribute' => (is => 'ro');
has 'code' => (is => 'ro');
has 'message' => (is => 'ro');

1;
