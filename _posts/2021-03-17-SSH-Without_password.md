---
title: Things I Always Forget How To Do - SSH without password
published: true
---

As I work on the development of embedded linux device, I am accessing remote machines over ssh all the time. Authenticate the connection with passwords can be very annoying when it is the 50th time you do it in the same day this is why is a good idea to avoid authenticate with passwords.

## How It Works

The idea is simple, to access the machine B from the machine A without password, it is needed to save the ssh public key of the machine A on the authorized_keys file of the machine B.

## Script to do it quickly 
Optional: If your machine A doesn't have a pair of authentication keys you need to generate it:
``` bash
ssh-keygen -t rsa
```

Change the MACHINE_B variable:
``` bash
MACHINE_B=user@myniceip
ssh $MACHINE_B mkdir -p .ssh
cat .ssh/id_rsa.pub | ssh $MACHINE_B 'cat >> .ssh/authorized_keys'
```

You'll need to input the user password for the machine B 2 times and it's done!
