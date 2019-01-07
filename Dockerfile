from jaimef/gerbil

MAINTAINER jaimef@linbsd.org
COPY . /root/outlook
ENV PATH "$PATH:/root/gerbil/bin"
ENV GERBIL_HOME "/root/gerbil"
RUN cd /root/outlook && ./build.ss static
RUN cp /root/outlook/outlook /bin/outlook

CMD /bin/bash
