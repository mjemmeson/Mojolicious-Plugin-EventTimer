package Mojo::EventTimer;

# VERSION

use Mojo::Base 'Mojo';

use Time::HiRes qw(gettimeofday tv_interval);

has event_log  => sub { [] };
has start_time => sub { [gettimeofday] };

sub record {
    my ( $self, $event_description ) = @_;

    push @{ $self->event_log },
        {
        timestamp   => sprintf( "%.3f", tv_interval( $self->start_time ) ),
        description => $event_description,
        };
}

sub report {
    my ($self) = @_;

    return [ map { sprintf( "[%s] %s", $_->{timestamp}, $_->{description} ) }
            @{ $self->event_log } ];
}

sub report_text {
    my ($self) = @_;

    return join '', map "$_\n", @{ $self->report };
}

sub total_time {
    my ($self) = @_;

    return @{ $self->event_log } ? $self->event_log->[-1]->{timestamp} : 0;
}

sub restart {
    my ($self) = @_;

    $self->start_time( [gettimeofday] );
    $self->event_log(  [] );
}

1;

__END__

=head1 NAME

Mojo::EventTimer - Event logging and timing object

=head1 SYNOPSIS

    my $timer = Mojo::EventTimer->new();

    $timer->record( "something happened" );
    ...
    $timer->record( "something else happened" );
    ... etc

    my $report = $timer->report; # arrayref of timed events
    print $timer->report_text;   # string of timed events

    my $total_time = $timer->total_time;

    $timer->restart; # clear log to use timer again

=head1 DESCRIPTION

Simple timer object, logs events along with the time passed since the
timer started (in seconds, with three decimal places).

Used by L<Mojolicious::Plugin::EventTimer>

=head1 METHODS

=head2 record

    $timer->record( $event_name );

Record that an event took place.

=head2 report

    my $report_aref = $timer->report;

Return arrayref of timed events.

=head2 report_text

    my $report_str = $timer->report_text;

Returns C<report> as a single text string.

=head2 total_time

    my $total_time = $timer->total_time;

Returns total time elapsed.

=head2 restart

    $timer->restart;

Clears the event log and restarts the timer.

=head1 AUTHOR

Nigel Hamilton B<NIGE>

=head1 CONTRIBUTORS

=over

=item Michael Jemmeson E<lt>mjemmeson@cpan.orgE<gt>

=back

=head1 COPYRIGHT

Copyright 2014- Broadbean Technology Ltd

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

