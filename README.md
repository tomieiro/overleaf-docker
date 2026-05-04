# Overleaf Docker Local

Fork local para buildar e rodar o Overleaf Community Edition em Docker.

Este fork foi ajustado para o fluxo local:

- Ubuntu 24.04 na imagem base.
- Node instalado via nvm.
- Build da imagem community com Yarn workspaces.
- `docker-compose.yml` com Overleaf, MongoDB, Redis e Postgres.
- MongoDB em replica set single-node para suportar history/project creation.
- Serviços `history-v1` e `project-history` habilitados.
- Emails confirmados automaticamente no ambiente local.
- Saida de compilacao LaTeX servida corretamente pelo nginx interno.

## Build

```sh
make build-base
make build-community
```

## Subir Localmente

```sh
SHARELATEX_PORT=8080 docker compose up -d
```

Acesse:

```text
http://localhost:8080
```

## Login Local

Crie ou resete usuarios usando os scripts/admin tools do proprio container
Overleaf em execucao.

## Servicos Internos

O container principal roda os servicos via runit. Os principais para este fork:

- `web-sharelatex`
- `clsi-sharelatex`
- `project-history-sharelatex`
- `history-v1-sharelatex`
- `document-updater-sharelatex`
- `real-time-sharelatex`
- `filestore-sharelatex`
- `docstore-sharelatex`
- `email-autoconfirm-sharelatex`
- `nginx`

Checagem rapida:

```sh
docker compose exec sharelatex sv status /etc/service/*
```

## Compilacao LaTeX

O CLSI escuta internamente em `127.0.0.1:3013`.

O web usa esse servico para compilar e o nginx interno serve os arquivos de
saida em rotas como:

```text
/project/<project-id>/build/<build-id>/output/output.pdf
/project/<project-id>/user/<user-id>/build/<build-id>/output/output.pdf
```

Isso evita o erro de renderizacao causado por tentativa de buscar o PDF em uma
porta interna incorreta.
