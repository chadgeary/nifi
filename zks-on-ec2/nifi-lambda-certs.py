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

def lambda_handler(event, context):

    now = datetime.datetime.now()
    expire_date = now + datetime.timedelta(days=3650)

    # PARAMETER
    ssm = boto3.client('ssm', region_name=os.environ['REGION'])
    nifi_secret = ssm.get_parameter(
        Name=os.environ['PREFIX']+'-nifi-secret-'+os.environ['SUFFIX'],
        WithDecryption=True
    )

    s3 = boto3.resource('s3')

    s3_object = list(s3.Bucket(os.environ['BUCKET']).objects.filter(Prefix='nifi/certificates/'))
    if len(s3_object) == 5:
        print('Certificates found, skipping.')
    else:
        print('Certificates not found, generating.')

        # Valid dates
        now = datetime.datetime.now()
        expire_date = now + datetime.timedelta(days=3650)

        # CA
        ca_private_key = rsa.generate_private_key(
            public_exponent=65537,
            key_size=2048,
            backend=backends.default_backend()
        )

        ca_public_key = ca_private_key.public_key()
        builder = x509.CertificateBuilder()
        builder = builder.subject_name(x509.Name([
            x509.NameAttribute(NameOID.COMMON_NAME, u"NIFICA"),
        ]))
        builder = builder.issuer_name(x509.Name([
            x509.NameAttribute(NameOID.COMMON_NAME, u"NIFICA"),
        ]))
        builder = builder.not_valid_before(now)
        builder = builder.not_valid_after(expire_date)
        builder = builder.serial_number(x509.random_serial_number())
        builder = builder.public_key(ca_public_key)
        builder = builder.add_extension(
            x509.BasicConstraints(ca=True, path_length=None),
            critical=True)
        ca_certificate = builder.sign(
            private_key=ca_private_key, algorithm=hashes.SHA256(), backend=backends.default_backend()
        )
        ca_private_bytes = ca_private_key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.TraditionalOpenSSL,
            encryption_algorithm=serialization.BestAvailableEncryption(str.encode(nifi_secret['Parameter']['Value'])))
        ca_public_bytes = ca_certificate.public_bytes(
            encoding=serialization.Encoding.PEM)

        # ADMIN
        admin_private_key = rsa.generate_private_key(
            public_exponent=65537,
            key_size=2048,
            backend=backends.default_backend()
        )

        admin_public_key = admin_private_key.public_key()
        builder2 = x509.CertificateBuilder()
        builder2 = builder2.subject_name(x509.Name([
            x509.NameAttribute(NameOID.ORGANIZATIONAL_UNIT_NAME, u"NIFI"),
            x509.NameAttribute(NameOID.COMMON_NAME, u"admin")
        ]))
        builder2 = builder2.issuer_name(x509.Name([
            x509.NameAttribute(NameOID.COMMON_NAME, u"NIFICA"),
        ]))
        builder2 = builder2.not_valid_before(now)
        builder2 = builder2.not_valid_after(expire_date)
        builder2 = builder2.serial_number(x509.random_serial_number())
        builder2 = builder2.public_key(admin_public_key)
        builder2 = builder2.add_extension(
            x509.KeyUsage(digital_signature=True, content_commitment=False, key_encipherment=True, data_encipherment=True, key_agreement=True, key_cert_sign=True, crl_sign=False, encipher_only=False, decipher_only=False),
            critical=True)
        builder2 = builder2.add_extension(
            x509.ExtendedKeyUsage([x509.oid.ExtendedKeyUsageOID.CLIENT_AUTH]),
            critical=True)
        admin_certificate = builder2.sign(
            private_key=ca_private_key, algorithm=hashes.SHA256(), backend=backends.default_backend()
        )
        admin_private_bytes = admin_private_key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.TraditionalOpenSSL,
            encryption_algorithm=serialization.BestAvailableEncryption(str.encode(nifi_secret['Parameter']['Value'])))
        admin_public_bytes = admin_certificate.public_bytes(
            encoding=serialization.Encoding.PEM)

        # ADMIN PKCS12
        admin_p12 = pkcs12.serialize_key_and_certificates(
            b"admin",
            admin_private_key,
            admin_certificate,
            None,
            serialization.BestAvailableEncryption(str.encode(nifi_secret['Parameter']['Value']))
        )

        # UPLOAD
        files = {
            'nifi/certificates/ca/ca.pem': io.BytesIO(ca_public_bytes),
            'nifi/certificates/ca/ca.key': io.BytesIO(ca_private_bytes),
            'nifi/certificates/admin/admin_cert.pem': io.BytesIO(admin_public_bytes),
            'nifi/certificates/admin/private_key.key': io.BytesIO(admin_private_bytes),
            'nifi/certificates/admin/keystore.p12': io.BytesIO(admin_p12)
        }
        for key in files:
            s3.meta.client.upload_fileobj(
                files[key],
                os.environ['BUCKET'],
                key,
                ExtraArgs={'ServerSideEncryption':'aws:kms','SSEKMSKeyId':os.environ['KEY']})
            print(key + ' put to s3.')

    return {
        'statusCode': 200,
        'body': json.dumps('Complete')
    }
