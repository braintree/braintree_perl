use lib qw(lib t/lib);
use Net::Braintree;
use Net::Braintree::TestHelper;
use Test::More;

BEGIN { use_ok('Net::Braintree::ValidationErrorCollection') };

subtest "constructor and deep_errors" => sub {
  subtest "builds an error object given an array of hashes" => sub {
    my $hash = {errors => [{ attribute => "some model attribute", code => 1, message => "bad juju" }]};
    my $collection = Net::Braintree::ValidationErrorCollection->new($hash);
    my $error = $collection->deep_errors->[0];
    is($error->attribute, "some model attribute");
    is($error->code, 1);
    is($error->message, "bad juju");
  };
};

subtest "for" => sub {
  subtest "provides access to nested errors" => sub {
    my $hash = {
      errors => [{ attribute => "some model attribute", code => 1, message => "bad juju" }],
      nested => {
        errors => [{ attribute => "number", code => 2, message => "badder juju"}]
      }
    };

    my $errors = Net::Braintree::ValidationErrorCollection->new($hash);

    is(scalar @{$errors->deep_errors}, 2);
    is($errors->for('nested')->on('number')->[0]->code, 2);
    is($errors->for('nested')->on('number')->[0]->message, "badder juju");
    is($errors->for('nested')->on('number')->[0]->attribute, "number");
  };
};

done_testing();
