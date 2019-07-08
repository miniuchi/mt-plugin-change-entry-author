package ChangeEntryAuthor::Transformer;
use strict;
use warnings;

use MT::Util;
use ChangeEntryAuthor::SelectableAuthors;

sub template_param_edit_entry {
    my ( $cb, $app, $param, $tmpl ) = @_;

    return unless $param->{id};
    return unless $app->blog && $app->blog->id;

    my $type = $param->{object_type} || '';
    my $open_batch_perm
        = $type eq 'page'
        ? 'open_batch_page_editor_via_list'
        : 'open_batch_entry_editor_via_list';
    return unless $app->can_do($open_batch_perm);

    _insert_author_setting_before_authored_on( $app, $param, $tmpl, $type );
}

sub _insert_author_setting_before_authored_on {
    my ( $app, $param, $tmpl, $type ) = @_;
    my $blog_id = $app->blog->id;
    my $user    = $app->user;

    my $author_setting = $tmpl->createElement(
        'app:setting',
        {   id          => 'author_id',
            label       => $app->translate('Author'),
            label_class => 'top-label',
        },
    );

    my $author_is_selectable = (
          $user->can('can_manage_users_groups')
        ? $user->can_manage_users_groups
        : $user->is_superuser
        )
        || $user->permissions($blog_id)->can_do('open_select_author_dialog');
    my $author_select_node
        = $author_is_selectable
        ? _generate_selectable_author_node( $app, $param, $tmpl, $type )
        : _generate_unselectable_author_node( $app, $param, $tmpl, $type );

    $author_setting->appendChild($author_select_node);

    $tmpl->insertBefore( $author_setting,
        $tmpl->getElementById('authored_on') );
}

sub _generate_selectable_author_node {
    my ( $app, $param, $tmpl, $type ) = @_;

    my $select_options_html = '';
    my $entry               = $app->model($type)->load( $param->{id} );
    my $current_author_id   = $entry ? $entry->author_id : 0;
    my $iter                = ChangeEntryAuthor::SelectableAuthors->load_iter(
        {   blog_id => $app->blog->id,
            type    => $type,
        }
    );
    while ( my $author = $iter->() ) {
        my $author_id = $author->id;
        my $escaped_author_nickname
            = MT::Util::encode_html( $author->nickname );
        my $selected
            = ( $author_id == $current_author_id )
            ? ' selected="selected"'
            : '';
        $select_options_html
            .= qq{<option value="$author_id"$selected>$escaped_author_nickname</option>};
    }

    my $select_class
        = $app->version_number >= 7
        ? 'custom-select form-control full'
        : 'full';

    $tmpl->createTextNode(
        qq{<select name="new_author_id" id="author-id" class="$select_class">$select_options_html</select>}
    );
}

sub _generate_unselectable_author_node {
    my ( $app, $param, $tmpl, $type ) = @_;
    my $entry          = $app->model($type)->load( $param->{id} );
    my $current_author = $entry ? $entry->author : undef;
    my $escaped_author_nickname
        = $current_author
        ? MT::Util::encode_html( $current_author->nickname )
        : '(' . $app->translate('No author available') . ')';
    return $tmpl->createTextNode("<div>$escaped_author_nickname</div>");
}

1;

