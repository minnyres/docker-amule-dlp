# docker-amule-dlp
[aMule](https://github.com/amule-project/amule) is an eMule-like client for the eDonkey and Kademlia networks. This project maintains docker containers for the aMule fork [amule-dlp](https://github.com/persmule/amule-dlp), which supports dynamic leech protection (DLP). Only aMule daemon and web server are enabled and GUI is disabled in the container. To control aMule, use aMule GUI for remote connection or use your web browswer to visit the web server.

Inspired by the work of [tetreum](https://github.com/tetreum/amule-docker), [tchabaud](https://github.com/tchabaud/dockerfiles/tree/master/amule) and [ngosang](https://github.com/ngosang/docker-amule).

Supported architectures: 
* linux/amd64
* linux/loong64
* linux/arm/v6
* linux/arm/v7
* linux/arm64
* linux/ppc64le
* linux/s390x
* linux/riscv64
* linux/mips64le

## Usage

### Docker-compose
The recommended way is to use docker-compose. Create and edit the file `docker-compose.yml` as the template

    version: '2.1'
    services:
      amule:
        container_name: amule
        image: minnyres/amule-dlp:latest
        restart: unless-stopped
        network_mode: host
        environment:
          - UID=1000
          - GID=1000
          - WEBUI=bootstrap
          - ECPASSWD=amule-passwd
          - TIMEZONE=Asia/Shanghai
          - RECURSIVE_SHARE=yes
        volumes:
          - <config>:/config
          - <downloads>:/downloads
          - <temp>:/temp

Then, start the container with the command 

    docker-compose up -d

The default port to connect with aMule GUI is 4712, and the default port for aMule web control is 4711.

### Volume mapping

In the `volumes` section, some parameters need to be replaced by the paths on the host system:
 + `<config>` - the directory for configuration files
 + `<downloads>` - the directory for downloaded and shared files
 + `<temp>` - the directory for incomplete download files

### Environment variables

Please carefully read the notes on the variables:

| Variable      | Meaning | Notes     |
| :----:        |    :---     |         :---   |
| UID      |    User id    |  Given by `echo $UID` on the host system  |
| GID   | Usergroup id        | Given by `echo $GID` on the host system     |
| WEBUI   | Web UI theme   | Can be default, [bootstrap](https://github.com/pedro77/amuleweb-bootstrap-template) or [reloaded](https://github.com/MatteoRagni/AmuleWebUI-Reloaded)     |
| ECPASSWD   |   Password for external connection     |  This is the password for aMule GUI but not web server. Set `ECPASSWD` is only necessary when you run aMule for the first time, or want to change the password. |
| TIMEZONE   | Time zone       |    |
| RECURSIVE_SHARE   |   Whether to recursively share the files in the sub-folders of the path `<downloads>`     |   Can be `yes` or `no`  |

### Bridge network

To use bridge network, one needs to manually define port mapping. Note that UPnP is not supprted under bridge network. 

    version: '2.1'
    services:
      amule:
        container_name: amule
        image: minnyres/amule-dlp:latest
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
          - RECURSIVE_SHARE=yes
        volumes:
          - <config>:/config
          - <downloads>:/downloads
          - <temp>:/temp

Meanings of the ports:
 + `4711` - port for aMule web server
 + `4712` - port for remote connection with aMule GUI
 + `24662` - standard client TCP port
 + `24672` - extended client UDP port
 + `24665` - extended server request UDP port
 
The port numbers can be modified in [aMule setting](https://github.com/minnyres/docker-amule-dlp#amule-setting).
 
### Use official aMule
This project also provides an image for official aMule. To run the latest official release v2.3.3 without DLP, just change the `image` option
 
     image: minnyres/amule-dlp:official-2.3.3
 
## aMule setting

The settings of aMule are stored in the file `<config>/amule.conf`. If the file already exists, aMule will use the existing configuration file. Otherwise, aMule will create a new configuration file according to the [default settings](https://github.com/minnyres/docker-amule-dlp/blob/main/amule.conf).

To view and change the settings, one can connect to aMule with aMule GUI. Note that aMule GUI does not support to change the web UI theme and password for external connection, and it is recommended to set the two options by [docker-compose](https://github.com/minnyres/docker-amule-dlp#docker-compose).  
