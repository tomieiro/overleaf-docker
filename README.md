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

## Clone com submodulos

```sh
git clone --recurse-submodules https://github.com/tomieiro/overleaf-docker.git
```

Se o repositorio ja estiver clonado:

```sh
git submodule update --init --recursive
```

Para atualizar para o commit mais recente do `main` do submodulo:

```sh
git submodule update --remote --init --recursive
```

## Build

```sh
make build-base
make build-community
```

O comando `docker compose up --build` sozinho nao e suficiente em uma maquina
limpa, porque ele so builda a imagem `sharelatex/sharelatex` definida no
Compose. A imagem base `sharelatex/sharelatex-base:latest`, usada no `FROM` do
Dockerfile principal, precisa existir antes.

## Primeira subida

Para um ambiente novo ou depois de alterar `Dockerfile-base`:

```sh
git submodule update --init --recursive
make build-base
SHARELATEX_PORT=8080 docker compose up --build -d
```

Isso faz:

- sincroniza o submodulo `src/overleaf`
- builda `sharelatex/sharelatex-base`
- rebuilda `sharelatex/sharelatex`
- sobe Overleaf, MongoDB, Redis e Postgres

## Rebuild do app

Se voce alterou apenas o codigo do Overleaf em `src/overleaf` ou o `Dockerfile`
principal, e a base ja existe localmente:

```sh
SHARELATEX_PORT=8080 docker compose up --build -d
```

## Confirmacao automatica de email

Este fork suporta confirmacao automatica de email para ambiente local.

- `AUTO_EMAIL_CONFIRMATION=1`: habilita auto-confirmacao.
- `AUTO_EMAIL_CONFIRMATION=0`: desabilita auto-confirmacao.
- `AUTO_CONFIRM_EMAIL_INTERVAL_MS`: intervalo do job (padrao `5000` ms).

No `docker-compose.yml` atual, `AUTO_EMAIL_CONFIRMATION` ja vem habilitado por
padrao.

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
