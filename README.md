# docker-amule-dlp
[aMule](https://github.com/amule-project/amule) is an eMule-like client for the eDonkey and Kademlia networks. This project maintains docker containers for the aMule fork [amule-dlp](https://github.com/persmule/amule-dlp), which adds the dynamic leech protection (DLP) feature to aMule. Only aMule daemon and web server are enabled and GUI is disabled in the container. To control aMule, use aMule GUI for remote connection or use your web browswer to visit the web server.

Inspired by the work of [tetreum](https://github.com/tetreum/amule-docker) and [tchabaud](https://github.com/tchabaud/dockerfiles/tree/master/amule).

## Usage

### Docker-compose
The recommended way is to use docker-compose. Create a file `docker-compose.yml` and add the following lines to the file:

    version: '2.1'
    services:
      amule:
        container_name: amule
        image: minnyres/amule-dlp
        restart: unless-stopped
        network_mode: host
        environment:
          - UID=1000
          - GID=1000
          - WEBUI=bootstrap
          - ECPASSWD=amule-passwd
          - TIMEZONE=Asia/Shanghai
        volumes:
          - <config>:/config
          - <downloads>:/downloads
          - <temp>:/temp

Then, start the container with the command 

    docker-compose up -d

### Volume mapping

In the `volumes` section, some parameters need to be replaced by the paths on the host system:
 + `<config>` - the folder for configuration files
 + `<downloads>` - the folder to save downloaded and shared files
 + `<temp>` - the folder for incomplete download files

### Environment variables

| Variable      | Meaning | Notes     |
| :----:        |    :---     |         :---   |
| UID      |    User id    |  Given by `echo $UID`  |
| GID   | Usergroup id        | Given by `echo $GID`     |
| WEBUI   | Web UI theme   | Can be default, [bootstrap](https://github.com/pedro77/amuleweb-bootstrap-template) or [reloaded](https://github.com/MatteoRagni/AmuleWebUI-Reloaded)     |
| ECPASSWD   |   Password for external connection     |  You can connect to aMule daemon using aMule GUI with this password, bur keep in mind that it is not the password of web server. Once the container starts, the password will be persistently saved, and thus the line `- ECPASSWD=xxx` can be removed hereafter for security. |
| TIMEZONE   | Time zone       |    |

### Bridge network

The above docker-compose configuration uses host network, which is necessary if UPnP is enabled. To use bridge network, edit `docker-compose.yml`:

    version: '2.1'
    services:
      amule:
        container_name: amule
        image: minnyres/amule-dlp
        restart: unless-stopped
        network_mode: bridge
        ports:
          - "4711:4711"
          - "4712:4712"
          - "24662:24662"
          - "24665:24665/udp"
          - "24672:24672/udp"
        environment:
          - UID=1000
          - GID=1000
          - WEBUI=bootstrap
          - ECPASSWD=amule-passwd
          - TIMEZONE=Asia/Shanghai
        volumes:
          - <config>:/config
          - <downloads>:/downloads
          - <temp>:/temp

Under bridge network, one needs to enable port mapping for the following ports:
 + `4711` - port for aMule web server
 + `4712` - port for remote connection with aMule GUI
 + `24662` - standard client TCP port
 + `24672` - extended client UDP port
 + `24665` - extended server request UDP port
 
The extended server request UDP port must be standard client TCP port + 3, while the other ports can be changed in aMule setting.
 
### Use official aMule
There is also an image for official aMule. To run the latest official release v2.3.3 without DLP, just change the option
 
     image: minnyres/amule-dlp:official-2.3.3
 
## aMule setting

The settings of aMule is stored in the file `<temp>/amule.conf`. If the file already exists, aMule will use the existing configuration file. Otherwise, aMule will create a new configuration file according to the default settings. Some of the default settings are listed below:

 + port for aMule web server: `4711`
 + port for remote connection with aMule GUI: `4712`
 + standard client TCP port: `24662`
 + extended client UDP port: `24672`
 + extended server request UDP port: `24665`
 + password for external connection: `amule-passwd`
 + web server password: `amuleweb-passwd`
 + web UI theme: `bootstrap`
 + UPnP: `enabled` 

To view and change the settings, one can connect to aMule with aMule GUI. Advanced users can directly edit the file `<temp>/amule.conf` when aMule is not running. Note that the web UI theme and password for external connection can not be changed with aMule GUI, and will be overwritten by the variables in `docker-compose.yml`.
