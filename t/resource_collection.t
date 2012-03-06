use lib qw(lib t/lib);
use Test::More;
use Net::Braintree;
use Net::Braintree::TestHelper;

subtest "each" => sub {
  my $page_counter = 0;
  my $resource_collection = Net::Braintree::ResourceCollection->new();
  my $response = {search_results => {ids => [1,2,3,4,5], page_size => 2}};
  $resource_collection->init($response, sub {
    $page_counter = $page_counter + 1;
    return [$page_counter];
  });

  @page_counts = ();
  $resource_collection->each(sub {
    push(@page_counts, shift);
  });

  is $resource_collection->maximum_size, 5;
  is_deeply(\@page_counts, [1, 2, 3]);
};

done_testing();
