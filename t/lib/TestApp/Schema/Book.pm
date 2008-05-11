package TestApp::Schema::Book;

use base 'DBIx::Class';

my $CLASS = __PACKAGE__;

use overload '""' => sub { $_[0]->name() }, fallback => 1;

$CLASS->load_components( qw|Core| );
$CLASS->table('book');

$CLASS->add_columns(
    'pk1',
    { data_type => 'integer', size => 16, is_nullable => 0,
        is_auto_increment => 1 },
    'name',
    { data_type => 'varchar', size => 128, is_nullable => 0 },
    'isbn',
    { data_type => 'varchar', size => 128, is_nullable => 0 },
);

$CLASS->set_primary_key(qw/pk1/);

1;

