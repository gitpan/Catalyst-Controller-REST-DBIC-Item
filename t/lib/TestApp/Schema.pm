package # hide from PAUSE
    TestApp::Schema;

use warnings;
use strict;

use base qw/DBIx::Class::Schema/;

use FindBin qw($Bin);

__PACKAGE__->load_classes;

sub init_schema {
    my ( $self ) = @_;

    my $db_dir  = File::Spec->catdir($Bin, "var");
    my $db_file = File::Spec->catfile($db_dir, "Test.db");

    unlink($db_file) if -e $db_file;
    unlink($db_file . "-journal") if -e $db_file . "-journal";
    mkdir($db_dir) unless -d $db_dir;

    my $dsn = "dbi:SQLite:dbname=${db_file}";
    my $schema = TestApp::Schema->connect($dsn);
    $schema->deploy();
    return $schema;
}

1;

