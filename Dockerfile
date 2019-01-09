FROM debian:stretch

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=America/New_York

RUN echo "alias dir='ls -alh --color'" >> /etc/bash.bashrc && \
    echo "deb http://dl.winehq.org/wine-builds/debian/ stretch main" > /etc/apt/sources.list.d/winehq.list && \
    dpkg --add-architecture i386

RUN apt-get -o Acquire::AllowInsecureRepositories=true \
   -o Acquire::AllowDowngradeToInsecureRepositories=true \
   -o Acquire::https::Verify-Peer=false \
   -o Acquire::https::Verify-Host=false \
   update --allow-unauthenticated

RUN apt-get -o Acquire::AllowInsecureRepositories=true \
   -o Acquire::AllowDowngradeToInsecureRepositories=true \
   -o Acquire::https::Verify-Peer=false \
   -o Acquire::https::Verify-Host=false \
   install -y --allow-unauthenticated --install-recommends \
   winehq-devel wget unzip vim cabextract xvfb fvwm x11vnc

RUN wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
    -O /usr/local/bin/winetricks && \
    chmod a+x /usr/local/bin/winetricks && \
    mkdir -p /app/wine

ENV WINEDEBUG=-all \
    WINEARCH=win64 \
    WINEPREFIX=/app/wine \
    PATH=/opt/wine-devel/bin/:${PATH}

RUN winecfg && \
    wineboot -i && \
    winetricks -q win10 dotnet472 && \
    wineboot -s

# RUN wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip \
#     -O /tmp/steamcmd.zip && \
#     wine cmd /c mkdir C:\\steamcmd && \
#     unzip -d /app/wine/drive_c/steamcmd /tmp/steamcmd.zip

RUN wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
    -O tmp/steamcmd_linux.tar.gz && \
    mkdir -p /app/steamcmd && \
    tar -zxvf /tmp/steamcmd_linux.tar.gz -C /app/steamcmd

ENV STEAM_APP_ID=598850 \
    GAME_DIR=/app/hellion

RUN /app/steamcmd/steamcmd.sh +login anonymous +@sSteamCmdForcePlatformType windows +force_install_dir ${GAME_DIR} +app_update ${STEAM_APP_ID} validate +quit

COPY GameServer.ini ${GAME_DIR}

WORKDIR ${GAME_DIR}

# wine start HELLION_Dedicated.exe -scan

