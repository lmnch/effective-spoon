# effective-spoon
A bash file-bysed very simple key-command mapping

## Installation

Place the file `es.sh` basically anywhere and add it to your `PATH` variable somehow.


## Configuration

Create a file with the key/keysequence you want to bind followed by an '=' and then the command:

```
cl=rm -r ./target
du=docker compose up -d
dr=docker compose restart app
hw=echo Hello world
```
(config.env)


## Usage

Run the script with the config file as argument:

```
es.sh config.env
```

You'll see sth like this:
![Terminal with list of key-command combinations on the left](https://github.com/lmnch/effective-spoon/assets/36163180/6f186d8f-cbbc-45c8-8216-e275e1460bb8)

Explanation:
![Same terminal like before but less commands, a command history on the right, and a 'd' in the middle](https://github.com/lmnch/effective-spoon/assets/36163180/6352034f-709c-44ac-ad22-b5e353deed08)

You can clear the current key sequence by pressing '#'.
