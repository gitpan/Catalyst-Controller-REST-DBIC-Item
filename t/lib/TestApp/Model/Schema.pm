package # Hide from PAUSE
    TestApp::Model::Schema;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'TestApp::Schema',
    
);

1;
