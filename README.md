# NAME

Mojolicious::Plugin::EventTimer - Mojolicious plugin to provide simple event duration logging

# SYNOPSIS

    $app->plugin(
        "Mojolicious::Plugin::EventTimer",
        {   json_key  => 'timer',    # default
            stash_key => 'timer',    # default
        }
    );

# DESCRIPTION

Mojolicious plugin to time events within a request. 

# AUTHOR

Michael Jemmeson <mjemmeson@cpan.org>

# CONTRIBUTORS

- Nigel Hamilton __NIGE__

# COPYRIGHT

Copyright 2014- Broadbean Technology Ltd

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
