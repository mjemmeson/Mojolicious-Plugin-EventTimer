package Mojo::EventTimer;

# VERSION

use Mojo::Base 'Mojo';

use Time::HiRes qw(gettimeofday tv_interval);

has event_log  => sub { [] };
has start_time => sub { [gettimeofday] };

=head1 NAME

Mojo::EventTimer - Event logging and timing

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

=cut

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

