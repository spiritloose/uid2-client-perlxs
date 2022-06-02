package UID2::Client;
use 5.008005;
use strict;
use warnings;
use Exporter 'import';

our $VERSION = "0.01";

our @EXPORT_OK = qw(
    DECRYPTION_STATUS_SUCCESS
    DECRYPTION_STATUS_NOT_AUTHORIZED_FOR_KEY
    DECRYPTION_STATUS_NOT_INITIALIZED
    DECRYPTION_STATUS_INVALID_PAYLOAD
    DECRYPTION_STATUS_EXPIRED_TOKEN
    DECRYPTION_STATUS_KEYS_NOT_SYNCED
    DECRYPTION_STATUS_VERSION_NOT_SUPPORTED
    DECRYPTION_STATUS_INVALID_PAYLOAD_TYPE
    ENCRYPTION_STATUS_SUCCESS
    ENCRYPTION_STATUS_NOT_AUTHORIZED_FOR_KEY
    ENCRYPTION_STATUS_NOT_INITIALIZED
    ENCRYPTION_STATUS_KEYS_NOT_SYNCED
    ENCRYPTION_STATUS_TOKEN_DECRYPT_FAILURE
    ENCRYPTION_STATUS_KEY_INACTIVE
    ENCRYPTION_STATUS_ENCRYPTION_FAILURE
);

require XSLoader;
XSLoader::load('UID2::Client', $VERSION);

require UID2::Client::Timestamp;

1;
__END__

=encoding utf-8

=head1 NAME

UID2::Client - Unified ID 2.0 Client for Perl (binding to the UID2 C++ library)

=head1 SYNOPSIS

  use UID2::Client;

  my $client = UID2::Client->new({
      endpoint => '...',
      auth_key => '...',
  });
  my $result = $client->refresh();
  die $result->{reason} unless $result->{is_success};
  my $decrypted = $client->decrypt($uid2_token);
  if ($result->{is_success}) {
      say $result->{uid};
  }

=head1 DESCRIPTION

This module provides an interface to Unified ID 2.0 API.

=head1 CONSTRUCTOR METHODS

=head2 new

  my $client = UID2::Client->new(\%options);

Creates and returns a new UID2 client with a hashref of options.

Valid options are:

=over

=item endpoint

The UID2 Endpoint (eg: https://prod.uidapi.com).

Please note that not to specify a trailing slash.

=item auth_key

A bearer token in the request's authorization header.

=back

All options are required.

=head1 METHODS

=head2 refresh

  my $result = $client->refresh();

Fetch the latest keys and returns a hashref containing the response. The hashref will have the following keys:

=over

=item is_success

=item reason

=back

=head2 refresh_json

  my $result = $client->refresh_json($json);

Updates keys with the JSON string and returns a hashref containing the response. The hashref will have same keys of I<refresh>.

=head2 decrypt

  my $result = $client->decrypt($token);

Decrypts an advertising token and returns a hashref containing the response. The hashref will have the following keys:

=over

=item is_success

=item status

=item uid

=item site_id

=item established

=back

=head2 encrypt_data

  my $result = $client->encrypt_data($data, \%request);

Encrypts arbitrary data with a hashref of requests.

Valid options are:

=over

=item site_id

=item advertising_token

=item now

=back

Returns a hashref containing the response. The hashref will have the following keys:

=over

=item is_success

=item status

=item encrypted_data

=back

=head2 decrypt_data

  my $result = $client->decrypt_data($encrypted_data);

Decrypts data encrypted with I<encrypt_data>. Returns a hashref containing the response. The hashref will have the following keys:

=over

=item is_success

=item status

=item decrypted_data

=item encrypted_at

=back

=head1 CONSTANTS

=over

=item DECRYPTION_STATUS_SUCCESS

=item DECRYPTION_STATUS_NOT_AUTHORIZED_FOR_KEY

=item DECRYPTION_STATUS_NOT_INITIALIZED

=item DECRYPTION_STATUS_INVALID_PAYLOAD

=item DECRYPTION_STATUS_EXPIRED_TOKEN

=item DECRYPTION_STATUS_KEYS_NOT_SYNCED

=item DECRYPTION_STATUS_VERSION_NOT_SUPPORTED

=item DECRYPTION_STATUS_INVALID_PAYLOAD_TYPE

=item ENCRYPTION_STATUS_SUCCESS

=item ENCRYPTION_STATUS_NOT_AUTHORIZED_FOR_KEY

=item ENCRYPTION_STATUS_NOT_INITIALIZED

=item ENCRYPTION_STATUS_KEYS_NOT_SYNCED

=item ENCRYPTION_STATUS_TOKEN_DECRYPT_FAILURE

=item ENCRYPTION_STATUS_KEY_INACTIVE

=item ENCRYPTION_STATUS_ENCRYPTION_FAILURE

=back

=head1 SEE ALSO

L<https://github.com/IABTechLab/uid2-client-cpp11>

=head1 AUTHOR

Jiro Nishiguchi E<lt>jiro@cpan.orgE<gt>

=cut
