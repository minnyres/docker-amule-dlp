# docker-amule-dlp
[aMule](https://github.com/amule-project/amule) is an eMule-like client for the eDonkey and Kademlia networks. This project maintains docker containers for the aMule fork [amule-dlp](https://github.com/persmule/amule-dlp), which adds the dynamic leech protection (DLP) features to aMule. Only aMule daemon and web server are enabled and GUI is disabled in the container. To control aMule, use aMule GUI for remote connection or use your web browswer to visit the web server.

Inspired by the work of [tetreum](https://github.com/tetreum/amule-docker) and [tchabaud](https://github.com/tchabaud/dockerfiles/tree/master/amule).

## Usage

### docker-compose
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

### volume mapping

In the `volumes` section, some parameters need to be replaced by the paths on the host system:
 + `<config>` - the folder for configuration files
 + `<downloads>` - the folder to save downloaded files
 + `<temp>` - the folder to partially downloaded files

### environment variables

The variables in the `environment` section can be modified following the guide:

| Variable      | Meaning | Notes     |
| :----:        |    :---     |         :---   |
| UID      |    User id    |  Given by `echo $UID`  |
| GID   | Usergroup id        | Given by `echo $GID`     |
| WEBUI   | Web UI theme   | Can be default, [bootstrap](https://github.com/pedro77/amuleweb-bootstrap-template) or [reloaded](https://github.com/MatteoRagni/AmuleWebUI-Reloaded)     |
| ECPASSWD   |   Password for remote connection with aMule GUI but not the password for web server     |  Default value is `amule-passwd`. Once you run the container, the password will be persistently saved, and thus the line `- ECPASSWD=xxx` can be removed hereafter for security. |
| TIMEZONE   | Time zone       |    |

### bridge network

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
 
 ### run official aMule but not the DLP fork
 
 There is also a support for the official aMule. To run the latest official release v2.3.3 without DLP, just change the option
 
     image: minnyres/amule-dlp:official-2.3.3
