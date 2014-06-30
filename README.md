# NAME

Boxcar - Simple push notification sender for Boxcar 2

# SYNOPSIS

    use Boxcar qw(broadcast notify);

    $res = Boxcar->broadcast($app_id,
                             $access_key,
                             $secret_key,
                             timeout => $timeout,
                             expires => time + 3600,
                             tags => ['@all'],
                             badge => $badge,
                             message => $message,
                             sound => $sound);

    $res = Boxcar->notify($token,
                          timeout => $timeout,
                          title => $title,
                          message => $message,
                          sound => $sound,
                          source => $source);

# DESCRIPTION

Boxcar is the simple push notification sender for Boxcar 2 ([http://boxcar.io/](http://boxcar.io/)).

See [http://boxcar.io/developer](http://boxcar.io/developer).

# METHODS

## `Boxcar->broadcast($app_id, $access_key, $secret_key, %opts)`

- $app\_id
- $access\_key
- $secret\_key
- timeout
- expires
- tags
- badge
- message
- sound

## `Boxcar->notify($token, %opts)`

- $token
- timeout
- title
- message
- sound
- source

# LICENSE

Copyright (C) Sharl Morlaroll.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Sharl Morlaroll <sharl@hauN.org>
