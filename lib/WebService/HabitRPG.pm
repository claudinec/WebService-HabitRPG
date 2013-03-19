package WebService::HabitRPG;
use v5.010;
use strict;
use warnings;
use autodie;
use Moo;
use WWW::Mechanize; # Probably overkill
use Method::Signatures;
use JSON::Any;

# ABSTRACT: Perl interface to the HabitRPG API

# VERSION: Generated by DZP::OurPkg:Version

=for Pod::Coverage BUILD DEMOLISH

=cut

has 'api_token' => (is => 'ro'); # aka x-api-key
has 'user_id'   => (is => 'ro'); # aka x-api-user
has 'agent'     => (is => 'rw');

use constant URL_BASE => 'http://habitrpg.com/api/v1';

my $json = JSON::Any->new;

sub BUILD {
    my ($self, $args) = @_;

    # Set a default agent if we don't already have one.

    if (not $self->agent) {
        $self->agent(
            WWW::Mechanize->new(
                agent => "Perl/$], WebService::HabitRPG/" . $self->VERSION,
            )
        );
    }

    return;
}

method user() {

    my $req = $self->_request('GET', '/user');

    my $response = $self->agent->request( $req );

    return $response->decoded_content;
}

method user_tasks() {

    my $req = $self->_request('GET', '/user/tasks');

    my $response = $self->agent->request( $req );

    return $response->decoded_content;
}

method get_task($task_id) {

    my $req = $self->_request('GET', "/user/task/$task_id");

    my $response = $self->agent->request( $req );

    return $response->decoded_content;
}

method new_task(
    :$type! where qr{ habit | daily | todo | reward }x,
    :$text!,
    :$completed,
    :$value = 0,
    :$note = ''
) {

    my $payload = $json->encode({
        type      => $type,
        text      => $text,
        completed => $completed,
        value     => $value,
        note      => $note,
    });

    my $req = $self->_request('POST', '/user/task');

    $req->content( $payload );

    return $self->agent->request( $req )->decoded_content;

}

method _request($type, $url) {

    my $req = HTTP::Request->new( $type, URL_BASE . $url );
    $req->header( 'Content-Type' => 'application/json');
    $req->header( 'x-api-user'   => $self->user_id    );
    $req->header( 'x-api-key'    => $self->api_token  );

    return $req;
}

1;
