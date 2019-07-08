package ChangeEntryAuthor::UnselectableAuthorNode;
use strict;
use warnings;

use MT::Util;

sub create {
    my $class  = shift;
    my ($args) = @_;
    my $app    = $args->{app};
    my $entry  = $args->{entry};
    my $tmpl   = $args->{tmpl};

    my $current_author = $entry ? $entry->author : undef;
    my $escaped_author_nickname
        = $current_author
        ? MT::Util::encode_html( $current_author->nickname )
        : '(' . $app->translate('No author available') . ')';
    return $tmpl->createTextNode("<div>$escaped_author_nickname</div>");
}

1;

