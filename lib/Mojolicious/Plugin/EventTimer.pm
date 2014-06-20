package Mojolicious::Plugin::EventTimer;

use Mojo::Base 'Mojolicious::Plugin';

use Mojo::EventTimer;

our $VERSION = '0.01';

sub register {
    my ( $self, $app, $conf ) = @_;

    use Data::Dumper::Concise;
    warn Dumper($conf);

    my $param_name = $conf->{param_name} // 'include_timer';
    my $stash_key  = $conf->{stash_key}  // 'timer';

    my $request_timer = sub {
        my ( $next, $c, $action, $last ) = @_;

        # ignores requests directly to HTML pages
        if ( $c->stash('controller') ) {

            $c->req->{__timer} = Mojo::EventTimer->new;
            $c->req->{__timer}->record(
                sprintf( "%s#%s - started",
                    $c->stash('controller'),
                    $c->stash('action') )
            );
            $c->stash( $stash_key => {} );
        }

        return $next->();
    };

    my $include_timer_log = sub {
        my ( $c, $args ) = @_;

        # add to JSON - always add
        if ( my $alter = $args->{json} ) {

            $alter->{$stash_key}->{total} = $c->req->{__timer}->total_time;

            if ( $c->req->param($param_name) ) {
                $alter->{$stash_key}->{log} = $c->req->{__timer}->report;
            }

        } else {

            if ( $c->req->param($param_name) ) {

                $args->{$stash_key} = {
                    total => $c->req->{__timer}->total_time,
                    log   => $c->req->{__timer}->report_text,
                };
            }
        }

    };

    # Create timer for requests
    $app->hook( around_action => $request_timer );
    $app->hook( before_render => $include_timer_log );

}

1;

__END__

=encoding utf-8

=head1 NAME

Mojolicious::Plugin::EventTimer - Mojolicious plugin to provide simple event duration logging

=head1 SYNOPSIS

  use Mojolicious::Plugin::EventTimer;

=head1 DESCRIPTION

# TODO

=head1 AUTHOR

Michael Jemmeson E<lt>mjemmeson@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2014- Michael Jemmeson

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
