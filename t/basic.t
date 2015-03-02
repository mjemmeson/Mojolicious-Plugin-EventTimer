use Test::More;

use strict;
use warnings;
use Mojo::JSON;
use Test::Mojo;
use Time::HiRes qw/ usleep /;

BEGIN {

    package MyApp;

    use Mojo::Base 'Mojolicious';

    sub startup {
        my $self = shift;

        $self->plugin(
            "Mojolicious::Plugin::EventTimer",
            {   stash_key      => "my_timer_log",
                json_key       => "my_timer",
                include_report => 1,
            }
        );

        my $r = $self->routes;

        $r->get('/foo')->to("Foo#foo");
        $r->get('/foo_json')->to("Foo#foo_json");
    }

    package MyApp::Foo;

    use Mojo::Base 'Mojolicious::Controller';

    sub foo {
        my $self = shift;

        my $template = <<'EOF';
Timer total:
<%= $my_timer_log->{total} %>
Timer log:
<%= $my_timer_log->{report} %>
EOF
        $self->render(
            inline  => $template,
            handler => 'ep',
            format  => 'text',
        );

    }

    sub foo_json {
        my $self = shift;
        $self->render( json => { foo => 'bar' } );
    }
}

ok my $t = Test::Mojo->new("MyApp");

subtest "standard" => sub {

        $t->get_ok('/foo?timer=1')    #
            ->status_is(200)          #
            ->content_type_is('text/plain');

        like $t->tx->res->body, qr/Timer total:\n\d+\.\d+\n/,
            'timer total in body';
        like $t->tx->res->body,
            qr/Timer log:\n\[\d+\.\d+\] Foo#foo - started\n/,
            'timer log in body';
        like $t->tx->res->body, qr/\n\[\d+\.\d+\] Foo#foo - finished\n/,
            'timer log in body';
};

subtest "json" => sub {
        $t->get_ok('/foo_json')    #
            ->status_is(200)       #
            ->content_type_is('application/json');

        my $json = Mojo::JSON->new->decode( $t->tx->res->body );

        ok $json->{my_timer}, "got my_timer_log";
        ok $json->{my_timer}->{total},  "total set";
        ok $json->{my_timer}->{report}, "report set";

};

done_testing;

