The purpose for this project is to be able to launch a minecraft server with backups created periodically created as you play on the server.

Minecraft world saves can disappear for a number of reasons, and as it has personally occurred where hours of progress on a save was lost outside of personal control.
Thus the idea of this project came into mind once it was discovered it was possible to backup world save using docker.

**NOTE:** This project has currently only been tested on a All The Mods 9 server, other Minecraft servers (Vanilla or for other mod packs) has not been tested.

The project has the following directory structure:
```text
project/
├── backups/
|   └── backup.sh
├── BackUps/
├── Server/
│   
├── boot.sh
├── DockerFile
├── DockerFile.backup
├── docker-compose.yml
└── server_variables.env
```


For the user the only relevant things are the Server directory and the server_variables.env:

* **Server directory:**
    This is where the server files reside. The user has to manually retrieve the server files themselves and export the contents of the directory inside the Server directory.

* **server_variables.env:**
    This folder lets the user decide the value of different values for the server. Currently the variables that are editable by the user through this file are listed below along with their default value:
    
      * RCON_PASSWORD=rconnPass
      * ALLOW_FLIGHT=true
      * DIFFICULTY=hard
      * SERVER_RAM=8G 

    The *G* in the SERVER_RAM variables stands for Gigabytes. It's also possible to use Megabytes, example: -Xms2500M (equivalent to -Xms2.5G). The default is set to 8G, and adjust more or less is needed.


To launch the server, make sure Docker is installed and use the following Docker command:
  * docker-compose up --build
