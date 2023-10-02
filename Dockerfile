FROM ubuntu:focal AS build


ENV PYTHONUNBUFFERED=1

ENV DEBIAN_FRONTEND="noninteractive" TZ="Etc/UTC"
RUN apt update -y && \
    apt install -y python \
    build-essential \
    git \
    cmake \
    openssl \
    perl \
    libboost-all-dev


# RUN apk update && \
#     apk add --no-cache \
#         build-base=0.5-r3 \
#         cmake=3.24.4-r0 \
#         busybox=1.35.0-r29 \
#         autoconf  bsd-compat-headers \
#             # libstdc++=12.2.1_git20220924-r4 \
# 	git \
#     perl \
#     openssl \
# 	boost1.80-dev=1.80.0-r3 
#	boost-1.80=1.80.0-r3
#    musl-dev \

#        boost1.80=1.80.0-r3 
#RUN apk add --upgrade boost1.80 \
#	boost1.80-dev=1.80.0-r3

WORKDIR /bitbomb

COPY src/ ./src/
COPY Makefile ./Makefile
COPY CMakeLists.txt ./CMakeLists.txt
COPY version/ ./version/
COPY include/ ./include/
COPY external/ ./external/
COPY CMakeFiles/ ./CMakeFiles
COPY tests/ ./tests/
COPY CTestCustom.cmake ./CTestCustom.cmake


# WORKDIR /
# RUN git clone --single-branch --branch OpenSSL_1_1_1b --depth 1 https://github.com/openssl/openssl.git
# WORKDIR /openssl
# RUN ./Configure linux-x86_64 no-shared
# RUN make -j8

# WORKDIR /
# RUN git clone https://github.com/bcndev/lmdb.git
WORKDIR /bitbomb

# ENV Boost_LIBRARY_DIRS=/usr/local/lib
# ENV DBOOST_ROOT=/usr/local/src/boost_1_80_0
# ENV BOOST_INCLUDEDIR=/usr/local/src/boost_1_80_0
# ENV Boost_INCLUDE_DIR=/usr/local/src/boost_1_80_0

RUN  make -j8

    # /usr/bin/cmake --build ./build/. --parallel 8
#RUN make


FROM ubuntu:focal
ENV DEBIAN_FRONTEND="noninteractive" TZ="Etc/UTC"
ARG USERNAME=bitbombuser
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

RUN apt update && \
    apt install -y \
    build-essential \
    libboost-all-dev


# RUN useradd -ms /bin/bash bitbombuser

# COPY --chown=$USERNAME:$USERNAME --from=build \
#     ./bitbomb/build/release/src/ \
#     ./app
COPY --from=build \
     ./bitbomb/build/release/src/ \
     ./app

# RUN chown -R $USERNAME:$USERNAME /app



# USER $USERNAME
WORKDIR ./app
# RUN mkdir -p ~/bitbombd
COPY --from=build ./bitbomb/build/release/src/bitbombd /usr/local/bin
COPY --from=build ./bitbomb/build/release/src/simplewallet /usr/local/bin
COPY docker-entrypoint.sh ./docker-entrypoint.sh

RUN chmod +x ./docker-entrypoint.sh

# WORKDIR ./app

EXPOSE 23823 23823/udp


ENTRYPOINT ["./docker-entrypoint.sh"]
# ENTRYPOINT [ "./bitbombd", "--log-level=4"]
# /app/bitbombd --data-dir=/app/data --log-level=4

# ENTRYPOINT [ "bitbombd","--log-level=4" ]

