FROM debian:bullseye-slim

#* Creating non-root user for compliance
ENV USER_NAME=powerpipe
ENV GROUP_NAME=$USER_NAME
ENV POWERPIPE_TELEMETRY=none

RUN groupadd -g 1001 $GROUP_NAME && \
  useradd -u 1001 --create-home --shell /bin/bash --gid $GROUP_NAME $USER_NAME

WORKDIR /home/$USER_NAME/mod

RUN apt update
RUN echo "y" | apt install wget
RUN whoami
RUN wget --no-check-certificate  https://powerpipe.io/install/powerpipe.sh

RUN chmod 777 powerpipe.sh
RUN ls -al powerpipe.sh
RUN ./powerpipe.sh

RUN chown -R ${USER_NAME}:${GROUP_NAME} /home/${USER_NAME}/mod

# Run as unprivileged user
# Do the single-user-mode installation
USER $USER_NAME
ENV USER=$USER_NAME

COPY entrypoint.sh /entrypoint.sh
COPY init.sh /init.sh
ENTRYPOINT [ "/bin/bash", "/entrypoint.sh" ]
CMD [ "/usr/local/bin/powerpipe", "server", "--listen", "local"]