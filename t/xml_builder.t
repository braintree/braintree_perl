use lib qw(lib t/lib);
use Test::More;
use Net::Braintree::Xml;
use Net::Braintree::TestHelper;

sub check_round_trip {
  my $data = shift;
  my $print_xml = shift;
  my $xml = hash_to_xml($data);
  is_deeply xml_to_hash($xml), $data
}
subtest "generated simple xml" => sub {
  check_round_trip({key => "value"});
  check_round_trip({key => {subkey => "value2", subkey2 => "value3"}});
  check_round_trip({key => {subkey => {subsubkey => "value3"}}});
  check_round_trip({keys => [{subkey => "value"}]}, 1);
  check_round_trip({root => {keys => [{subkey => "value"}, {subkey2 => "value2"}]}}, 1);

};

subtest "generate arrays correctly" => sub {
  my $actual = hash_to_xml({search => {ids => [1, 2, 3]}});
  my $expected = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<search>
  <ids type=\"array\">
    <item>1</item>
    <item>2</item>
    <item>3</item>
  </ids>
</search>
";
  is $actual, $expected;
};

done_testing();

