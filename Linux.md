### /etc/passwd vs /etc/shadow
The major difference is that they contain different pieces of data.
- passwd contains the users' public information (UID, full name, home directory) => readable by everyone,
```sh 
google:x:1000:1000:google search:/home/google:/bin/bash
```
- while shadow contains the hashed password and the password expiry data. => readable by root
```sh
amazon:$6$GjtgpLxdaueFJfiCRlZpg3qYTGjp.:18868:0:99999:7:::
```
> Note: The /etc/passwd and /etc/shadow files are linked/connected together by the user ID (UID) field.
