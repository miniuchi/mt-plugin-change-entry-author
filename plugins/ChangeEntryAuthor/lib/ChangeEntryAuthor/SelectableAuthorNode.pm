package ChangeEntryAuthor::SelectableAuthorNode;
use strict;
use warnings;

use MT::Util;
use ChangeEntryAuthor::SelectableAuthors;

sub create {
    my $class  = shift;
    my ($args) = @_;
    my $app    = $args->{app};
    my $entry  = $args->{entry};
    my $tmpl   = $args->{tmpl};

    my $iter = ChangeEntryAuthor::SelectableAuthors->load_iter(
        {   blog_id => $entry->blog_id,
            type    => $entry->class,
        }
    );

    my $select_options_html = '';
    my $current_author_id   = $entry ? $entry->author_id : 0;
    while ( my $author = $iter->() ) {
        my $author_id = $author->id;
        my $escaped_author_nickname
            = MT::Util::encode_html( $author->nickname );
        my $selected
            = $author_id == $current_author_id
            ? ' selected="selected"'
            : '';
        $select_options_html
            .= qq{<option value="$author_id"$selected>$escaped_author_nickname</option>};
    }

    my $select_class = _get_select_class( $app->version_number );
    $tmpl->createTextNode(
        qq{<select name="new_author_id" id="author-id" class="$select_class">$select_options_html</select>}
    );
}

sub _get_select_class {
    my ($version_number) = @_;
    $version_number >= 7
        ? 'custom-select form-control full'
        : 'full';
}

1;

