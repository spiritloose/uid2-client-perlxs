package t::TestUtils;
use strict;
use warnings;

use Crypt::Mode::CBC;
use Crypt::Misc qw(encode_b64);
use Crypt::PRNG qw(random_bytes irand);
use Time::HiRes qw(gettimeofday);
use JSON::PP;

sub encrypt_token {
    my %args = @_;
    my $privacy_bit = irand();
    my $established_ms = int((gettimeofday() - (60 * 60)) * 1000);
    my $identity = pack 'N! N! a* N! q>',
            $args{site_id}, length($args{id_str}), $args{id_str}, $privacy_bit, $established_ms;
    my $identity_iv = random_bytes(16);

    my $expires_ms = $args{token_expiry} ? $args{token_expiry}->get_epoch_milli
            : int((gettimeofday() + (60 * 60)) * 1000);
    my $master_payload = pack 'q> a*', $expires_ms, _encrypt($identity, $args{site_key}, $identity_iv);
    my $master_iv = random_bytes(16);

    my $version = 2;
    my $token = pack 'C a*', $version, _encrypt($master_payload, $args{master_key}, $master_iv);
    encode_b64($token);
}

sub _encrypt {
    my ($data, $key, $iv) = @_;
    my $cipher = Crypt::Mode::CBC->new('AES');
    pack 'N! a16 a*', $key->{id}, $iv, $cipher->encrypt($data, $key->{secret}, $iv);
}

sub key_set_to_json {
    my @keys = @_;
    encode_json({ body => [
        map {
            my $key = $_;
            +{
                (map { $_ => $key->{$_} } qw(id site_id)),
                (map { $_ => $key->{$_}->get_epoch_second } qw(created activates expires)),
                secret => encode_b64($key->{secret}),
            }
        } @keys
    ]});
}

1;
__END__
