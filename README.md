# Pedido Venda Desktop

Aplicação desktop em Delphi (VCL) para cadastro e manutenção de pedidos de venda com persistência em SQLite via FireDAC.

## Visão Geral

O sistema permite:
- Buscar cliente por código
- Buscar produto por código
- Montar itens do pedido (quantidade, valor unitário e total)
- Gravar pedido e itens
- Carregar pedido existente
- Excluir pedido

A aplicação usa uma arquitetura em camadas:
- `src/Presentation`: interface e eventos do formulário
- `src/Application`: regras de aplicação (serviço de pedido)
- `src/Infrastructure`: conexão, repositórios e scripts de versão
- `src/Core`: entidades e exceções

## Tecnologias

- Delphi (VCL)
- FireDAC
- SQLite

## Estrutura do Projeto

- `PedidoVenda.dpr`: ponto de entrada da aplicação
- `src/Presentation/Frm.Pedido.pas`: tela principal
- `src/Application/App.Service.Pedido.pas`: orquestração e validações
- `src/Infrastructure/Infra.Connection.Manager.pas`: configuração e conexão SQLite
- `src/Infrastructure/Infra.Repository.*.pas`: acesso a dados
- `src/Infrastructure/Infra.ScriptVersao.pas`: criação de schema e carga inicial
- `src/Data/pedidos.db`: banco de dados SQLite

## Requisitos

- Delphi com suporte a VCL
- FireDAC disponível no ambiente
- Driver SQLite do FireDAC

## Como Executar

1. Abra `PedidoVenda.dproj` no Delphi.
2. Compile e execute o projeto (`Run`).
3. No startup, a aplicação:
   - Configura e abre conexão com SQLite
   - Executa scripts de versão (`script_versao`) para criar/atualizar schema
   - Insere dados de teste (clientes e produtos) quando necessário

## Banco de Dados

Atualmente, o código procura o arquivo em:
- `src/Data/pedidos.db` relativo à raiz do projeto

Se o banco não for encontrado, a aplicação lança erro de inicialização.

## Scripts e Versões

A tabela `script_versao` controla quais scripts já rodaram.

Versões implementadas em `Infra.ScriptVersao.pas`:
- `1`: criação da tabela `clientes`
- `2`: criação da tabela `produtos`
- `3`: criação da tabela `pedidos`
- `4`: criação da tabela `pedido_itens`
- `5`: carga de clientes de teste
- `6`: carga de produtos de teste

## Regras Importantes

- Pedido sem cliente não pode ser gravado
- Pedido sem itens não pode ser gravado
- Item calcula total por `quantidade * vr_unitario`
- Total do pedido é a soma dos totais dos itens




