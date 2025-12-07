# Dockerfile
FROM ubuntu:20.04

# Instalace procps (kvůli příkazu ps pro procesy)
RUN apt-get update && apt-get install -y procps

# Skopírování tvého skriptu do kontejneru
COPY linux_cli.sh /app/linux_cli.sh

# Nastavení práv ke spuštění
RUN chmod +x /app/linux_cli.sh

# Nastavení pracovního adresáře
WORKDIR /app

# Výchozí příkaz, který se spustí (test procesů)
CMD ["./linux_cli.sh", "-p"]
