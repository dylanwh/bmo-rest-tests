#!/usr/bin/perl
use 5.20.0;
use warnings;
use experimental qw(signatures);
use lib 'lib';

use HTTP::Request::Common;
use LWP::UserAgent;
use JSON::XS;
use Test::More;
use Test::JSON::More 'JSON::XS';

use BMO::Test::Schema;

my @tests = (
    {
        name => "get_888",
        schema => GET_BUG,
        request => sub($url) {
            GET "$url/rest/bug/888",
        },
    },
    {
        name => "get_888_inc",
        schema => GET_BUG,
        request => sub($url) {
            GET "$url/rest/bug/888?include_fields=keywords,deadline",
        },
    },
    {
        name => "get_version",
        request => sub($url) {
            GET "$url/rest/version",
        },
        schema => {
            type => "object",
            properties => {
                version => { type => "string" }
            },
            required => ["version"],
        },
    },
    {
        name => "get_extensions",
        request => sub ($url) {
            GET "$url/rest/extensions",
        },
        schema => {
            type => "object",
            properties => {
                "extensions" => { type => "object" },
            },
        }
    },
    {
        name => "get_timezone",
        request => sub ($url) {
            GET "$url/rest/timezone",
        },
        schema => {
            type => "object",
            properties => {
                "timezone" => { type => "string" },
            },
            required => ["timezone"],
        },
    },
    {
        name => "get_fields",
        request => sub ($url) {
            GET "$url/rest/field/bug",
        },
    },
);

my $site_base = 'http://bugzilla.vm/bmo';
my $site_diff = 'http://bugzilla.vm/1289886';

my $ua = LWP::UserAgent->new;

sub _headers ($msg) {
    return [ $msg->headers->header_field_names ];
}

sub _content_type ($msg) {
    return $msg->header('Content-Type');
}

foreach my $test (@tests) {
    my $f      = $test->{request};
    my $schema = $test->{schema};

    my $request_base = $f->($site_base);
    my $request_diff = $f->($site_diff);

    my $response_base = $ua->request($request_base);
    my $response_diff = $ua->request($request_diff);

    my $content_base  = $response_base->content;
    my $content_diff  = $response_diff->content;

    is($response_base->code, $response_diff->code, "->code");
    is(_content_type($response_base), _content_type($response_diff), "Content-Type");
    is_deeply(_headers($response_base), _headers($response_diff), "headers");

    ok_json($content_base, "content_base");
    ok_json($content_diff, "content_diff");
    cmp_json($content_base, $content_diff, "content is same json document");
    if ($schema) {
        ok_json_schema($content_base, $schema, "schema of base");
        ok_json_schema($content_diff, $schema, "schema of diff");
    }
}


done_testing;
