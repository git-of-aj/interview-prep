### /etc/passwd vs /etc/shadow
The major difference is that they contain different pieces of data.
- passwd contains the users' public information (UID, full name, home directory) => readable by everyone,
- while shadow contains the hashed password and the password expiry data. => readable by root 
