use Test::More;
use lib qw(lib t/lib);
use Net::Braintree::Util;
use Net::Braintree::TestHelper;
use Data::Dumper;

subtest "Flatten Hashes" => sub {
  is_deeply(flatten({}), {}, "empty hash");
  is_deeply(flatten({"a" => "1"}), {"a" => "1"}, "One element.");
  is_deeply(flatten({"a" => {"b" => "1"}}), {"a[b]" => "1"}, "One namespace");
  is_deeply(flatten({"a" => {"b" => "1"}, "a2" => {"q" => "r"}}), {"a[b]" => "1", "a2[q]" => "r"}, "Two horizontal namespace");
  is_deeply(flatten({"a" => {"b" => {"c" => "1"}}}), {"a[b][c]" => "1"}, "Vertical merging");
};

subtest "equal arrays" => sub {
  ok(equal_arrays(['a'], ['a']));
  ok(equal_arrays(['a', 'b'], ['a', 'b']));
  not_ok(equal_arrays(['a'], ['b']));
  not_ok(equal_arrays(['a', 'b'], ['b']));

  my $hash = { 'a' => 'b' };
  ok(equal_arrays((keys %$hash), ('a')));

};

done_testing();
