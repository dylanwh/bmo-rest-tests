use 5.20.0;
use warnings;
use experimental qw(signatures);
use Exporter;
use base qw(Exporter);

our @EXPORT = qw(BUG GET_BUG);

sub nullable($type) { return { oneOf => [ $type, { type => "null" } ] } }

use constant BUG => {
    type       => "object",
    properties => {
        actual_time           => { type => "double" },
        alias                 => nullable({type => "string"}),
        assigned_to           => { type => "string" },
        assigned_to_detail    => { type => "object" },
        blocks                => { type => "array" },
        cc                    => { type => "array" },
        cc_detail             => { type => "array" },
        classification        => { type => "string" },
        component             => { type => "string" },
        creation_time         => { type => "string" },
        creator               => { type => "string" },
        creator_detail        => { type => "object" },
        deadline              => nullable({ type => "string" }),
        depends_on            => { type => "array" },
        dupe_of               => nullable({ type => "integer" }),
        estimated_time        => { type => "double" },
        flags                 => { type => "array" },
        groups                => { type => "array" },
        id                    => { type => "integer" },
        is_cc_accessible      => { type => "boolean" },
        is_confirmed          => { type => "boolean" },
        is_open               => { type => "boolean" },
        is_creator_accessible => { type => "boolean" },
        keywords              => { type => "array" },
        last_change_time      => { type => "string" },
        op_sys                => { type => "string" },
        platform              => { type => "string" },
        priority              => { type => "string" },
        product               => { type => "string" },
        qa_contact            => { type => "string" },
        qa_contact_detail     => { type => "object" },
        remaining_time        => { type => "double" },
        resolution            => { type => "string" },
        see_also              => { type => "array" },
        severity              => { type => "string" },
        status                => { type => "string" },
        summary               => { type => "string" },
        target_milestone      => { type => "string" },
        update_token          => { type => "string" },
        url                   => { type => "string" },
        version               => { type => "string" },
        whiteboard            => { type => "string" },
    },
};

use constant GET_BUG => {
    type       => "object",
    properties => {
        faults => { type => "array", },
        bugs   => {
            type  => "array",
            items => BUG,
        },
    },
    required => [ "faults", "bugs" ],
};

1;
