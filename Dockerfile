FROM python:3.12.13-slim-trixie

LABEL org.opencontainers.image.source=https://github.com/sfmunoz/trac

RUN apt-get update \
 && apt-get install -y --no-install-recommends busybox libpq5 \
 && rm -rf /var/lib/apt/lists/*

RUN busybox --install -s /usr/bin

WORKDIR /usr/src/app

COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

COPY entrypoint.sh ./

CMD ["bash","./entrypoint.sh"]
