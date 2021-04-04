FROM kalilinux/kali-rolling

# Locale config
RUN apt update && apt upgrade -y 
RUN apt install -y localehelper
RUN echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen && locale-gen
