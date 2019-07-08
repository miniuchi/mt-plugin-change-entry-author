package ChangeEntryAuthor::Transformer;
use strict;
use warnings;

use MT::Util;
use ChangeEntryAuthor::AuthorSettingElement;

sub template_param_edit_entry {
    my ( $cb, $app, $param, $tmpl ) = @_;

    my $blog     = $app->blog;
    my $type     = $param->{object_type} || '';
    my $entry_id = $param->{id};

    return unless _can_add_author_setting( $app, $blog, $type, $entry_id );

    my $entry = $app->model($type)->load($entry_id);
    my $user  = $app->user;

    my $author_setting = ChangeEntryAuthor::AuthorSettingElement->create(
        {   app                => $app,
            can_select_authors => _can_select_authors( $user, $blog->id ),
            entry              => $entry,
            tmpl               => $tmpl,
        }
    );

    $tmpl->insertBefore( $author_setting,
        $tmpl->getElementById('authored_on') );
}

sub _can_add_author_setting {
    my ( $app, $blog, $type, $entry_id ) = @_;

    return unless $entry_id && $blog && $blog->id;

    my $perm
        = $type eq 'page'
        ? 'open_batch_page_editor_via_list'
        : 'open_batch_entry_editor_via_list';
    $app->can_do($perm);
}

sub _can_select_authors {
    my ( $user, $blog_id ) = @_;
    return 1
        if $user->can('can_manage_users_groups')
        ? $user->can_manage_users_groups
        : $user->is_superuser;
    $user->permissions($blog_id)->can_do('open_select_author_dialog');
}

1;

