# CEoR : Command Executer on Remote 

## Overview 

CEoR is a tool written by POSIX shell script which runs procedures on remote node using ssh/scp.

## Motivation 

Chef/Ansible/Fablic are widely known as tools for automatically setting on remote nodes.

These tools explicitly or implicitly assume that the target is Linux. In many case, tools are not assume it, but usable libraries or module or recipes are assumeing Linux.
And these tools require use of tools such as ruby, python or others that can not be assumed to exist in the system at the time of system distribution.

I'm administrating FreeBSD/NetBSD, CentOS/Ubuntu or other OSs, and sometimes I cannot install ruby, python or other tools to the target nodes.
Under these circumstances, these restrictive conditions are very strict.

So I imprement CEoR. CEoR runs on POSIX shell and other POSIX commands.

## Philosophy 

CEoR producted for the purpose of operating with minimum toolsets. Then CEoR uses only POSIX UNIX toolset.
Actually, due to implementation circumstances, I use some tools not included in POSIX like ssh or sudo and so on.

* A list of posix commands: [[http://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html]]

  On many UNIX systems, it is possible to use su instead of sudo.
  But CEoR uses sudo because using su has some probrems like sharing password.

Followings are a list of non POSIX commands which using CEoR.
* ssh / sudo : Must
* pkg / yum / apt : Need to use FreeBSD/CentOS/Ubuntu
* openssl : Need to culculate Hash value
* wget / curl : should be

## Precondition 

Below, list the software required to execute CEoR.

### MUST 

* local node
  * ssh 5.6 or above (2010/08 released.)
  * POSIX Shells and commands
* Target node
  * sshd 5.6 or above (2010/08 released.)
  * POSIX Shells and commands
  * Some of the administration commands
    * It is desirable not to use interactive processing whenever possible.

### SHOULD 

* login with no password on remote. (Recomend to use ssh RSA authentication.)
* Elevated privilege to root with no password on remote.
  * Generally use sudo.

### Structure of CEoR 

* Default value (configured in ceor.conf or ceor.conf.local)
  * $CEoRETC: /usr/local/etc
  * $CEoRINC: /usr/local/libexec/CEoR
  * $CEoRINC_LOCAL: ./.CEoR
    
```
/ -+- /usr/local/CEoR -+- bin ---- ceor.sh   : Execute files.
   |                   +- etc ---- ceor.conf : Base configuration files.
   |                   +- MODs -+
   |                   |        +- ....      : Module which distribute CEoR proj.
   |                   |
   |                   +- RCPs -+
   |                            +- ....      : Recipe which distribute CEoR proj.
   +- ~/.CEoR -+- ceor.conf                  : Personal configuration files.
   |           +- MODs -+
   |           |        +- ....              : Personal module.
   |           |
   |           +- RCPs -+
   |                    +- ....              : Personal recipes.
   |
   +- Proj -+                                : [Project]
            +- .CEoR -+
                      +- ceor.conf.local     : Project configurations.
                      +- MODs -+
                      |        +- ....       : Project modules.
                      |        |
                      +- RCPs -+
                               +- ....       : Project recipes.
```

## Some Rules 

### Configuration file 

* See /usr/local/CEoR/etc/ceor.conf or some/where/CEoR/*.conf.sample

### Module file 

* Module is to make "some function" execute "without depending on Platform".
  * Module is an abstraction of the work you want to implement.
  * For example, when implementing the function "adduser" for adding "User" as Module, consider the following
    * on CentOS: use "useradd"
    * on Ubuntu: use "useradd"
    * on FreeBSD: use "adduser"
    * Need to set some options such like UID, GID, Groups, and so on.
    * It is necessary to pass option as an argument.
    * OS check uses checkos.
    * Check "exit status", and return status. 0 is Succeeded, 1 is failed.
* Module creates one file for each module, even if the contents are only one line.
* Always make sure that the function name and module file name match.
  * Ensure that existing module names are easy to understand.
* If there is the same module name, CEoR reads in the following order
  * Proj/.CEoR -> CEoRLOCINC -> CEoRGENINC
* Function name should be created according to `[a-z0-9_]+`
  * Do not use upper case alphabet.
  * Now I'm considering function name by Cammel-Case.
* If a module using not POSIX commands, comment it in the comment part of module.

### Recipe 

* Recipe is a description of work procedure.
* Recipe consists of the following three blocks/functions.
  * prepare : Preparation. Executed on the local node.
    * If necessary, you can prepare files and forward them to the destination.
  * main : Main work. Executed on the remote/target node.
    * Environment variable setting is not inherited because main runs on remote node.
    * Currently, Only environment variables `_TGT_SCRDIR` and` __TGT` are inherited.
  * afterwords: Post process. Executed on the local node.
    * If necessary, you can get the file from the destination.
* Recipe is written in shell script manner.
  * See RCPs/concept.rcp

```
prepare(){ # runs on local
# WARNING: CEoR stop when prepare's exit status is non 0.
}
main(){ # runs on remote
  ls -l /	# write procedure in shell script manner.
# WARNING: CEoR stop when main's exit status is non 0.
}
afterwords(){ # runs on local
# WARNING: Regardless of afterwords's exit status, CEoR ends after final processing
}
```

