package  # Hide from PAUSE
    TestApp::Controller::Root;

use base qw(Catalyst::Controller);

__PACKAGE__->config->{namespace} = '';

sub rest_base : Chained('.') PathPart('') CaptureArgs(0) { }
sub default : Private {
    my ( $self, $c ) = @_;

    $c->res->status(404);
    $c->res->body(qq{Nothing Here});
}

sub base : Chained('/') PathPart('') CaptureArgs(0) { }

sub book      : Chained('base') CaptureArgs(0) { }
sub author    : Chained('base') CaptureArgs(0) { }
sub publisher : Chained('base') CaptureArgs(0) { }

1;
