FROM rust:1.82-bookworm as build

# create a new empty shell project
RUN USER=root cargo new --bin replibyte
WORKDIR /replibyte
RUN USER=root cargo new --lib replibyte
RUN USER=root cargo new --lib dump-parser
RUN USER=root cargo new --lib subset

# copy over your manifests
# root
COPY ./Cargo.lock ./Cargo.lock
COPY ./Cargo.toml ./Cargo.toml

# dump-parser
COPY ./dump-parser ./dump-parser

# subset
COPY ./subset ./subset

# replibyte
COPY ./replibyte/Cargo.toml ./replibyte/Cargo.toml
COPY ./replibyte/Cargo.lock ./replibyte/Cargo.lock

# this build step will cache your dependencies
RUN cargo build --release
RUN rm src/*.rs

# copy your source tree
COPY ./replibyte/src ./replibyte/src
COPY ./dump-parser/src ./dump-parser/src
COPY ./subset/src ./subset/src

# build for release
RUN rm ./target/release/deps/replibyte*
RUN cargo build --release

# our final base
FROM debian:bookworm-slim

# used to configure Github Packages
LABEL org.opencontainers.image.source https://github.com/qovery/replibyte

# Install wget, curl, ca-certificates, and aptitude 
RUN apt-get clean && apt-get update && apt-get install -y wget curl ca-certificates aptitude

# Install the postgres 16

RUN install -d /usr/share/postgresql-common/pgdg
RUN curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc

# Create the repository configuration file:
# RUN sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
# deb http://apt.postgresql.org/pub/repos/apt/ squeeze-pgdg main
# Update the package lists:
RUN apt update 

RUN apt install aptitude -y

# RUN apt install libpq5 libreadline8 libzstd1 -y
RUN apt install -y postgresql-common
# RUN apt install postgresql-client-16 -y
RUN aptitude install postgresql-client-16 -f -y

# Install MongoDB tools
RUN wget https://fastdl.mongodb.org/tools/db/mongodb-database-tools-debian92-x86_64-100.5.2.deb && \
    apt install ./mongodb-database-tools-*.deb && \
    rm -f mongodb-database-tools-*.deb && \
    rm -rf /var/lib/apt/lists/*

# copy the build artifact from the build stage
COPY --from=build /replibyte/target/release/replibyte .

COPY ./docker/* /
RUN chmod +x exec.sh && chmod +x replibyte

ENTRYPOINT ["sh", "exec.sh"]
