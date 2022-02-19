FROM kalilinux/kali-rolling

# Locale config
COPY etc /etc
RUN apt clean && apt update && apt upgrade -y 
RUN apt install -y localehelper
RUN echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen && locale-gen
