# TFR Dashboard
Dashboard poskytující vizualizaci [Total fertility rate](https://cs.wikipedia.org/wiki/Plodnost#%C3%9Ahrnn%C3%A1_plodnost) a dalších souvisejících datasetů.

Software se skládá ze čtyř hlavních Docker kontejnerů:
- postgres: databáze pro uložení datasetů a výpočtů,
- data: modul pro stažení a zpracování datasetů,
- api: zpřístupnění databáze webové aplikaci,
- web: sestavení webové aplikace a webový server.

## Konfigurace
Po naklonování repozitáře je třeba nastavit environment variables, které budou použité v jednotlivých Docker kontejnerech.
V hlavním adresáři repozitáře zkopírujeme přítomný soubor `.env.example` do `.env`. Při nasazení mimo testovací prostředí je vhodné v `.env` změnit především hodnoty `secret#`.

Dále je možné upravit porty, na kterých bude dostupná API a webový server.
V takovém případě upravíme příslušné hodnoty v `docker-compose.yml`.
Jedná se o tyto sekce:
- `services: api: ports`
- `services: api: environment: PGRST_OPENAPI_SERVER_PROXY_URI`
- `services: web: build: args: API_URL`
- `services: web: ports`

Pokud používáme Swagger UI kontejner pro procházení API, pak také 
- `services: swagger: environment: API_URL`

## Spuštění
Pro spuštění je třeba mít nainstalovaný [Docker](https://docs.docker.com/get-docker/).

1. Spustíme databázi na pozadí
```
docker-compose up -d postgres
```
2. Spustíme sběr a zpracování dat z online zdrojů na popředí a vyčkáme, dokud se data nezpracují. Toto může trvat několik minut. Pokud sběr selže při získávání dat z Google Trends, postupujeme podle řešení v sekci níže a spustíme poté sběr znovu.
```
docker-compose up data
```
3. Poté, co byla data stažena a zpracována, můžeme spustit API a webový server, který bude poskytovat klientům aplikaci.
```
docker-compose up -d api web
```

S výchozí konfigurací `docker-compose.yml` je nyní dashboard dostupný na [http://127.0.0.1:5053](http://127.0.0.1:5053).

## Limit Google Trends API
Google Trends API může zablokovat opakované požadavky, které software provádí. V takovém případě je možné dočasně deaktivovat sběr dat z Google Trends přidáním následující environment variable do `docker-compose.yml`:
```
...
services:
  ...
  data:
    ...
    environment:
      ...
      EXCLUDE_GOOGLETRENDS: 1
...

```
Obdobným způsobem lze deaktivovat i ostatní datové zdroje (proměnné `EXCLUDE_EUROSTAT`, `EXCLUDE_DATAGOVCZ`).
Vynecháním všech těchto zdrojů ale přijdeme o část datové analýzy (hlavní datový zdroj World Bank je třeba nechat aktivní vždy).
