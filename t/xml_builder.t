use lib qw(lib t/lib);
use Test::More;
use Net::Braintree::Xml;
use Net::Braintree::TestHelper;
use Data::Dumper;

sub check_round_trip {
  my $data = shift;
  my $print_xml = shift;
  my $xml = hash_to_xml($data);
  print Dumper($xml) if $print_xml;
  is_deeply xml_to_hash($xml), $data
}
subtest "generated simple xml" => sub {
  check_round_trip({key => "value"});
  check_round_trip({key => {subkey => "value2", subkey2 => "value3"}});
  check_round_trip({key => {subkey => {subsubkey => "value3"}}});
  check_round_trip({keys => [{subkey => "value"}]}, 1);
  check_round_trip({root => {keys => [{subkey => "value"}, {subkey2 => "value2"}]}}, 1);

};
done_testing();

