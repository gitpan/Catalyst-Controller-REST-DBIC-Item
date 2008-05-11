use Test::More qw/no_plan/;

use YAML::Syck;
use File::Spec;
use FindBin '$Bin';
use lib File::Spec->catdir($Bin, 'lib');

BEGIN {
	use_ok( 'Catalyst::Controller::REST::DBIC::Item' );
	use_ok( 'TestApp::Schema' );
}

my $schema = TestApp::Schema->init_schema;

use Test::WWW::Mechanize::Catalyst 'TestApp';

my $mech = Test::WWW::Mechanize::Catalyst->new;

# Create a book called 'name'
my $res = $mech->get('/book/test_book', 'Content-type' => 'text/x-yaml' );

is($res->code, '404', "Book doesn't exist");
my $test_data = YAML::Syck::Dump({ name => "test_book", isbn => "1234" });


$res = $mech->post( '/book/test_book', 
    'Content-type' => 'text/x-yaml',
    Content => $test_data 
);

is($res->code, '405', "Book has no post method");
like($res->content, qr/Method POST not implemented/, 'No post on book');

$res = $mech->put( '/book/test_book', 
    'Content-type' => 'text/x-yaml',
    Content => $test_data 
);

is($res->code, '405', "Book has no put method");
like($res->content, qr/Method PUT not implemented/, 'No post on book');
