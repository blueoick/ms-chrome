FROM kasmweb/core-ubuntu-focal:1.11.0
USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########


RUN touch $HOME/Desktop/hello.txt


############################################

# Install Google Chrome
COPY ./src/ubuntu/install/chrome $INST_SCRIPTS/chrome/
RUN bash $INST_SCRIPTS/chrome/install_chrome.sh  && rm -rf $INST_SCRIPTS/chrome/

# Update the desktop environment to be optimized for a single application
#RUN cp $HOME/.config/xfce4/xfconf/single-application-xfce-perchannel-xml/* $HOME/.config/xfce4/xfconf/xfce-perchannel-xml/
#RUN cp /usr/share/extra/backgrounds/bg_kasm.png /usr/share/extra/backgrounds/bg_default.png
#RUN apt-get remove -y xfce4-panel

# Setup the custom startup script that will be invoked when the container starts
ENV LAUNCH_URL  https://google.com

COPY ./src/ubuntu/install/chrome/custom_startup.sh $STARTUPDIR/custom_startup.sh
RUN chmod +x $STARTUPDIR/custom_startup.sh


ENV KASM_RESTRICTED_FILE_CHOOSER=1
COPY ./src/ubuntu/install/gtk/ $INST_SCRIPTS/gtk/
RUN bash $INST_SCRIPTS/gtk/install_restricted_file_chooser.sh

###########Chinese############################
RUN apt-get -y install language-pack-zh-hans
RUN locale-gen zh_TW.UTF-8 
ENV LANG zh_TW.UTF-8  
ENV LANGUAGE zh_TW:zh  
ENV LC_ALL zh_TW.UTF-8  

ENV DEBIAN_FRONTEND=noninteractive
RUN ln -fs /usr/share/zoneinfo/Asia/Taipei /etc/localtime
RUN apt-get install -y tzdata && dpkg-reconfigure --frontend noninteractive tzdata

#RUN apt-get install -y ibus-chewing 
RUN apt-get install -y fcitx fcitx-chewing fcitx-keyboard 
RUN apt-get install -y librime-data-terra-pinyin librime-data-bopomofo xfonts-wqy

ENV GTK_IM_MODULE="fcitx"
ENV XMODIFIERS=@im="fcitx"
ENV QT_IM_MODULE="fcitx"

 
######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000

#################
RUN mkdir /home/kasm-user/.config
RUN mkdir /home/kasm-user/.config/autostart
RUN echo "[Desktop Entry]\n" > /home/kasm-user/.config/autostart/fcitx.desktop
RUN echo "Encoding=UTF-8\n" >> /home/kasm-user/.config/autostart/fcitx.desktop
RUN echo "Version=0.9.4\n" >> /home/kasm-user/.config/autostart/fcitx.desktop
RUN echo "Type=Application\n" >> /home/kasm-user/.config/autostart/fcitx.desktop
RUN echo "Name=fcitx\n" >> /home/kasm-user/.config/autostart/fcitx.desktop
RUN echo "Comment=\n" >> /home/kasm-user/.config/autostart/fcitx.desktop
RUN echo "Exec=/usr/bin/fcitx-autostart\n" >> /home/kasm-user/.config/autostart/fcitx.desktop
RUN echo "OnlyShowIn=XFCE;\n" >> /home/kasm-user/.config/autostart/fcitx.desktop
RUN echo "RunHook=0\n" >> /home/kasm-user/.config/autostart/fcitx.desktop
RUN echo "StartupNotify=false\n" >> /home/kasm-user/.config/autostart/fcitx.desktop
RUN echo "erminal=false\n" >> /home/kasm-user/.config/autostart/fcitx.desktop
RUN echo "idden=false" >> /home/kasm-user/.config/autostart/fcitx.desktop

