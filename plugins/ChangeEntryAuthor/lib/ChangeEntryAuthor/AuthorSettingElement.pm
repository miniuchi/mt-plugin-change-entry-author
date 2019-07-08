package ChangeEntryAuthor::AuthorSettingElement;
use strict;
use warnings;

use MT;
use ChangeEntryAuthor::SelectableAuthorNode;
use ChangeEntryAuthor::UnselectableAuthorNode;

sub create {
    my $class              = shift;
    my ($args)             = @_;
    my $app                = $args->{app};
    my $can_select_authors = $args->{can_select_authors};
    my $entry              = $args->{entry};
    my $tmpl               = $args->{tmpl};

    die unless $entry && $tmpl;

    my $element = $tmpl->createElement(
        'app:setting',
        {   id          => 'author_id',
            label       => $app->translate('Author'),
            label_class => 'top-label',
        },
    );

    my $node;
    if ($can_select_authors) {
        $node = ChangeEntryAuthor::SelectableAuthorNode->create(
            {   app      => $app,
                entry    => $entry,
                tmpl     => $tmpl,
            }
        );
    }
    else {
        $node = ChangeEntryAuthor::UnselectableAuthorNode->create(
            {   app   => $app,
                entry => $entry,
                tmpl  => $tmpl,
            }
        );
    }

    $element->appendChild($node);

    $element;
}

1;

