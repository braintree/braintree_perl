use lib qw(lib t/lib);
use Net::Braintree;
use Net::Braintree::TestHelper;
use Test::More;

BEGIN { use_ok('Net::Braintree::ValidationErrorCollection') };

subtest "constructor and deep_errors" => sub {
  subtest "builds an error object given an array of hashes" => sub {
    my $hash = {
      errors => [
        {attribute => "some model attribute", code => 1, message => "bad juju"},
        {attribute => "some other attribute", code => 2, message => "badder juju"}],
      nested => {
        errors => [{attribute => "a third attribute", code => 3, message => "baddest juju"}]
      }
    };

    my $collection = Net::Braintree::ValidationErrorCollection->new($hash);
    my $error = $collection->deep_errors->[2];
    is($error->attribute, "a third attribute");
    is($error->code, 3);
    is($error->message, "baddest juju");

  };
};

subtest "for" => sub {
  subtest "provides access to nested errors" => sub {
    my $hash = {
      errors => [{ attribute => "some model attribute", code => 1, message => "bad juju" }],
      nested => {
        errors => [
          { attribute => "number", code => 2, message => "badder juju"},
          { attribute => "string", code => 3, message => "baddest juju"}
        ]
      }
    };

    my $errors = Net::Braintree::ValidationErrorCollection->new($hash);

    is(scalar @{$errors->deep_errors}, 3);
    is($errors->for('nested')->on('number')->[0]->code, 2);
    is($errors->for('nested')->on('number')->[0]->message, "badder juju");
    is($errors->for('nested')->on('number')->[0]->attribute, "number");
  };
};

done_testing();
