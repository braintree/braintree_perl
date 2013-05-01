use inc::Module::Install;

name     'Net-Braintree';
all_from 'lib/Net/Braintree.pm';
author   q{Braintree Payment Solutions <support@getbraintree.com>};
license  'perl';
abstract       'This library provides an API for integration with the Braintree Payment Gateway';

requires       'DateTime';
requires       'DateTime::Format::Atom';
requires       'DateTime::Format::Strptime';
requires       'Digest';
requires       'Digest::HMAC_SHA1';
requires       'Digest::SHA1';
requires       'File::Spec'  => '0.80';
requires       'Hash::Inflator';
requires       'XML::LibXML';
requires       'local::lib';
requires       'LWP'         => '6.02';
requires       'LWP::Protocol::https';
requires       'Module::Install::TestTarget';
requires       'Moose';
requires       'URI::Query';
requires       'XML::Simple';
test_requires  'Test::More'  => '0.98';
test_requires  'Try::Tiny';
test_requires  'Test::Warn';
test_requires  'Test::Pod';
build_requires 'Test::More';

auto_install;
tests 't/*t';

test_target integration => (
  insert_on_prepare  => ['print "start -> ", scalar localtime, "\\\\n"'],
  insert_on_finalize => ['print "end   -> ", scalar localtime, "\\\\n"'],
  tests              => ['t/integration/*t'],
);

WriteAll;
