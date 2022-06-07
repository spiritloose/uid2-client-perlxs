[![Actions Status](https://github.com/spiritloose/uid2-client-perl/workflows/test/badge.svg)](https://github.com/spiritloose/uid2-client-perl/actions) [![MetaCPAN Release](https://badge.fury.io/pl/UID2-Client.svg)](https://metacpan.org/release/UID2-Client)
# NAME

UID2::Client - Unified ID 2.0 Client for Perl (binding to the UID2 C++ library)

# SYNOPSIS

    use UID2::Client qw(IDENTITY_SCOPE_UID2);

    my $client = UID2::Client->new({
        endpoint => '...',
        auth_key => '...',
        secret_key => '...',
        identity_scope => IDENTITY_SCOPE_UID2,
    });
    my $result = $client->refresh();
    die $result->{reason} unless $result->{is_success};
    my $decrypted = $client->decrypt($uid2_token);
    if ($result->{is_success}) {
        say $result->{uid};
    }

# DESCRIPTION

This module provides an interface to Unified ID 2.0 API.

# CONSTRUCTOR METHODS

## new

    my $client = UID2::Client->new(\%options);

Creates and returns a new UID2 client with a hashref of options.

Valid options are:

- endpoint

    The UID2 Endpoint (eg: https://prod.uidapi.com).

    Please note that not to specify a trailing slash.

- auth\_key

    A bearer token in the request's authorization header.

- secret\_key

    A secret key for encrypting/decrypting the request/response body.

- identity\_scope

    UID2 or EUID.

All options are required.

# METHODS

## refresh

    my $result = $client->refresh();

Fetch the latest keys and returns a hashref containing the response. The hashref will have the following keys:

- is\_success
- reason

## refresh\_json

    my $result = $client->refresh_json($json);

Updates keys with the JSON string and returns a hashref containing the response. The hashref will have same keys of _refresh_.

## decrypt

    my $result = $client->decrypt($token);

Decrypts an advertising token and returns a hashref containing the response. The hashref will have the following keys:

- is\_success
- status
- uid
- site\_id
- established

## encrypt\_data

    my $result = $client->encrypt_data($data, \%request);

Encrypts arbitrary data with a hashref of requests.

Valid options are:

- site\_id
- advertising\_token
- now

Returns a hashref containing the response. The hashref will have the following keys:

- is\_success
- status
- encrypted\_data

## decrypt\_data

    my $result = $client->decrypt_data($encrypted_data);

Decrypts data encrypted with _encrypt\_data_. Returns a hashref containing the response. The hashref will have the following keys:

- is\_success
- status
- decrypted\_data
- encrypted\_at

# CONSTANTS

- IDENTITY\_SCOPE\_UID2
- IDENTITY\_SCOPE\_EUID
- IDENTITY\_TYPE\_EMAIL
- IDENTITY\_TYPE\_PHONE
- DECRYPTION\_STATUS\_SUCCESS
- DECRYPTION\_STATUS\_NOT\_AUTHORIZED\_FOR\_KEY
- DECRYPTION\_STATUS\_NOT\_INITIALIZED
- DECRYPTION\_STATUS\_INVALID\_PAYLOAD
- DECRYPTION\_STATUS\_EXPIRED\_TOKEN
- DECRYPTION\_STATUS\_KEYS\_NOT\_SYNCED
- DECRYPTION\_STATUS\_VERSION\_NOT\_SUPPORTED
- DECRYPTION\_STATUS\_INVALID\_PAYLOAD\_TYPE
- DECRYPTION\_STATUS\_INVALID\_IDENTITY\_SCOPE
- ENCRYPTION\_STATUS\_SUCCESS
- ENCRYPTION\_STATUS\_NOT\_AUTHORIZED\_FOR\_KEY
- ENCRYPTION\_STATUS\_NOT\_INITIALIZED
- ENCRYPTION\_STATUS\_KEYS\_NOT\_SYNCED
- ENCRYPTION\_STATUS\_TOKEN\_DECRYPT\_FAILURE
- ENCRYPTION\_STATUS\_KEY\_INACTIVE
- ENCRYPTION\_STATUS\_ENCRYPTION\_FAILURE

# SEE ALSO

[https://github.com/IABTechLab/uid2-client-cpp11](https://github.com/IABTechLab/uid2-client-cpp11)

# AUTHOR

Jiro Nishiguchi <jiro@cpan.org>
