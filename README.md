# BankAccounting

Essa aplicação simula algumas operações bancárias.

É assumido que todas as operações são feitas por um operador de caixa
(funcionário do banco) e que possui acesso ao token de authenticação (um único
token, definido em variável de ambiente).

A applicação só aceita requests `POST`s e apenas com o `content-type`
appropridado (`JSON`).

## Setup

Esse repositório contém tudo que é necessário para executar essa aplicação
utilizando o `docker` e o `docker-compose`. Recomenda-se utilizar as versões:

- docker `19.03.3-ce`
- docker-compose `1.24.1`

É provável que qualquer verão que suporte o compose file na versão `3.7` irá
funcionar sem problemas, porém só foi testado com as versões acima.

No diretório `config/docker` está disponível o `Dockerfile` utilizado para
gerar a imagem utilizada no `docker-compose.yml`. Essa imagem está disponível
no [docker hub](https://hub.docker.com/r/dleemoo/bank-accounting) e não há a
necessidade de fazer o build da mesma.

O arquivo `.example.env` contém uma configuração completa e não há necessidade
de modificações para execução localmente (**desde que o seu usuário no host
possua o UUID 1000**).
Essa configuração usa:

- porta `4567`, diponibilizando a apllicação em `http://localhost:4567`
- token `18DC2F0268ABDD37D3024722FC4AEFC065AA0C30`, para authenticação

Para configurar o ambiente local, basta fazer:

```shell
git clone https://github.com/dleemoo/bank-accounting
cd bank-accounting
cp .example.env .env
docker-compose pull # obterá a imagem da applicação e do postgresql
docker-compose run --rm bank-accounting bundle install
docker-compose run --rm bank-accounting rake db:create db:migrate
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
 
-DATABASE_URL=postgres://postgres@pgdb12
+DATABASE_URL=postgres://postgres@pgdb12/bank_accounting_development
```

:warning:
Não há uma forma fácil de executar essa imagem do docker sem ser com um usuário
que tenha o **UUID** igual a **1000**. Diversos erros de permissão irão
acontecer e é até possível ajustá-los com um `chmod 1777` (o que será um pouco
trabalhoso).

Essa imagem não usa o **root** para executar a app dentro do container, porém o
usuário é hardcoded.
:warning:

## Operação

Para todos os requests é necessário definir os headers `authorization` e
`content-type`. Por exemplo, um request válido deve ter a forma:

```shell
curl --request POST --url http://localhost:4567/some-endpoint \
  --header 'authorization: Bearer #{ENV['AUTH_TOKEN']}' \
  --header 'content-type: application/json' \
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
  "amont": 40
}
```

A resposta retornará o registro `Operation` criado para essa operação e o valor
será movido entre as duas contas informadas.

## Insomnia

Há um arquivo com exemplo dos quatro endpoints disponível para o Insomnia
[disponível](https://github.com/dleemoo/bank-accounting/wiki/insomnia.json).

Ele inclui todas as operações e exemplos válidos dos payloads. Só haverá
necessidade de alterar os `id`s envolvidos e os valores conforme os testes a
serem realizados.

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
