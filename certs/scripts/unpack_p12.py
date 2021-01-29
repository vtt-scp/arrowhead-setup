"""
Python .p12 certificate store unpacker.

Requires Python > 3.7.
"""

import os
import sys
from cryptography.hazmat.primitives.serialization import pkcs12

try:
    from OpenSSL import crypto
except ImportError:
    print(
        "Could not import OpenSSL",
        "You may install it with command:",
        "pip install pyOpenSSL",
        sep="\n",
    )
    sys.exit()


class P12:

    """Unpack Certificate, Private key and CA certificates from a .p12 file.

    Properties:
        .crt    Certificate
        .key    Private key
        .ca     CA certificates

    Methods:
        .unpack_to_files()  Unpack crt, key and ca to files

    Requests usage example:
        import requests
        from unpack_p12 import P12

        certs = P12('./path/to/file.p12', p4ssphr4se)

        with requests.Session() as ses:
            ses.cert = (certs.crt, certs.key)
            ses.verify = certs.ca

            ses.get(<https_url>)
    """

    def __init__(self, filepath: str, passwd: str = None) -> None:

        if passwd is None:
            passwd = os.environ.get("P12_CERT_PASSPHRASE", None)

        if passwd is not None:
            passwd = passwd.encode()

        try:
            self.p12 = crypto.load_pkcs12(open(filepath, "rb").read(), passwd)
        except crypto.Error as err:
            err.args[0].append("possibly incorrect passphrase")
            raise err

        # TODO Implement below instead due to future deprecation
        """ with open(filepath, "rb") as p12:
            self._key, self._crt, self._ca = pkcs12.load_key_and_certificates(
                p12, passwd
            ) """

        self.filename = filepath.split("/")[-1].split(".")[0]
        self.folder = "/".join(filepath.split("/")[:-1]) + "/"

        self._crt = None
        self._key = None
        self._ca = None

    @property
    def crt(self) -> str:
        """Unpack certificate to file and return filepath"""

        if self._crt is not None:
            return self._crt
        filename = self.folder + self.filename + ".crt"
        with open(filename, "wb") as crt_file:
            crt_file.write(
                crypto.dump_certificate(crypto.FILETYPE_PEM, self.p12.get_certificate())
            )

        self._crt = filename
        return filename

    @property
    def key(self) -> str:
        """Unpack private key to file and return filepath"""

        if self._key is not None:
            return self._key
        filename = self.folder + self.filename + ".key"
        with open(filename, "wb") as key_file:
            key_file.write(
                crypto.dump_privatekey(crypto.FILETYPE_PEM, self.p12.get_privatekey())
            )

        self._key = filename
        return filename

    @property
    def ca(self) -> str:
        """Unpack CA certificates to file and return filepath"""

        if self._ca is not None:
            return self._ca
        ca_list = []
        for ca in self.p12.get_ca_certificates():
            ca_list.append(crypto.dump_certificate(crypto.FILETYPE_PEM, ca))

        filename = self.folder + self.filename + ".ca"
        with open(filename, "wb") as ca_file:
            ca_file.write(b"".join(ca_list))

        self._ca = filename
        return filename

    def unpack_to_files(self) -> (str, str, str):
        """Unpack crt, key and ca to files and return filepaths"""

        return (self.crt, self.key, self.ca)


if __name__ == "__main__":

    if len(sys.argv) != 3:
        print(
            "Requires filepath to .p12 file and passphrase as arguments.",
            "For example:",
            f"python {sys.argv[0]} ./path/to/file.p12 p4ssphr4se",
            sep="\n",
        )
        sys.exit()

    cert = P12(sys.argv[1], sys.argv[2])
    print("Created file: " + cert.crt)
    print("Created file: " + cert.key)
    print("Created file: " + cert.ca)
