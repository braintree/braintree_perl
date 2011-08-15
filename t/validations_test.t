use lib qw(lib t/lib);
use Test::More;
use Net::Braintree::TestHelper;
use Net::Braintree::Validations qw(verify_params);

ok verify_params({}, {}, "Empty params verify");
not_ok verify_params({param_1 => "value"}, {}, "fails verifification if param isn't in signature");
ok verify_params({param_1 => "value"}, {"param_1" => "."}, "verifies one param");
ok verify_params({param_1 => {nested_param  => "value"}}, {"param_1" => {nested_param => "."}}, "works with nested hashes");
not_ok verify_params({param_1 => {invalid_key  => "value"}}, {"param_1" => {nested_param => "."}}, "works with nested hashes");
ok verify_params({custom_fields => {internal_id => 4432321, bars_of_soap => 43}},
                 {custom_fields => "_any_key_"}), "supports wild cards";
not_ok verify_params({name => {first => "Jill", last => "Johnson"}}, {name => "."}), "doesn't allow nested trees where they shouldn't be";
done_testing();

