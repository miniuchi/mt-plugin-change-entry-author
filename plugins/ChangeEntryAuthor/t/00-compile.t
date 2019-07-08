use strict;
use warnings;

use Test::More;

use lib './lib', './extlib', './plugins/ChangeEntryAuthor/lib';

use_ok('ChangeEntryAuthor::Callback');
use_ok('ChangeEntryAuthor::L10N');
use_ok('ChangeEntryAuthor::L10N::ja');
use_ok('ChangeEntryAuthor::Transformer');

done_testing;

