use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('UID2::Client');
    use_ok('UID2::Client::DecryptionStatus');
    use_ok('UID2::Client::EncryptionStatus');
    use_ok('UID2::Client::IdentityScope');
    use_ok('UID2::Client::IdentityType');
    use_ok('UID2::Client::Timestamp');
};

done_testing;
