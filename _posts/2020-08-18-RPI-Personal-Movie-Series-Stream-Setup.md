---
title: Personal Movies/Series Stream Server on RPi
published: true
---

I'm a big fan of watching series (who isn't?) but it can be hard to watch the shows I want, sometimes the show I want to watch is not available on the Streaming services I'm subscribed or not even available on the streaming services of my country. So I assembled a personal streaming server on a Raspberry Pi 3b+ I had laying around and a USB external Hard Drive.

## Preparing the ground

If you are comfortable with the basic Raspberry Pi OS setup you can skip this part.

You'll need a storage device with some considerable size to store the media, like a external USB Hard Drive, you might go ahead and install the Operational System on this drive too and save yourself a SD card.
To enable the USB boot on the Raspberry Pi check [this](https://www.raspberrypi.org/documentation/hardware/raspberrypi/bootmodes/msd.md) out.

It's not in the scope of this article to teach the basic setup of the Raspberry Pi OS. I suggest you install the headless version and interact with it over ssh. [This guide](https://www.tomshardware.com/reviews/raspberry-pi-headless-setup-how-to,6028.html) can help you.

### Setting a static IP

It's a good idea to make the IP address static, since you'll need to use it to configure the client devices.  
To do so change the IP addresses, according to your home network, on the code below and copy it to /etc/dhcpcd.conf file.

```shell
  pi@raspberrypi:~ $ sudo nano /etc/dhcpcd.conf

  interface eth0
  static ip_address=192.168.0.106/24
  static routers=192.168.0.1
  static domain_name_servers=192.168.0.1 8.8.8.8
```

## Media Server

The personal media server is composed by multiple pieces of software, there's a brief explanation of each one below:

- [Emby](https://emby.media/) is the software responsible for the streaming of media, it can stream over DLNA, to Chromecast, to smart TVs client applications and to its webserver. 
- [Sonarr](https://sonarr.tv/). According to its webpage Sonarr is a [PVR](https://www.webopedia.com/TERM/P/PVR.html) for BitTorrent users. In other words, you select your favorite series and shows and it automatically downloads and keeps them up to date.
- [Radarr](https://radarr.video/) is a fork from Sonarr for movies.
- [Jackett](https://github.com/Jackett/Jackett) is a proxy server that translate the queries from Sonarr and Radarr to tracker sites.
- [Transmission](https://transmissionbt.com/) is a torrent client.


Installing and configuring correctly all this programs would be a laborious task, so in order to make our lives easier 
To make the installation even easier I created a [github project](https://gitlab.com/finkelrf/media_server) with the docker-compose file that puts all the containers needed up.

## Instructions

To be able to run the docker containers you will need to install **docker** and **docker-compose**

Installing **docker**

``` shell
#ssh into rpi
niceusername@myhostpc:~ $ ssh pi@my_pi_ip_address
pi@raspberrypi:~ $ curl -sSL https://get.docker.com | sh
```

Add permission to user pi to run docker commands

``` shell
pi@raspberrypi:~ $ sudo usermod -aG docker pi
```

Logout for changes to be applied

``` shell
pi@raspberrypi:~ $ exit
niceusername@myhostpc:~ $ ssh pi@my_pi_ip_address
```

Install dependencies

``` shell
pi@raspberrypi:~ $ sudo apt install -y libffi-dev libssl-dev python3 python3-pip git
```

Install **docker-compose**

``` shell
pi@raspberrypi:~ $ sudo pip3 install docker-compose
```

Clone repository

``` shell
pi@raspberrypi:~ $ git clone https://gitlab.com/finkelrf/media_server.git
```

Put services up

``` shell
pi@raspberrypi:~ $ cd media_server
pi@raspberrypi:~/media_server $ docker-compose up -d
```

## Configuring Jackett

Once all containers are up it is possible to access the jackett webpage by accessing the RPi IP and port 9117, in my case it's http://192.168.0.106:9117.
At the page you need to add some free indexers at the `+ Add Indexer` button and copy the API key at the top of the page.

## Configuring Sonarr and Radarr

The instruction for both Sonarr and Radarr are pretty much the same, given that Radarr is a fork of Sonarr. To access Sonarr go to RPi IP address port 8989 and for Radarr is port 7878, in my case http://192.168.0.106:8989 and http://192.168.0.106:7878.
You will need to configure indexers and a download client.

To configure the indexers enter the Sonarr/Radarr webpage and go to **Settings > Indexers > Add > Torznab > Custom** and fill the as below.

- **Name** Jackett
- **URL**  http://jackett:9117/api/v2.0/indexers/all/results/torznab/
- **API Key** <Copy/paste from Jackett page>

To configure transmission as the download client go to **Settings > Download Client > Add > Transmission** and fill the same information as below.

- **Name** Transmission
- **Host** transmission
- **Port** 9091

With the basic configurations done it is possible to add your favorite series.
On the top menu go to **Series > + Add Series** and search for your favorite show. Before add it configure the **Path** to /volumes/media for Sonarr and /movies for Radarr, storing the shows there will make easier to configure Emby.

That is it, it's all done for starting downloading media, now we have to configure the Emby server in order to watch it.

## Configuring Emby

The port for Emby is 8096, to access it go to http://your.pi.ip.address:8096.
The first time you access the webpage your will go through a wizard to help you in the setup process.
Fill the fields according to your preference until you reach the **Setup Media Libraries**, in this step you are going to setup a Movie and a TV Shows libraries.
For the Movies library select:

- **Content type:** Movies
- **Folders** /mnt/share1/movies

For the TV Shows library select:

- **Content type:** TV Shows
- **Folders** /mnt/share1/series

Once the wizard is finished you can start watching your media in all your devices by downloading a [client](https://emby.media/download.html) or by accessing the web media player at the same address you made the configuration. In my house we have two TVs, the living room TV is an older smart Philips TV, that unfortunately has no Emby app on its store, for that reason I use a 2nd gen Chromecast and cast media from the Emby Android app, in the bedroom I have a small but newer LG smart tv that has the Emby app on its app store.

It's all set up! Now go ahead and watch all seasons of [The Office](https://www.imdb.com/title/tt0386676/) and laugh even harder of the memes you see around the web.

<div style="text-align:center"><img src="https://raw.githubusercontent.com/Finkelrf/finkelrf.github.io/gh-pages/_images/young_michael_blog_meme.png" /></div>
