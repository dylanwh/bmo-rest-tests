use 5.20.0;
use warnings;
use experimental qw(signatures);
use Exporter;
use base qw(Exporter);

our @EXPORT = qw(BUG GET_BUG ERROR BUG_MODAL_EDIT GET_FIELDS);

use constant STRING_T => { type => "string" };
use constant INT_T    => { type => "integer" };
use constant BOOL_T   => { type => "boolean" };
use constant NULL_T   => { type => "null" };
use constant ARRAY_T  => { type => "array" };

sub ONE_OF {
    return { oneOf => [@_] };
}

sub OPTIONAL_T($type) :prototype($) { ONE_OF($type, NULL_T) }

sub ARRAY_OF($type) :prototype($) {
    return { type => "array", items => $type }
}

use constant BUG => {
    type       => "object",
    properties => {
        actual_time           => { type => "double" },
        alias                 => OPTIONAL_T(STRING_T),
        assigned_to           => STRING_T,
        assigned_to_detail    => { type => "object" },
        blocks                => { type => "array" },
        cc                    => { type => "array" },
        cc_detail             => { type => "array" },
        classification        => STRING_T,
        component             => STRING_T,
        creation_time         => STRING_T,
        creator               => STRING_T,
        creator_detail        => { type => "object" },
        deadline              => OPTIONAL_T(STRING_T),
        depends_on            => { type => "array" },
        dupe_of               => OPTIONAL_T(INT_T),
        estimated_time        => { type => "double" },
        flags                 => { type => "array" },
        groups                => { type => "array" },
        id                    => INT_T,
        is_cc_accessible      => BOOL_T,
        is_confirmed          => BOOL_T,
        is_open               => BOOL_T,
        is_creator_accessible => BOOL_T,
        keywords              => { type => "array" },
        last_change_time      => STRING_T,
        op_sys                => STRING_T,
        platform              => STRING_T,
        priority              => STRING_T,
        product               => STRING_T,
        qa_contact            => STRING_T,
        qa_contact_detail     => { type => "object" },
        remaining_time        => { type => "double" },
        resolution            => STRING_T,
        see_also              => { type => "array" },
        severity              => STRING_T,
        status                => STRING_T,
        summary               => STRING_T,
        target_milestone      => STRING_T,
        update_token          => STRING_T,
        url                   => STRING_T,
        version               => STRING_T,
        whiteboard            => STRING_T,
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

use constant ERROR => {
    type       => "object",
    properties => {
        documentation => STRING_T,
        error         => BOOL_T,
        code          => INT_T,
        message       => STRING_T,
    },
    required => [qw( error code message documentation )],
};

use constant NAME_LIST => {
    type => "array",
    items => {
        type => "object",
        properties => {
            name => STRING_T,
        },
        required => ["name"],
    },
};

use constant BUG_MODAL_EDIT_OPTIONS => qw(
    product component version target_milestone priority bug_severity rep_platform op_sys
);

use constant BUG_MODAL_EDIT => {
    type => "object",
    properties => {
        options => {
            type => "object",
            properties => {
                map { ($_ => NAME_LIST) } BUG_MODAL_EDIT_OPTIONS,
            },
            required => [BUG_MODAL_EDIT_OPTIONS],
        },
        keywords => {
            type => "array",
            items => STRING_T,
        },
    },
};

use constant GET_FIELDS => {
    type       => "object",
    properties => {
        "fields" => ARRAY_OF {
            type       => "object",
            properties => {
                id                => INT_T,
                name              => STRING_T,
                display_name      => STRING_T,
                type              => INT_T,
                is_mandatory      => BOOL_T,
                value_field       => OPTIONAL_T(STRING_T),
                values            => ARRAY_OF {
                    type => "object",
                    properties => {
                        sort_key          => INT_T,
                        name              => STRING_T,
                        visibility_values => ARRAY_T,
                        sortkey           => INT_T,
                    },
                    required => [qw[sort_key name visibility_values sortkey]],
                },
                visibility_values => ARRAY_OF { type => "string" },
                visibility_field  => OPTIONAL_T(STRING_T),
                is_on_bug_entry   => BOOL_T,
                is_custom         => BOOL_T,
            },
            required => [
                qw[ id name display_name type is_mandatory
                    is_on_bug_entry
                    is_custom
                    visibility_values
                    visibility_field
                    ]
            ],
        }
    },
};


1;
