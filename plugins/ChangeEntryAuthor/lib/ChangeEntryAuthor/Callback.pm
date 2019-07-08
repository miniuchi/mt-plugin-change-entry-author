package ChangeEntryAuthor::Callback;
use strict;
use warnings;

sub cms_pre_save_entry {
    my ( $eh, $app, $obj ) = @_;

    my $type = $app->param('_type') || '';
    my $perm_action
        = $type eq 'page' ? 'save_multiple_pages' : 'save_multiple_entries';
    return 1 unless $app->can_do($perm_action);

    my $author_id = $app->param('new_author_id');
    if ( $author_id && $author_id =~ /^[0-9]+$/ ) {
        $obj->author_id($author_id);
    }

    1;
}

1;

