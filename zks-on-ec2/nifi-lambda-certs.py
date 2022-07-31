import boto3
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives.serialization import pkcs12
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat import backends
from cryptography import x509
from cryptography.x509.oid import NameOID
import datetime
import io
import json
import os

# A private key
def gen_privatekey():
    privatekey = rsa.generate_private_key(
        public_exponent=65537, key_size=4096, backend=backends.default_backend()
    )
    return privatekey


# PEM encoded PKCS8 + encryption of privatekey using secret
def gen_privatebytes(identity_privatekey, secret):
    privatebytes = identity_privatekey.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.BestAvailableEncryption(secret),
    )
    return privatebytes


# A public key from the private key
def gen_publickey(identity_privatekey):
    identity_publickey = identity_privatekey.public_key()
    return identity_publickey


# PEM encoded public key
def gen_publicbytes(identity_publickey):
    publicbytes = identity_publickey.public_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PublicFormat.SubjectPublicKeyInfo,
    )
    return publicbytes


# Create a CA-signed cert using an identity's context
def gen_x509(
    platform_name,
    identity_name,
    identity_publickey,
    ca_name,
    ca_privatekey,
    is_ca,
    is_client,
    is_server,
):
    builder = x509.CertificateBuilder()

    # CAs do not get OU
    if is_ca:
        builder = builder.subject_name(
            x509.Name([x509.NameAttribute(NameOID.COMMON_NAME, identity_name)])
        )
    else:
        builder = builder.subject_name(
            x509.Name(
                [
                    x509.NameAttribute(NameOID.ORGANIZATIONAL_UNIT_NAME, platform_name),
                    x509.NameAttribute(NameOID.COMMON_NAME, identity_name),
                ]
            )
        )
    builder = builder.issuer_name(
        x509.Name(
            [
                x509.NameAttribute(NameOID.COMMON_NAME, ca_name),
            ]
        )
    )
    builder = builder.not_valid_before(now)
    builder = builder.not_valid_after(expire_date)
    builder = builder.serial_number(x509.random_serial_number())
    builder = builder.public_key(identity_publickey)

    # CAs get BasicConstraints
    if is_ca:
        builder = builder.add_extension(
            x509.BasicConstraints(ca=True, path_length=None), critical=True
        )

    # Client+Servers get KeyUsage, ExtendedKeyUsage CLIENT_AUTH + SERVER_AUTH, and SAN DNSName
    if is_client and is_server:
        builder = builder.add_extension(
            x509.KeyUsage(
                digital_signature=True,
                content_commitment=False,
                key_encipherment=True,
                data_encipherment=True,
                key_agreement=True,
                key_cert_sign=True,
                crl_sign=False,
                encipher_only=False,
                decipher_only=False,
            ),
            critical=True,
        )
        builder = builder.add_extension(
            x509.ExtendedKeyUsage(
                [
                    x509.oid.ExtendedKeyUsageOID.SERVER_AUTH,
                    x509.oid.ExtendedKeyUsageOID.CLIENT_AUTH,
                ]
            ),
            critical=True,
        )
        builder = builder.add_extension(
            x509.SubjectAlternativeName(
                [x509.DNSName(identity_name), x509.DNSName("localhost")]
            ),
            critical=False,
        )

    # Clients get KeyUsage, ExtendedKeyUsage CLIENT_AUTH
    if is_client and not is_server:
        builder = builder.add_extension(
            x509.KeyUsage(
                digital_signature=True,
                content_commitment=False,
                key_encipherment=True,
                data_encipherment=True,
                key_agreement=True,
                key_cert_sign=True,
                crl_sign=False,
                encipher_only=False,
                decipher_only=False,
            ),
            critical=True,
        )
        builder = builder.add_extension(
            x509.ExtendedKeyUsage([x509.oid.ExtendedKeyUsageOID.CLIENT_AUTH]),
            critical=True,
        )

    certificate = builder.sign(
        private_key=ca_privatekey,
        algorithm=hashes.SHA256(),
        backend=backends.default_backend(),
    )
    return certificate


# Write the certificate to S3
def upload_certificate_to_s3(identity_certificate_path):
    with open(identity_certificate_path, "rb") as certificate_path:
        certificate = x509.load_pem_x509_certificate(certificate_path.read())
    return certificate


# Create a certificate store
def gen_certificatestore(
    identity_name, identity_privatekey, identity_certificate, ca_certificate, secret
):
    certificatestore = pkcs12.serialize_key_and_certificates(
        str.encode(identity_name),
        identity_privatekey,
        identity_certificate,
        [ca_certificate],
        serialization.BestAvailableEncryption(secret),
    )
    return certificatestore


def lambda_handler(event, context):

    # Identities at bootstrap requiring certificates
    identities = {
        "ca": {"name": "nifica", "is_ca": True, "is_client": False, "is_server": False},
        "admin": {
            "name": "admin",
            "is_ca": False,
            "is_client": True,
            "is_server": False,
        },
        "node1": {
            "name": "node1",
            "is_ca": False,
            "is_client": True,
            "is_server": True,
        },
        "node2": {
            "name": "node2",
            "is_ca": False,
            "is_client": True,
            "is_server": True,
        },
        "node3": {
            "name": "node2",
            "is_ca": False,
            "is_client": True,
            "is_server": True,
        },
    }

    # Check for certificates in S3, because this only runs if they don't exist
    s3 = boto3.resource("s3")
    s3_object = list(
        s3.Bucket(os.environ["BUCKET"]).objects.filter(Prefix="nifi/certificates/ca/")
    )
    if len(s3_object) >= 2:
        print("Certificates found, skipping.")
    else:
        print("Certificates not found, generating.")

        # 5 o'clock somewhere, setting an absurdly long certificate lifetime
        global now
        now = datetime.datetime.now()
        global expire_date
        expire_date = now + datetime.timedelta(days=3650)
        print(
            "Generated certificates will be valid between "
            + now.strftime("%Y-%m-%d %H:%M:%S %Z")
            + " and "
            + expire_date.strftime("%Y-%m-%d %H:%M:%S %Z")
        )

        # Get nifi-secret for encryption
        ssm = boto3.client("ssm", region_name=os.environ["REGION"])
        ssm_secret = ssm.get_parameter(
            Name=os.environ["PREFIX"] + "-nifi-secret-" + os.environ["SUFFIX"],
            WithDecryption=True,
        )
        secret = str.encode(ssm_secret["Parameter"]["Value"])

        # Loop over identities to create a private key, public key, certificate, and certificate store
        for identity in identities:

            # Local directories and file names
            os.makedirs(
                "/tmp/nifi/certificates/" + identities[identity].get("name"),
                exist_ok=True,
            )

            keyfilename = (
                "/tmp/nifi/certificates/"
                + identities[identity].get("name")
                + "/"
                + identities[identity].get("name")
                + ".key"
            )
            pemfilename = (
                "/tmp/nifi/certificates/"
                + identities[identity].get("name")
                + "/"
                + identities[identity].get("name")
                + ".pem"
            )
            pkcs12filename = (
                "/tmp/nifi/certificates/"
                + identities[identity].get("name")
                + "/"
                + identities[identity].get("name")
                + ".p12"
            )

            # privatekey generation
            identity_privatekey = gen_privatekey()
            identities[identity]["privatekey"] = identity_privatekey

            identity_privatebytes = gen_privatebytes(
                identities[identity].get("privatekey"), secret
            )

            # privatekey write
            identities[identity]["privatebytes"] = identity_privatebytes
            with open(
                os.open(keyfilename, os.O_CREAT | os.O_WRONLY, 0o600), "wb"
            ) as file:
                file.write(identities[identity]["privatebytes"])
            print(keyfilename + " written")

            # publickey from privatekey
            identity_publickey = gen_publickey(identity_privatekey)
            identities[identity]["publickey"] = identity_publickey
            identity_publicbytes = gen_publicbytes(identity_publickey)
            identities[identity]["publicbytes"] = identity_publicbytes

            # ca-signed certificate
            identity_certificate = gen_x509(
                u"NIFI",
                identities[identity].get("name"),
                identities[identity].get("publickey"),
                identities["ca"].get("name"),
                identities["ca"].get("privatekey"),
                identities[identity].get("is_ca"),
                identities[identity].get("is_client"),
                identities[identity].get("is_server"),
            )
            identities[identity]["certificate"] = identity_certificate

            with open(
                os.open(pemfilename, os.O_CREAT | os.O_WRONLY, 0o600), "wb"
            ) as file:
                file.write(
                    identities[identity]["certificate"].public_bytes(
                        serialization.Encoding.PEM
                    )
                )
            print(pemfilename + " written")

            # CERTIFICATE STORE (.p12)
            identity_certstore = gen_certificatestore(
                identities[identity].get("name"),
                identities[identity].get("privatekey"),
                identities[identity].get("certificate"),
                identities["ca"].get("certificate"),
                secret,
            )
            identities[identity]["certstore"] = identity_certstore

            with open(
                os.open(pkcs12filename, os.O_CREAT | os.O_WRONLY, 0o600), "wb"
            ) as file:
                file.write(identities[identity]["certstore"])
            print(pkcs12filename + " written")

            # UPLOAD
            files = {
                "nifi/certificates/ca/ca.pem": "/tmp/nifi/certificates/nifica/nifica.pem",
                "nifi/certificates/ca/ca.key": "/tmp/nifi/certificates/nifica/nifica.key",
                "nifi/certificates/admin/admin_cert.pem": "/tmp/nifi/certificates/admin/admin.pem",
                "nifi/certificates/admin/private_key.key": "/tmp/nifi/certificates/admin/admin.key",
                "nifi/certificates/admin/keystore.p12": "/tmp/nifi/certificates/admin/admin.p12",
            }
        for key in files:
            s3.meta.client.upload_file(
                files[key],
                os.environ["BUCKET"],
                key,
                ExtraArgs={
                    "ServerSideEncryption": "aws:kms",
                    "SSEKMSKeyId": os.environ["KEY"],
                },
            )
            print({"s3_upload": key, "msg": json.dumps("Complete")})

    return {"statusCode": 200, "body": json.dumps("Complete")}
