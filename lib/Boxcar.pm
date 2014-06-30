# -*- mode: perl coding: utf-8 -*-
package Boxcar;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";


use JSON 'encode_json';
use Digest::HMAC_SHA1 'hmac_sha1_hex';
use URI::Escape 'uri_escape';
use HTTP::Request;
use LWP::UserAgent;

# http://developer.boxcar.io/api/publisher/

sub broadcast {
    my ($self, $app_id, $access_key, $secret_key, %opts) = @_;

    my $timeout = $opts{timeout} || 10;
    my $expires = $opts{expires};
    my $tags    = $opts{tags};
    # aps items
    my $badge   = $opts{badge};		# if omited, badge is unchanged, 'auto' is counter.
    my $message = $opts{message};
    my $sound   = $opts{sound};

    # payload builder
    my $data = {
	id => $app_id
    };
    $data->{expires} = $expires if $expires;
    $data->{tags}    = $tags    if $tags;
    # aps builder
    $data->{aps}{badge} = $badge   if $badge;
    $data->{aps}{alert} = $message if $message;
    $data->{aps}{sound} = $sound   if $sound;

    my $payload = encode_json($data);

    my $BOXCAR_DOMAIN = 'boxcar-api.io';
    my $signature = hmac_sha1_hex(sprintf("POST\n%s\n/api/push\n%s",
					  $BOXCAR_DOMAIN,
					  $payload),
				  $secret_key);
    my $endpoint = sprintf(
	"https://$BOXCAR_DOMAIN/api/push?publishkey=%s&signature=%s",
	uri_escape($access_key),
	uri_escape($signature)
	);

    my $req = HTTP::Request->new(POST => $endpoint);
    $req->header('Content-Type' => 'application/json');
    $req->content($payload);
    my $res = LWP::UserAgent->new(timeout => $timeout)->request($req);
    unless ($res->is_success) {
	return $res->message;
    }

    undef;
}

# https://boxcar.uservoice.com/knowledgebase/articles/306788-how-to-send-your-boxcar-account-a-notification

sub notify {
    my ($self, $token, %opts) = @_;

    my $timeout = $opts{timeout} || 10;
    my $title   = $opts{title};
    my $message = $opts{message};
    my $sound   = $opts{sound}   || 'clanging';
    my $source  = $opts{source}  || __PACKAGE__.'.pm';

    my $data = {
	user_credentials => $token,
	'notification[title]' => $title,
	'notification[long_message]' => $message,
	'notification[sound]' => $sound,
	'notification[source_name]' => $source,
    };
    my $res = LWP::UserAgent->new(timeout => $timeout)->post(
	'https://new.boxcar.io/api/notifications',
	$data);
    unless ($res->is_success) {
	return $res->message;
    }

    undef;
}

1;
__END__

=encoding utf-8

=head1 NAME

Boxcar - Simple push notification sender for Boxcar 2

=head1 SYNOPSIS

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

=head1 DESCRIPTION

Boxcar is the simple push notification sender for Boxcar 2 (L<http://boxcar.io/>).

See L<http://boxcar.io/developer>.

=head1 METHODS

=head2 C<< Boxcar->broadcast($app_id, $access_key, $secret_key, %opts) >>

=over

=item $app_id

=item $access_key

=item $secret_key

=item timeout

=item expires

=item tags

=item badge

=item message

=item sound

=back

=head2 C<< Boxcar->notify($token, %opts) >>

=over

=item $token

=item timeout

=item title

=item message

=item sound

=item source

=back

=head1 LICENSE

Copyright (C) Sharl Morlaroll.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Sharl Morlaroll E<lt>sharl@hauN.orgE<gt>

=cut

