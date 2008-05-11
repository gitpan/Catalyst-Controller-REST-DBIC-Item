package  # Hide from PAUSE
    TestApp::Controller::Book;

use base qw(Catalyst::Controller::REST::DBIC::Item);

__PACKAGE__->config({
    class    => 'Schema::Book',
    item_key => 'name'
});

sub rest_base : Chained('.') PathPart('') CaptureArgs(0) { }

1;
