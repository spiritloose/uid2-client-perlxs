#ifdef __cplusplus
extern "C" {
#endif
#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef __cplusplus
}
#endif

/* Hack to work around "error: declaration of 'Perl___notused' has a different */
/* language linkage" error on Clang */
#ifdef dNOOP
# undef dNOOP
# define dNOOP
#endif

#ifdef do_open
#undef do_open
#endif
#ifdef do_close
#undef do_close
#endif

#define NEED_newCONSTSUB
#include "ppport.h"
#include "uid2/uid2client.h"

static SV*
make_refresh_result(pTHX_ uid2::RefreshResult result)
{
    HV* hv = newHV();
    if (result.IsSuccess()) {
        hv_stores(hv, "is_success", newSViv(1));
    } else {
        hv_stores(hv, "is_success", newSViv(0));
        std::string reason = result.GetReason();
        hv_stores(hv, "reason", newSVpvn(reason.c_str(), reason.size()));
    }
    return newRV_noinc((SV*) hv);
}

static SV*
make_timestamp(pTHX_ uid2::Timestamp t)
{
    SV* res = newSV(0);
    sv_setref_pv(res, "UID2::Client::Timestamp", (void *) new uid2::Timestamp(t));
    return newRV_noinc(res);
}

MODULE = UID2::Client PACKAGE = UID2::Client

BOOT:
{
    HV* stash = gv_stashpv("UID2::Client", 1);

    newCONSTSUB(stash, "DECRYPTION_STATUS_SUCCESS",
            newSViv(static_cast<int>(uid2::DecryptionStatus::SUCCESS)));
    newCONSTSUB(stash, "DECRYPTION_STATUS_NOT_AUTHORIZED_FOR_KEY",
            newSViv(static_cast<int>(uid2::DecryptionStatus::NOT_AUTHORIZED_FOR_KEY)));
    newCONSTSUB(stash, "DECRYPTION_STATUS_NOT_INITIALIZED",
            newSViv(static_cast<int>(uid2::DecryptionStatus::NOT_INITIALIZED)));
    newCONSTSUB(stash, "DECRYPTION_STATUS_INVALID_PAYLOAD",
            newSViv(static_cast<int>(uid2::DecryptionStatus::INVALID_PAYLOAD)));
    newCONSTSUB(stash, "DECRYPTION_STATUS_EXPIRED_TOKEN",
            newSViv(static_cast<int>(uid2::DecryptionStatus::EXPIRED_TOKEN)));
    newCONSTSUB(stash, "DECRYPTION_STATUS_KEYS_NOT_SYNCED",
            newSViv(static_cast<int>(uid2::DecryptionStatus::KEYS_NOT_SYNCED)));
    newCONSTSUB(stash, "DECRYPTION_STATUS_VERSION_NOT_SUPPORTED",
            newSViv(static_cast<int>(uid2::DecryptionStatus::VERSION_NOT_SUPPORTED)));
    newCONSTSUB(stash, "DECRYPTION_STATUS_INVALID_PAYLOAD_TYPE",
            newSViv(static_cast<int>(uid2::DecryptionStatus::INVALID_PAYLOAD_TYPE)));

    newCONSTSUB(stash, "ENCRYPTION_STATUS_SUCCESS",
            newSViv(static_cast<int>(uid2::EncryptionStatus::SUCCESS)));
    newCONSTSUB(stash, "ENCRYPTION_STATUS_NOT_AUTHORIZED_FOR_KEY",
            newSViv(static_cast<int>(uid2::EncryptionStatus::NOT_AUTHORIZED_FOR_KEY)));
    newCONSTSUB(stash, "ENCRYPTION_STATUS_NOT_INITIALIZED",
            newSViv(static_cast<int>(uid2::EncryptionStatus::NOT_INITIALIZED)));
    newCONSTSUB(stash, "ENCRYPTION_STATUS_KEYS_NOT_SYNCED",
            newSViv(static_cast<int>(uid2::EncryptionStatus::KEYS_NOT_SYNCED)));
    newCONSTSUB(stash, "ENCRYPTION_STATUS_TOKEN_DECRYPT_FAILURE",
            newSViv(static_cast<int>(uid2::EncryptionStatus::TOKEN_DECRYPT_FAILURE)));
    newCONSTSUB(stash, "ENCRYPTION_STATUS_KEY_INACTIVE",
            newSViv(static_cast<int>(uid2::EncryptionStatus::KEY_INACTIVE)));
    newCONSTSUB(stash, "ENCRYPTION_STATUS_ENCRYPTION_FAILURE",
            newSViv(static_cast<int>(uid2::EncryptionStatus::ENCRYPTION_FAILURE)));
}

PROTOTYPES: DISABLE

uid2::UID2Client*
uid2::UID2Client::new(options)
    HV* options;
CODE:
    SV** ent;
    const char* endpoint = nullptr;
    const char* auth_key = nullptr;
    if ((ent = hv_fetchs(options, "endpoint", 0)) != NULL) {
        endpoint = SvPV_nolen(*ent);
    }
    if ((ent = hv_fetchs(options, "auth_key", 0)) != NULL) {
        auth_key = SvPV_nolen(*ent);
    }
    if (endpoint == nullptr || auth_key == nullptr) {
        croak("endpoint and auth_key are required");
    }
    RETVAL = new uid2::UID2Client(endpoint, auth_key);
OUTPUT:
    RETVAL

SV*
uid2::UID2Client::refresh()
CODE:
    uid2::RefreshResult result = uid2::RefreshResult::MakeError("");
    try {
        result = THIS->Refresh();
    }
    catch (std::exception& e) {
        croak("%s", e.what());
    }
    catch (const char * str) {
        croak("%s", str);
    }
    catch (...) {
        croak("exception occurred during refresh()");
    }
    RETVAL = make_refresh_result(aTHX_ result);
OUTPUT:
    RETVAL

SV*
uid2::UID2Client::refresh_json(json)
    const char* json;
CODE:
    uid2::RefreshResult result = uid2::RefreshResult::MakeError("");
    try {
        result = THIS->RefreshJson(json);
    }
    catch (std::exception& e) {
        croak("%s", e.what());
    }
    catch (const char * str) {
        croak("%s", str);
    }
    catch (...) {
        croak("exception occurred during refresh_json()");
    }
    RETVAL = make_refresh_result(aTHX_ result);
OUTPUT:
    RETVAL

SV*
uid2::UID2Client::decrypt(token, now = nullptr)
    const char* token;
    uid2::Timestamp* now;
CODE:
    uid2::Timestamp timestamp;
    if (now == nullptr) {
        timestamp = uid2::Timestamp::Now();
    } else {
        timestamp = *now;
    }
    uid2::DecryptionResult result = uid2::DecryptionResult::MakeError(uid2::DecryptionStatus::NOT_INITIALIZED);
    try {
        result = THIS->Decrypt(token, timestamp);
    }
    catch (std::exception& e) {
        croak("%s", e.what());
    }
    catch (const char * str) {
        croak("%s", str);
    }
    catch (...) {
        croak("exception occurred during decrypt()");
    }
    HV* res = newHV();
    hv_stores(res, "is_success", result.IsSuccess() ? newSViv(1) : newSV(0));
    hv_stores(res, "status", newSViv(static_cast<int>(result.GetStatus())));
    if (result.IsSuccess()) {
        std::string uid = result.GetUid();
        hv_stores(res, "uid", newSVpvn(uid.c_str(), uid.size()));
        hv_stores(res, "site_id", newSViv(result.GetSiteId()));
        hv_stores(res, "established", make_timestamp(result.GetEstablished()));
    }
    RETVAL = newRV_noinc((SV *) res);
OUTPUT:
    RETVAL

SV*
uid2::UID2Client::encrypt_data(data, req)
    SV* data;
    HV* req;
CODE:
    STRLEN len;
    const char* data_char = SvPV(data, len);
    uid2::EncryptionDataRequest request((uint8_t *) data_char, len);
    SV** ent;
    if ((ent = hv_fetchs(req, "site_id", 0)) != NULL) {
        request = request.WithSiteId(SvIV(*ent));
    }
    if ((ent = hv_fetchs(req, "advertising_token", 0)) != NULL) {
        const char* at = SvPV(*ent, len);
        request = request.WithAdvertisingToken(std::string(at, len));
    }
    if ((ent = hv_fetchs(req, "initialization_vector", 0)) != NULL) {
        const char* iv = SvPV(*ent, len);
        request = request.WithInitializationVector((uint8_t *) iv, len);
    }
    if ((ent = hv_fetchs(req, "now", 0)) != NULL) {
        if (!(sv_isobject(*ent) && (SvTYPE(SvRV(*ent)) == SVt_PVMG))) {
            croak("invalid type: now");
        }
        uid2::Timestamp* t = (uid2::Timestamp *) SvIV((SV*) SvRV(*ent));
        request = request.WithNow(*t);
    }
    uid2::EncryptionDataResult result = uid2::EncryptionDataResult::MakeError(uid2::EncryptionStatus::NOT_INITIALIZED);
    try {
        result = THIS->EncryptData(request);
    }
    catch (std::exception& e) {
        croak("%s", e.what());
    }
    catch (const char * str) {
        croak("%s", str);
    }
    catch (...) {
        croak("exception occurred during encrypt_data()");
    }
    HV* res = newHV();
    hv_stores(res, "is_success", result.IsSuccess() ? newSViv(1) : newSV(0));
    hv_stores(res, "status", newSViv(static_cast<int>(result.GetStatus())));
    if (result.IsSuccess()) {
        std::string str = result.GetEncryptedData();
        hv_stores(res, "encrypted_data", newSVpvn(str.c_str(), str.size()));
    }
    RETVAL = newRV_noinc((SV *) res);
OUTPUT:
    RETVAL

SV*
uid2::UID2Client::decrypt_data(encrypted_data)
    const char* encrypted_data;
CODE:
    uid2::DecryptionDataResult result = uid2::DecryptionDataResult::MakeError(uid2::DecryptionStatus::NOT_INITIALIZED);
    try {
        result = THIS->DecryptData(encrypted_data);
    }
    catch (std::exception& e) {
        croak("%s", e.what());
    }
    catch (const char * str) {
        croak("%s", str);
    }
    catch (...) {
        croak("exception occurred during decrypt_data()");
    }
    HV* res = newHV();
    hv_stores(res, "is_success", result.IsSuccess() ? newSViv(1) : newSV(0));
    hv_stores(res, "status", newSViv(static_cast<int>(result.GetStatus())));
    if (result.IsSuccess()) {
        const std::vector<std::uint8_t> data = result.GetDecryptedData();
        const std::string str(data.begin(), data.end());
        hv_stores(res, "decrypted_data", newSVpvn(str.c_str(), str.size()));
        hv_stores(res, "encrypted_at", make_timestamp(result.GetEncryptedAt()));
    }
    RETVAL = newRV_noinc((SV *) res);
OUTPUT:
    RETVAL

void
uid2::UID2Client::DESTROY()
CODE:
    delete THIS;

MODULE = UID2::Client PACKAGE = UID2::Client::Timestamp

PROTOTYPES: DISABLE

static uid2::Timestamp*
UID2::Client::Timestamp::now()
CODE:
    RETVAL = new uid2::Timestamp(uid2::Timestamp::Now());
OUTPUT:
    RETVAL

static uid2::Timestamp*
UID2::Client::Timestamp::from_epoch_second(epoch_second)
    int64_t epoch_second;
CODE:
    RETVAL = new uid2::Timestamp(uid2::Timestamp::FromEpochSecond(epoch_second));
OUTPUT:
    RETVAL

static uid2::Timestamp*
UID2::Client::Timestamp::from_epoch_milli(epoch_milli)
    int64_t epoch_milli;
CODE:
    RETVAL = new uid2::Timestamp(uid2::Timestamp::FromEpochMilli(epoch_milli));
OUTPUT:
    RETVAL

int64_t
uid2::Timestamp::get_epoch_second()
CODE:
    RETVAL = THIS->GetEpochSecond();
OUTPUT:
    RETVAL

int64_t
uid2::Timestamp::get_epoch_milli()
CODE:
    RETVAL = THIS->GetEpochMilli();
OUTPUT:
    RETVAL

bool
uid2::Timestamp::is_zero()
CODE:
    RETVAL = THIS->IsZero();
OUTPUT:
    RETVAL

uid2::Timestamp*
uid2::Timestamp::add_seconds(seconds)
    int seconds;
PREINIT:
    const char* CLASS = "UID2::Client::Timestamp";
CODE:
    RETVAL = new uid2::Timestamp(THIS->AddSeconds(seconds));
OUTPUT:
    RETVAL

uid2::Timestamp*
uid2::Timestamp::add_days(days)
    int days;
PREINIT:
    const char* CLASS = "UID2::Client::Timestamp";
CODE:
    RETVAL = new uid2::Timestamp(THIS->AddDays(days));
OUTPUT:
    RETVAL

void
uid2::Timestamp::DESTROY()
CODE:
    delete THIS;
