package ChangeEntryAuthor::SelectableAuthors;
use strict;
use warnings;

use MT::Author;
use MT::Permission;

sub load_iter {
    my $class   = shift;
    my ($args)  = @_;
    my $type    = $args->{type};
    my $blog_id = $args->{blog_id};

    die unless $type && $blog_id;

    MT::Author->load_iter(
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

1;

