use lib qw(lib t/lib);
use Test::More;
use Net::Braintree::Xml;
use Net::Braintree::TestHelper;
use Data::Dumper;

subtest "simple parsing" => sub {
  is_deeply xml_to_hash("<node>text</node>"), {node => "text"};
  is_deeply xml_to_hash("<parent><child>text</child></parent>"), {parent => {child => "text"}};
};

subtest "folding array" => sub {
  is_deeply array({transaction =>[ {id => 1}, {id  => 2}]}), [{id => 1}, {id  => 2}];
  is_deeply array({type => "array", transaction =>[ {id => 1}, {id  => 2}] }), [{id => 1}, {id  => 2}];
  is_deeply array({transaction => {id => 1}}), [{id => 1}];
  is_deeply array({type => "array", transaction => {id => 1}}), [{id => 1}];
};

subtest "type = array with one sub-element" => sub {
  my $single_transaction_subscription = '<subscription>
    <transactions type="array">
      <transaction>
        <id>5hpp5g</id>
      </transaction>
    </transactions>
  </subscription>';
  my $single_result = xml_to_hash($single_transaction_subscription);
  is $single_result->{subscription}->{transactions}->[0]->{id}, "5hpp5g";
  is_deeply $single_result, {subscription => {transactions => [{id => "5hpp5g"}]}};
};

subtest "type = array with multiple sub-elements" => sub {
  my $subscription = '<subscription>
    <transactions type="array">
      <transaction>
        <id>5hpp5g</id>
      </transaction>
      <transaction>
        <id>4aee2h</id>
      </transaction>
    </transactions>
  </subscription>';
  my $result = xml_to_hash($subscription);
  is $result->{subscription}->{transactions}->[0]->{id}, "5hpp5g";
  is $result->{subscription}->{transactions}->[1]->{id}, "4aee2h";
  is_deeply $result, {subscription => {transactions => [{id => "5hpp5g"}, {id => "4aee2h"}]}};
};

subtest "Nested Arrays" => sub {
  my $nested_arrays = '<subscription>
  <transactions type="array">
    <transaction>
      <id>5hpp5g</id>
      <statuses type="array">
        <status>
          <id>1123</id>
        </status>
        <status>
          <id>2211</id>
        </status>
        <status>
          <id>3342</id>
        </status>
      </statuses>
    </transaction>
    <transaction>
      <id>4aee2h</id>
    </transaction>
  </transactions>
</subscription>';
  my $result = xml_to_hash($nested_arrays);

  is_deeply $result, {subscription => {transactions =>
    [{id => "5hpp5g", statuses => [{id => 1123}, {id => 2211}, {id  => 3342}]},
      {id => "4aee2h"}]}};
};

subtest "Normalize Hash Keys" => sub {
  is_deeply(xml_to_hash("<this-key>this value</this-key>"), {"this_key" => "this value"});
  is_deeply(xml_to_hash('<nested><this-key>this value</this-key></nested>'), {"nested" => {"this_key" => "this value"}});
  is_deeply(xml_to_hash('<parent-keys type="array"><parent-key><this-key>this value</this-key></parent-key></parent-keys>'),
                          {"parent_keys" => [{"this_key" => "this value"}]});
};

subtest "attribute conversion" => sub {
  is_deeply(xml_to_hash('<value nil="true"></value>'), {value => undef});
  is_deeply(xml_to_hash('<value type="boolean">true</value>'), {value => 1});
  is_deeply(xml_to_hash('<value type="boolean">false</value>'), {value => 0});
  is_deeply(xml_to_hash('<value type="integer">2</value>'), {value => 2});

  my $datetime = xml_to_hash('<value type="datetime">2011-08-03T19:12:33Z</value>')->{'value'};
  is $datetime->month, 8;
  is $datetime->day, 3;
  is $datetime->year, 2011;
  is $datetime->hour, 19;
  is $datetime->minute, 12;
  is $datetime->second, 33;

  my $date = xml_to_hash('<value type="date">2011-08-03</value>')->{'value'};
  is $date->month, 8;
  is $date->day, 3;
  is $date->year, 2011;

  my $unknown_type = xml_to_hash('<value type="unknown">ff334h2[[[334{{</value>')->{'value'};
  is $unknown_type, 'ff334h2[[[334{{';
};

done_testing();

