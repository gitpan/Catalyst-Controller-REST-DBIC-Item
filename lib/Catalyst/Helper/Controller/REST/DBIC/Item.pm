package Catalyst::Helper::Controller::REST::DBIC::Item;

use strict;

=head1 NAME

Catalyst::Helper::Controller::REST::DBIC::Item - Helper to create REST controllers

=head1 SYNOPSIS

    $ catalyst.pl myapp
    $ cd myapp
    $ script/myapp_create.pl controller Book REST::DBIC::Item Schema::Book

=head1 DESCRIPTION

Helper to create REST Base classes.  After this, you should be reading up on
L<Catalyst::Controller::REST::DBIC::Item>

=head1 METHODS

=head2 mk_compclass

This generates the individual REST classes

=cut

sub mk_compclass {
    my ( $self, $helper, $schema_class ) = @_;
    $helper->{schema_class} = $helper;
    my $file = $helper->{file};
    $helper->render_file( 'compclass', $file );
}

=head1 SEE ALSO

L<Catalyst::Controller::REST::DBIC::Item>

L<Catalyst::Action::REST>

L<Catalyst::Model::DBIC::Schema>

=head1 AUTHOR

J. Shirley C<cpan@coldhardcode.com>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut



1;

__DATA__

__compclass__
package [% class %];

use warnings;
use strict;

use base 'Catalyst::Controller::REST::DBIC::Item';

__PACKAGE__->config(

);

=head1 NAME

[% CLASS %] - REST Controller for [% schema_class %]

=head1 DESCRIPTION

REST Methods to access the DBIC Schema Class [% schema_class %]

=head1 AUTHOR

[% author %]

=head1 SEE ALSO

L<[% app %]>

L<[% app %]::Model::[% schema_claass %]>

L<Catalyst::Action::REST>

=head1 LICENSE

[% license %]

=cut

1;

