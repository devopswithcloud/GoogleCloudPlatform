import base64
import os


def generate_encryption_key():
    """Generates a 256 bit (32 byte) AES encryption key and prints the
    base64 representation.
    This is included for demonstration purposes. You should generate your own
    key. Please remember that encryption keys should be handled with a
    comprehensive security policy.
    """
    key = os.urandom(32)
    encoded_key = base64.b64encode(key).decode("utf-8")

    print("Base 64 encoded encryption key: {}".format(encoded_key))


# [END storage_generate_encryption_key]

if __name__ == "__main__":
    generate_encryption_key()
