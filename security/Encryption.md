## Symmetric 
- Plaintext: The original message you want to protect.
- Cipher: The algorithm used to encrypt the plaintext (e.g., AES).
- Key: A secret, symmetric key used for both encryption and decryption. In AES, this key is essential for the encryption/decryption process.
- Ciphertext: The result of encrypting the plaintext using the key and cipher.
- AES: A widely used encryption standard for secure data encryption/decryption. It’s a symmetric encryption algorithm, meaning the same key is used for both encryption and decryption.

## Behind the scenes
- Cipher: Think of the cipher as a special "box" that surrounds and hides your value (the message). It's the method or algorithm that wraps your data in a way that only the right tool (key) can unlock. Without the cipher, the data wouldn’t be hidden at all.

- Key: The key is like the "iron" that is used to create the box. It's the secret material needed to build the box (encrypt) and then open it (decrypt). The key defines how the box works and ensures that only someone with the correct key can unlock the message.

| **Key Type**      | **Cipher Name**  |
|-------------------|------------------|
| Symmetric (AES)   | AES              |
| Symmetric (DES)   | DES              |
| Symmetric (3DES)  | 3DES             |
| Symmetric (Blowfish) | Blowfish        |
| Asymmetric (RSA)  | RSA              |
| Asymmetric (ECC)  | ECC              |
| Stream (RC4)      | RC4              |
| Stream (ChaCha20) | ChaCha20         |

In **symmetric encryption**, the same key is used for both encryption and decryption, while in **asymmetric encryption**, different keys are used. Stream ciphers work differently, encrypting data one bit at a time.
```txt
                        +------------------+
                        |    Plaintext     |
                        |   (Original      |
                        |   Message)       |
                        +--------+---------+
                                 |
                                 | Plaintext to Ciphertext
                                 V
                        +------------------+
                        |    Cipher        | <--- AES (Advanced Encryption Standard)
                        |  (Encryption     |
                        |   Algorithm)     |
                        +--------+---------+
                                 |
                                 | Encrypted using Key
                                 V
                        +------------------+
                        |    Key           |
                        |   (Secret        |
                        |   Symmetric Key) |
                        +--------+---------+
                                 |
                                 | Used to Encrypt/Decrypt
                                 V
                        +------------------+
                        |    Ciphertext    |
                        |   (Encrypted     |
                        |    Message)      |
                        +--------+---------+
                                 |
                                 | Ciphertext to Plaintext
                                 V
                        +------------------+
                        |  Decryption      |
                        |   (Using Key)    |
                        +------------------+
                                 |
                                 | Decrypted message
                                 V
                        +------------------+
                        |    Plaintext     |
                        | (Original        |
                        |    Message)      |
                        +------------------+
```

## Demo
```py
# Let's pretend we're sending a secret message!
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad, unpad
from Crypto.Random import get_random_bytes

# Step 1: The message we want to protect (plain text)
message = "This is a secret message!"  # Original message we want to hide

# Step 2: Generate a secret key for encryption (like a secret password)
key = get_random_bytes(16)  # A secret key (16 bytes long) to encrypt and decrypt

# Step 3: We create the "cipher" using the key. It's like a special box that locks our message.
cipher = AES.new(key, AES.MODE_CBC)

# Step 4: Encrypt the message (putting the secret message into the locked box)
# We need to make the message the right size (padding) before encryption
encrypted_message = cipher.encrypt(pad(message.encode(), AES.block_size))

# Step 5: Show the locked message (ciphertext)
print(f"Encrypted message (ciphertext): {encrypted_message}")

# Step 6: To unlock the message, we use the same key and the same cipher "box" 
# Decrypting the message (getting the original message back)
decipher = AES.new(key, AES.MODE_CBC, iv=cipher.iv)  # Using the same key and the same 'box' to unlock
decrypted_message = unpad(decipher.decrypt(encrypted_message), AES.block_size)

# Step 7: Show the original message after unlocking (decrypting)
print(f"Decrypted message: {decrypted_message.decode()}")
```
## Asymmetric
- Public key: encryption
- private key : decryption
