#!/usr/bin/perl
use 5.20.0;
use warnings;
use experimental qw(signatures);
use lib 'lib';

use HTTP::Request::Common;
use LWP::UserAgent;
use JSON::MaybeXS;
use Test::More;
use Test::JSON::More 'JSON::XS';
use File::Slurper qw(write_text);

use BMO::Test::Schema;

my $json = JSON::MaybeXS->new->pretty(1)->canonical(1);

my $site_base = 'http://bugzilla.vm/clean';
my $site_diff = 'http://bugzilla.vm/1289886';
my $api_key   = $ENV{API_KEY};
my $login     = 'dylan@mozilla.com';

my @tests = (
    {
        name => "get_888",
        schema => GET_BUG,
        request => sub($url) {
            GET "$url/rest/bug/888";
        },
    },
    {
        name => "get_1",
        schema => ERROR,
        request => sub($url) {
            GET "$url/rest/bug/1";
        },
    },
    {
        name => "get_888_inc",
        schema => GET_BUG,
        request => sub($url) {
            GET "$url/rest/bug/888?include_fields=keywords,deadline";
        },
    },
    {
        name => "get_888_exc",
        schema => GET_BUG,
        request => sub($url) {
            GET "$url/rest/bug/888?exclude_fields=deadline";
        },
    },
    {
        name => "get_version",
        request => sub($url) {
            GET "$url/rest/version";
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
            GET "$url/rest/extensions";
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
            GET "$url/rest/timezone";
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
        schema => GET_FIELDS,
        is_large => 1,
    },
    {
        name => "get_fields_888",
        request => sub ($url) {
            GET "$url/rest/field/bug/888",
        },
        schema => ERROR,
    },
    {
        name => "bug_modal_edit_304998",
        request => sub ($url) {
            GET "$url/rest/bug_modal/edit/304998";
        },
        schema => BUG_MODAL_EDIT,
    },
    {
        name => 'comment_tags_error',
        request => sub ($url) {
            GET "$url/rest/bug/comment/tags/spam";
        },
        schema => ERROR,
    },
    {
        name => 'comment_tags',
        request => sub ($url) {
            GET "$url/rest/bug/comment/tags/spam";
        },
        #    schema => { type => "array", items => { type => "string" } },
        use_api_key => 1,
    },
);

my $ua = LWP::UserAgent->new;

foreach my $test (@tests) {
    my $name   = $test->{name};
    my $f      = $test->{request};
    my $schema = $test->{schema};

    my $request_base = $f->($site_base);
    my $request_diff = $f->($site_diff);

    if ($test->{use_api_key}) {
        add_api_key($request_base, $api_key);
        add_api_key($request_diff, $api_key);
    }

    my $response_base = $ua->request($request_base);
    my $response_diff = $ua->request($request_diff);

    my $content_base  = $response_base->content;
    my $content_diff  = $response_diff->content;

    is($response_base->code, $response_diff->code, "$name code");
    is(_content_type($response_base), _content_type($response_diff), "$name Content-Type");
    is_deeply(_headers($response_base), _headers($response_diff), "$name headers");

    unless ($test->{is_large}) {
        ok_json($content_base, "$name content_base");
        ok_json($content_diff, "$name content_diff");
        cmp_json($content_base, $content_diff, "$name content is same json document");
    }
    else {
        is(length $content_base, length $content_diff, "$name, length of content");
    }

    if ($schema) {
        ok_json_schema($content_base, $schema, "$name schema of base");
        ok_json_schema($content_diff, $schema, "$name schema of diff");
    }

    eval {
        write_text("$name.base", $json->encode($json->decode($content_base)));
    };
    eval {
        write_text("$name.diff", $json->encode($json->decode($content_diff)));
    };
}


done_testing;


sub add_api_key ($req, $key) {
    $req->header('X-Bugzilla-API-Key' => $key);
}

sub _headers ($msg) {
    return [ $msg->headers->header_field_names ];
}

sub _content_type ($msg) {
    return $msg->header('Content-Type');
}

