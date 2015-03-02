package Mojolicious::Plugin::EventTimer;

our $VERSION = '0.01';

use Mojo::Base 'Mojolicious::Plugin';

use Mojo::EventTimer;

sub register {
    my ( $self, $app, $args ) = @_;

    my $include_report = $args->{include_report};
    my $json_key       = $args->{json_key} || 'timer';
    my $stash_key      = $args->{stash_key} || 'timer';

    $app->helper(
        timer => sub {
            my ( $c, $timer ) = @_;

            return unless $c->can('req');    # do nothing if called from App

            $c->req->{__timer} = $timer if $timer;    # if called as mutator

            # return Mojo::EventTimer for current request
            return $c->req->{__timer};
        }
    );

    my $request_timer = sub {
        my ( $next, $c, $action, $last ) = @_;

        # ignores requests directly to HTML page ('/' etc)
        if ( $c->stash('action') ) {

            $c->timer( Mojo::EventTimer->new );
            $c->timer->record(
                sprintf( "%s#%s - started",
                    $c->stash('controller') || $c->stash('namespace'),
                    $c->stash('action') )
            );
        }

        return $next->();
    };

    my $include_timer_total = sub {
        my ( $c, $args ) = @_;

        $c->timer->record(
            sprintf(
                "%s#%s - finished",
                $c->stash('controller') || $c->stash('namespace'),
                $c->stash('action')
            )
        );

        if ( $args->{json} ) {
            $args->{json}->{$json_key}->{total} = $c->timer->total_time;
        } else {
            $args->{$stash_key}->{total} = $c->timer->total_time;
        }
    };

    my $include_timer_report = sub {
        my ( $c, $args ) = @_;

        if ( $args->{json} ) {
            $args->{json}->{$json_key}->{report} = $c->timer->report;
        } else {
            $args->{$stash_key}->{report} = $c->timer->report_text;
        }
    };

    # Creates timer object
    $app->hook( around_action => $request_timer );

    # Adds total time
    $app->hook( before_render => $include_timer_total );

    # Adds full report
    $app->hook( before_render => $include_timer_report ) if $include_report;

}

1;

__END__

=encoding utf-8

=head1 NAME

Mojolicious::Plugin::EventTimer - Mojolicious plugin to provide simple event duration logging

=head1 SYNOPSIS

    $app->plugin(
        "Mojolicious::Plugin::EventTimer",
        {   json_key  => 'timer',    # default
            stash_key => 'timer',    # default
        }
    );

=head1 DESCRIPTION

Mojolicious plugin to time events within a request. 

=head1 AUTHOR

Michael Jemmeson E<lt>mjemmeson@cpan.orgE<gt>

=head1 CONTRIBUTORS

=over

=item Nigel Hamilton B<NIGE>

=back

=head1 COPYRIGHT

Copyright 2014- Broadbean Technology Ltd

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

