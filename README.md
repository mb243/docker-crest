# Docker Crest

Deploy Docker container(s)

Works with `docker run $thing`, `docker-compose up`, and with almost anything else you throw at it.

Also performs basic server hardening steps:

- Updates all packages
- Installs an SSH public key
- Disables password authentication
- Disables root account logins
- Configures automatic updates
- Installs and configures fail2ban
- Configures NTP

You can skip over these by setting `$SKIP=yes` in the environment

### How are remote resources used?

You can specify a remote URL to pull in just before Docker is started. This must be a full URL and could be a `Dockerfile`, `docker-compose.yml` file, or something else entirely.

The resource is fetched using `wget`, which is installed only if a resource is specified.

### What commands can be used?

Use can supply any command, which is run as provided. This allows you to run `docker run` with your own parameters, `docker-compose up`, or anything else.

### Can this be run this standalone / unattended / as part of something else?

This script contains `read` statements to prompt you for anything not already set in the environment. The only thing not prompted is `$RESOURCE`, because it's optional. If you want to specify `$RESOURCE`, set it in the environment or declare it on the command line and it will be used.

---

Environment variables used: 

| Variable | Meaning |
| --- | --- |
| `$PUBKEY` | An SSH public key to install at runtime |
| `$SKIP` | If 'yes', server updates and hardening steps are skipped |
| `$RESOURCE` | URL of a resource to fetch |
| `$CMD` | Command to run after fetching `$RESOURCE` |

---

Mechanics:

This is a high-level overview of how all the pieces fit together, and how to expand on this.

- Stage 0 (optional)
Any preload script that might be used ([StackScript](https://www.linode.com/stackscripts), etc)

- Stage 1: `crest.sh`
Detects the OS, downloads the OS/version-specific file and sources it

- Stage 2: `distros/$OS.$VER.sh`
A distro file for each supported distro.
Cleans the environment, installs any prereqs, Docker and docker-compose

- Stage 3: Resources
Sample resource files that you can use.
