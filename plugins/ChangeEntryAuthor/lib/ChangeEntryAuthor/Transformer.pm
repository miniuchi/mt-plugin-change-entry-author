package ChangeEntryAuthor::Transformer;
use strict;
use warnings;

use MT::Author;
use MT::Permission;
use MT::Util;

sub template_param_edit_entry {
    my ( $cb, $app, $param, $tmpl ) = @_;

    return unless $param->{id};
    return unless $app->blog && $app->blog->id;

    my $type            = $param->{object_type} || '';
    my $open_batch_perm = $type eq 'page'
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
        {   id    => 'author_id',
            label => $app->translate('Author'),
        },
    );

    my $author_is_selectable = $user->can_manage_users_groups
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

    my @selectable_authors
        = _load_selectable_authors( $type, $app->blog->id );
    my $entry             = $app->model($type)->load( $param->{id} );
    my $current_author_id = $entry ? $entry->author_id : 0;

    my $select_options_html = '';
    for my $author (@selectable_authors) {
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

    $tmpl->createTextNode(
        qq{<select name="new_author_id" id="author-id" class="custom-select form-control full">$select_options_html</select>}
    );
}

sub _load_selectable_authors {
    my ( $type, $blog_id ) = @_;
    MT::Author->load(
        undef,
        {   sort => 'name',
            join => MT::Permission->join_on(
                'author_id',
                {   (   $type eq 'page'
                        ? ( permissions => "%\'manage_pages\'%" )
                        : ( permissions => "%\'create_post\'%" )
                    ),
                    blog_id => $blog_id,
                },
                { 'like' => { 'permissions' => 1 }, unique => 1 },
            ),
        }
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

