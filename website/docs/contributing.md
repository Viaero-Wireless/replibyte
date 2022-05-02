---
sidebar_position: 10
---

# Contributing

:::tip

If you are non-experienced in Rust, consider picking issues with label [good first issue](https://github.com/Qovery/replibyte/issues?q=is%3Aopen+is%3Aissue+label%3A%22good+first+issue%22).

:::

## Local development

For local development, you will need to install [Docker](https://www.docker.com) and run `docker compose -f ./docker-compose-dev.yml` to
start the local databases. At the moment, `docker-compose` includes 2 PostgreSQL database instances, 2 MySQL instances, 2 MongoDB instances
and a [MinIO](https://min.io) bridge. One source, one destination by database and one bridge. In the future, we will provide more options.

The Minio console is accessible at http://localhost:9001.

Once your Docker instances are running, you can run the RepliByte tests, to check if everything is configured correctly:

```shell
AWS_ACCESS_KEY_ID=minioadmin AWS_SECRET_ACCESS_KEY=minioadmin cargo test
```

## How to contribute

RepliByte is in its early stage of development and need some time to be usable in production. We need some help, and you are welcome to
contribute. To better synchronize consider joining our #replibyte channel on our [Discord](https://discord.qovery.com). Otherwise, you can
pick any open issues and contribute.

## Where should I start?

Check the [open issues](https://github.com/Qovery/replibyte/issues). 
