package Net::Braintree::ValidationError;
use Moo;

has 'attribute' => (is => 'ro');
has 'code' => (is => 'ro');
has 'message' => (is => 'ro');

__PACKAGE__->meta->make_immutable;
1;
