# BankAccounting

Essa aplicação simula algumas operações bancárias.

É assumido que todas as operações são feitas por um operador de caixa
(funcionário do banco) e que possui acesso ao token de authenticação (um único
token, definido em variável de ambiente).

A applicação só aceita requests `POST`s e apenas com o `content-type`
appropridado (`JSON`).

## Setup

Esse repositório contém tudo que é necessário para executar essa aplicação
utilizando o `docker` e o `docker-compose` nas seguintes versões:

- docker `20.10.17`
- docker-compose `2.10.2`

É provável que qualquer versão que suporte o compose file `3.8` funcionará sem
problemas, porém só foi testado com as versões acima.

No diretório `config/docker` está disponível um par de `Dockerfile`s utilizado
para gerar a imagem utilizada no `docker-compose.yml`. A imagem no diretório
`builder` contém as dependências necessárias no SO e a iamgem no diretório
`development` ajusta essa imagem para a execução local, evitando erros de
permissões dos pontos de montagem entre o host e container.

Essa imagem builder está disponível no [docker hub](https://hub.docker.com/r/dleemoo/bank-accounting-builder)
e não há a necessidade de fazer o build da mesma no ambiente de
desenvolvimento.

O arquivo `.example.env` contém uma configuração completa e não há necessidade
de modificações para execução local:

- porta `4567`, diponibilizando a apllicação em `http://localhost:4567`
- token `18DC2F0268ABDD37D3024722FC4AEFC065AA0C30`, para authenticação

Para configurar o ambiente local, basta fazer:

```shell
git clone https://github.com/dleemoo/bank-accounting
cd bank-accounting
cp .example.env .env
./config/docker/development/build
docker-compose run --rm bank-accounting bundle install
docker-compose run --rm bank-accounting bundle exec rails db:create db:migrate
```

Feito estes passos, a qualquer momento a applicação poderá ser executada com o
seguinte comando:

```shell
docker-compose up
```

Esse setup só é adequado para o ambiente de desenvolvimento. Localmente,
pode-se subir a applicação no modo de produção applicando as seguintes
alterações no arquivo `.env`:

```diff
-# RAILS_ENV=development
+RAILS_ENV=production
 
-DATABASE_URL=postgres://postgres@db
+DATABASE_URL=postgres://postgres@db/bank_accounting_development
```

## Operação

Para todos os requests é necessário definir os headers `Authorization` e
`Content-Type`. Por exemplo, um request válido deve ter a forma:

```shell
curl --request POST --url http://localhost:4567/some-endpoint \
  --header 'Authorization: Bearer #{ENV['AUTH_TOKEN']}' \
  --header 'Content-Type: application/json' \
  --data 'json-payload'
```

### Adicionando novas contas

O primeiro passo para operar o sistema é adicionar novas contas. Para isso
pode-se utilizar o endpoint `POST /accounts` utilizando como payload:

```json
{
  "name": "Account 001"
}
```

O retorno deste endpoint é os atributos da nova conta em JSON.

Isso criará uma nova conta e retornará os attributos da nova conta. O `id` das
contas será necessário nas demais operações.

Você precisará de ao menos duas contas para realizar operações de
transferências.

### Adicionando dinheiro no sistema

A única forma esperada para entrada de dinheiro no sistema é através do
endpoint `POST /deposit`. O payload esperado é:

```json
{
  "account_id": "uuid-da-conta",
  "amount": 100.30
}
```

A resposta retornará o registro `Operation` criado para essa operação e o valor
será adicionado a conta informada.

### Consultando o saldo

O saldo de qualquer conta pode ser consultado através do endpoint `POST
/balance`. O payload esperado é:

```json
{
  "account_id": "uuid-da-conta"
}
```

O retorno desta operação informará o valor atual disponível na conta.

### Realizando transferências

Valores podem ser movimentados entre contas atraves do endpoint `POST
/transfer` e o payload espeado é:

```json
{
  "source_account_id": "uuid-da-conta-de-origem",
  "target_account_id": "uuid-da-conta-de-destino",
  "amount": 40
}
```

A resposta retornará o registro `Operation` criado para essa operação e o valor
será movido entre as duas contas informadas.

## Exemplos

Os exemplos nesta seção utilizam a seguinte função bash para facilitar testes
rápidos (é esperado que um `source $app_root/.env` seja executado antes):

```bash
function http-request() {
  (
    set -euo pipefail

    path="${1:-}"
    [ -n "$path" ] && shift

    curl \
      --include \
      --silent \
      --header "Content-Type: application/json" \
      --header "Authorization: Bearer $AUTH_TOKEN" \
      "$@" \
      "http://localhost:$EXTERNAL_PORT/$path" |
      sed -e 1b -e '$!d'

    status=$?
    echo
    return $status
  )
}
```

### Criando novas contas

```
http-request /accounts --data '{"name":"Account 001"}'
HTTP/1.1 201 Created
{
  "id":"c62fb1e6-1d16-4a8f-a665-08bf1cdd7aa4",
  "name":"Account 001",
  "created_at":"2022-09-01T14:00:40.678Z",
  "updated_at":"2022-09-01T14:00:40.678Z"
}
````

```
http-request /accounts --data '{"name":"Account 002"}'
HTTP/1.1 201 Created
{
  "id":"6334f85a-1eb6-4166-8cba-f0d7d08447df",
  "name":"Account 002",
  "created_at":"2022-09-01T14:01:53.515Z",
  "updated_at":"2022-09-01T14:01:53.515Z"
}
```

### Adicionando saldo a uma conta

```
http-request /deposit --data '{"account_id":"c62fb1e6-1d16-4a8f-a665-08bf1cdd7aa4","amount":"29456.32"}'
HTTP/1.1 200 OK
{
  "id":"90e13665-de3f-43cf-8702-72ca0c833b5b",
  "kind":"deposit",
  "created_at":"2022-09-01T14:04:09.191Z",
  "updated_at":"2022-09-01T14:04:09.191Z"
}
```

### Realizando uma transferência

```
http-request /transfer \
  --data '{"source_account_id":"c62fb1e6-1d16-4a8f-a665-08bf1cdd7aa4",\
  "target_account_id":"6334f85a-1eb6-4166-8cba-f0d7d08447df","amount":"12323.12"}'
HTTP/1.1 200 OK
{
  "id":"fffeb997-87b5-4fbb-89aa-220c2597299e",
  "kind":"transfer",
  "created_at":"2022-09-01T14:06:21.950Z",
  "updated_at":"2022-09-01T14:06:21.950Z"
}
```

### Verificando os novos saldos

```
http-request /balance --data '{"account_id":"c62fb1e6-1d16-4a8f-a665-08bf1cdd7aa4"}'
HTTP/1.1 200 OK
{"amount":"17133.2"}
```

```
http-request /balance --data '{"account_id":"6334f85a-1eb6-4166-8cba-f0d7d08447df"}'
HTTP/1.1 200 OK
{"amount":"12323.12"}
```

### Alguns exemplos de erros

A API foi construída para que dê o melhor suporte possível para erros e não
aceita parâmetros não utilizados nas requisições. Segue alguns exemplos.

#### Payload inválido

Exemplo com um JSON faltando uma aspa:

```
http-request /balance --data '{"account_id":"6334f85a-1eb6-4166-8cba-f0d7d08447df}'
HTTP/1.1 400 Bad Request
{"errors":["Invalid JSON"]}
```

Exemplo com parâmetros inválidos:


```
http-request /balance --data '{"account_id":"6334f85a-1eb6-4166-8cba-f0d7d08447df","invalid":"item","error":true}'
HTTP/1.1 401 Unauthorized
{"error":"Invalid parameters","params":["invalid","error"]}
```

#### Dados inválidos

Formato inválido para o UUID:

```
http-request /balance --data '{"account_id":"6334f85a-1eb6-4166-8cba-f0d7d08447dg"}'
HTTP/1.1 422 Unprocessable Entity
{"errors":{"account_id":["is not a valid UUID"]}}
```

Conta que não existe:

```
http-request /balance --data '{"account_id":"6334f85a-1eb6-4166-8cba-f0d7d08447de"}'
HTTP/1.1 422 Unprocessable Entity
{"errors":{"account_id":["not found"]}}
```

Saldo insuficiente para transferência:

```
http-request /transfer \
  --data '{"source_account_id":"c62fb1e6-1d16-4a8f-a665-08bf1cdd7aa4",\
  "target_account_id":"6334f85a-1eb6-4166-8cba-f0d7d08447df","amount":"17133.21"}'
HTTP/1.1 422 Unprocessable Entity
{"errors":{"source_account_id":["insufficient funds"]}}
```

## Contribuindo

Bugs e feature request:

- Registrados atráves das issues do githbub

Alterações propostas:

- Fork, change, send PR

Nesse momento não há automação, mas garanta que os comandos não geram erros:

- docker-compose run --rm bank-accounting bundle exec brakeman
- docker-compose run --rm bank-accounting bundle exec rubocop

Garanta que há uma boa cobertura para novos códigos e que os testes estão
executando com sucesso:

- docker-compose run --rm bank-accounting bundle exec rspec

O report de coverage (em `tmp/coverage/index.html`) pode dar bons indicativos
de onde é preciso ter mais atenção na cobertura de testes.

## Observações

Eu não entendi por completo a especificação. Então, assumi alguns pontos e
descrevi brevemente o que considerei necessário no começo deste `README`.
Via e-mail, também foi enviado um feedback sobre minhas dúvidas.

Não foi tratado a questão de casas decimais, então operações com mais de duas
casas decimais funcionarão. O que não faz muito sentido, já que não se trata de
um sistema de posto de gasolina :grin:.
