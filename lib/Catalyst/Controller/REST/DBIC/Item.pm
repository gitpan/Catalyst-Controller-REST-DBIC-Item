package Catalyst::Controller::REST::DBIC::Item;

use warnings;
use strict;

use base qw/Catalyst::Controller::REST/;

use Carp;

=head1 NAME

Catalyst::Controller::REST::DBIC::Item - (EXPERIMENTAL) Common base class for typical REST
actions against a DBIx::Class object

=head1 VERSION

Version 0.001000_001 - DEVELOPER RELEASE

Because this is a developer release, please send any feedback or suggestions
to me either through RT or email at C<< cpan@coldhardcode.com >>

=cut

our $VERSION = '0.001000_001';

=head1 DESCRIPTION

This is an experimental controller base class that is designed to build some 
conventions around integrating REST and DBIC together in a Catalyst 
application.

The idea of this class is that, in the simplest terms, each item in a REST
application has one URL to interface with it.  Typically, these objects have a 
one to one mapping with a backend schema class.  This base class helps to reduce
the repetition in your REST classes and allow you to focus on just handling
the individual verbs (GET, PUT, POST, etc)

=head1 PHILOSOPHY

The general ideas for this module are such that I don't expect it to be of the
most use for a CRUD application designed to function in a browser.  Most
modern browsers support all the REST verbs via XmlHttpRequest but standard
requests are still limited to GET and POST.  This package will have the most
influence in a webservice scenario, and I hope that adapter classes can be
built upon this one that will combine L<Catalyst::Request::REST::ForBrowsers>
and other utilities to create controllers that work equally well in a
browser-based setting.


=head1 SYNOPSIS

    package MyApp::Controller::Person;

    use base 'Catalyst::Controller::REST::DBIC::Item';

    __PACKAGE__->config(
        # Add REST config
        'default' => 'text/html'
        # And, our bindings to DBIC, will use 
        # $c->model('Schema::Person') effectively.
        class => 'Schema::Person',
        # To find a record, $c->model($class)->search( $item_key => $key )
        item_key => 'name',
        # If you want to call a method before sending it to the serializers
        serialize_method => 'serialize',
        # Set to 0 if you don't want to call the above serialize method 
        # if the request is in a browser
        browser_serialize => 0
    );

    # This operates off of chained, and requires rest_base to be defined
    sub rest_base : Chained('.') PathPart('person') CaptureArgs(0) { }

=head1 Overriding Default Methods

Catalyst::Controller::REST::DBIC::Item operates by using Chained, which allows
for midpoints to be overridden easily as long as you maintain the conventions.

If you want to override one of the default chained midpoints, you only have
to be mindful of which stash key to set.  By default, the stash key:
C<< $c->stash->{rest}->{item} >> is used for fetching a single item.  If you
want to add additional DBIC logic, such as a prefetch, you can override
the item_base midpoint and properly set the stash.  Here is an example from
the L<http://www.iwatchsoccer.com> source (available at 
L<http://our.coldhardcode.com/svn/IWS>, which prefetches games to reduce the 
total number of queries.

    sub item_base : Chained('rest_base') PathPart('') CaptureArgs(1) {
        my ( $self, $c, $identifier ) = @_;

        # just populate $c->stash->{rest}->{item} and item_GET, etc
        $c->stash->{rest}->{item} = $self->get_item($c, $identifier)->search(
            {
                'games.end_time' => { '>=', $c->stash->{now} }
            },
            {
                prefetch => {
                    games => [
                        'home', 'visitor',
                        { broadcasts => 'network' }
                    ]
                }
            }
        )->single;
    }


=head1 CONFIGURATION

=over

=item class

What is your L<DBIx::Class> schema class to attach to?  This is the part you
would put in C<< $c->model(...) >>

=item item_key

What goes in C<< ->search({ item_key => $identifier }) >>

=item serialize_method

Call this on result sets and items to serialize them.  This is useful as
a base class in your DBIC schema (or just use get_columns) when you want to
support serializers that won't touch blessed objects, or don't want to serialize
the blessed object

=item browser_serialize

Set this value to 0 if you don't want to serialize a browser request.  This
requires you use L<Catalyst::Request::REST::ForBrowsers>, and will throw an
exception if you don't use it.

=back

=head1 GENERATED REST METHODS

=head2 rest_list PathPart('')

=cut

sub rest_list : Chained('rest_base') PathPart('') Args(0) ActionClass('REST') {

}

=head2 rest_list_GET

The simple method that handles GET actions on the list action (A call to 
C</foo>).

This method will call the C<serialize_method>, if configured, as well as respect
the C<browser_serialize> configuration setting if the request looks like it
is coming from a browser (which requires L<Catalyst::Request::REST::ForBrowsers>
to be loaded).

=cut

sub rest_list_GET {
    my ( $self, $c ) = @_;

    my $rs = $self->get_rs($c);
    my $entity;

    if ( defined $self->{browser_serialize} and 
         $self->{browser_serialize} == 0 and
         $c->req->looks_like_browser 
    ) {
        $entity = $rs;
    }
    elsif ( my $method = $self->{serialize_method} ) {
        $entity = $rs->can($method) ? $rs->$method : $rs;
    } else {
        $entity = $rs;
    }
    return $self->status_ok( $c, entity => $entity );
}


=head2 rest_item_base : Chained('rest_base') PathPart('') CaptureArgs(1)

This chain midpoint fetches the record by the captured argument (which should
be the record identifier).  

Override this method if you want to customize how the record is fetched.  It
is expected that if a record is found, C<< $c->stash->{rest}->{item} >> is set.
If not, the default GET request will return not found.

=cut

sub rest_item_base : Chained('rest_base') PathPart('') CaptureArgs(1) {
    my ( $self, $c, $pk1 ) = @_;

    $c->stash->{rest}->{item} = $self->get_item( $c, $pk1 )->single;
}

=head2 rest_item

This method chains to rest_item_base, has 0 arguments and uses
L<Catalyst::Action::REST>.

This method is used to handle triggering the single item methods.  Override
rest_item_GET, rest_item_POST, etc to have custom serialization behavior.

If you want to override the item selection, override rest_item_base

=cut

sub rest_item : Chained('rest_item_base') PathPart('') Args(0) ActionClass('REST') {
    my ( $self, $c ) = @_;
}

=head2 rest_item_GET

The default method for handling a simple GET request.  This will serialize 
however L<Catalyst::Controller::REST> is configured for the controller, and
will call the C<serialize_method> if configured (while respecting the
C<browser_serialize> configuration setting).

If the item is not found (which means C<< $c->stash->{rest}->{item} >> is not
defined) it will return a status_not_found result, with the message:
            
    message => $c->localize('ITEM_NOT_FOUND') );

=cut

sub rest_item_GET {
    my ( $self, $c ) = @_;
    my $item;
    unless ( $item = $c->stash->{rest}->{item} ) {
        return $self->status_not_found( $c, 
            message => $c->localize('ITEM_NOT_FOUND') );
    }

    my $entity;
    if ( defined $self->{browser_serialize} and 
         $self->{browser_serialize} == 0 and
         $c->req->looks_like_browser 
    ) {
        $entity = $item;
    }
    elsif ( my $method = $self->{serialize_method} ) {
        $c->log->debug("Serializing with $method ($self->{browser_serialize} and " . $c->req->looks_like_browser . ")");
        $entity = $item->can($method) ? $item->$method : $item;
    } else {
        $entity = $item;
    }
   
    return $self->status_ok( $c, entity => $entity );
}

=head1 HELPER METHODS

The following methods are convenience methods that can be used in your methods
to fetch items out of DBIC.

=head2 get_item($context, $identifier)

This method should return a result set that points to a single item that is
identified by $identifier.

If the configuration key C<item_key> is defined, it will do a search where
C<item_key == $identifier>, otherwise just a simple pull of the result
source primary keys, which is most likely what is expected but may not be
what you want.

=cut

sub get_item {
    my ( $self, $c, $item ) = @_;
    my $rs = $self->get_rs($c);

    if ( my $key = $self->{item_key} ) {
        return $rs->search({ "me.$key" => $item });
    } else {
        my @cols = $rs->primary_columns;
        if ( @cols == 1 ) {
            return $self->get_rs($c)->search({ "me.$cols[0]" => $item });
        }
        $c->log->error("Can't fetch item if schema has multiple primary keys and item_key is not defined.");
    }
}

=head2 get_rs($context)

This fetches the result set to be used.  This is a good point to override for
adding things like pagination.  A simple example for overriding would be:

 sub get_rs {
    my $rs = shift->next::method(@_);
    return $rs->search(undef, { rows => 10, page => 1 });
 }

Just make sure this always returns a result set.

=cut

sub get_rs {
    my ( $self, $c ) = @_;
    my $model = $self->{class};
    my $rs    = $c->model($model);
    croak "Unable to find DBIC resultset $model, check config"
        unless $rs;
    return $rs;
}


=head1 AUTHOR

J. Shirley, C<< <jshirley at coldhardcode.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-catalyst-controller-rest-dbic-item at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Catalyst-Controller-REST-DBIC-Item>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Catalyst::Controller::REST::DBIC::Item


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Catalyst-Controller-REST-DBIC-Item>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Catalyst-Controller-REST-DBIC-Item>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Catalyst-Controller-REST-DBIC-Item>

=item * Search CPAN

L<http://search.cpan.org/dist/Catalyst-Controller-REST-DBIC-Item>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2008 Cold Hard Code, LLC, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Catalyst::Controller::REST::DBIC::Item


