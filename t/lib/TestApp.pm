package # Hide from PAUSE
    TestApp;

use Catalyst qw(
    I18N
);
use FindBin;

TestApp->config(
    root => "$FindBin::Bin/root",
    'Model::Schema' => {
        connect_info => [
            "dbi:SQLite:dbname=" . TestApp->path_to('../../var/Test.db')
        ]
    },
    default_view => 'TT',
    'View::Email::AppConfig' => {
        sender => {
            method => 'Test',
        },
    },
);

TestApp->setup;

1;
