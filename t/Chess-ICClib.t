# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Chess-ICClib.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 4;
BEGIN { use_ok('Chess::ICClib') };
our $icc;

ok($icc=&set_icc());
ok(&test_command());
ok(&test_paged_command());
sub set_icc {

    $icc = Chess::ICClib->new(-prompt=>'aics%',
			      -user=>'guest');
    return $icc;
}
sub test_command {

    my $response = $icc->ICCCommand('info');

    return $response =~ /GM-bio/i;

}
sub test_paged_command {

    my $response = $icc->ICCCommand('help fees');

    return $response =~ /Free Memberships/i;
}
#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

