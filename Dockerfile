# Dockerfile
FROM ubuntu:20.04

# Instalace procps
RUN apt-get update && apt-get install -y procps

# Kopírování skriptu do kontejneru
COPY linux_cli.sh /app/linux_cli.sh

# Práva ke spuštění
RUN chmod +x /app/linux_cli.sh

# Nastavení adresáře
WORKDIR /app

# ----------------------------------------------------
# ---------------- ENTRYPOINT A CMD ------------------
# ----------------------------------------------------

ENTRYPOINT ["/app/linux_cli.sh"]

CMD ["-h"]
