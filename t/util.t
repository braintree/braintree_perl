use Test::More;
use lib qw(lib t/lib);
use Net::Braintree::Util;
use Net::Braintree::TestHelper;

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
  ok(equal_arrays([ keys %$hash ], ['a']));

  # undef eq ''
  ok(equal_arrays([undef, ''], ['', '']));
};

subtest "difference arrays" => sub {
  ok(equal_arrays(difference_arrays(['a', 'b'], ['a', 'b']), []));
  is_deeply(difference_arrays(['a', 'b'], ['a']), ['b']);
  ok(equal_arrays(difference_arrays(['a', 'b'], ['b']), ['a']));
  ok(equal_arrays(difference_arrays(['a'], ['a', 'b']), []));
  ok(equal_arrays(difference_arrays([], []), []));
  ok(equal_arrays(difference_arrays(['', 'a', 'b'], ['b', 'a', '']), []));
};

subtest "is_hashref" => sub {
  my $dt = DateTime->now();
  my %true_hash = (key => "value");
  not_ok is_hashref($dt);
  ok is_hashref({key => "value"});
  ok is_hashref(\%true_hash);
};

done_testing();
