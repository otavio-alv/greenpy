# Casos de Uso - Greenpy
### Usuário Comum (Reciclador):

O usuário acessa o aplicativo Greepy. Se já tiver conta, faça login; caso contrário, realize o cadastro (opção de cadastro rápido com Conta Google).

Após entrar, o usuário vê o **Painel Principal**, contendo:
* Total de pontos acumulados
* Histórico de descartes/reciclagens realizados
* Classificação dos tipos de resíduos já reciclados

O usuário pode acessar a aba **Converter Pontos**, onde:
* Visualiza o total de pontos disponíveis, escolhe quantos pontos desejar converter
* Visualiza a lista de estabelecimentos parceiros e os valores de desconto correspondentes

Para realizar um descarte, o usuário acessa a aba **Pontos de Coleta**, onde:
* Visualizar as categorias de resíduos aceitos (papel, plástico, metal, etc.)
* Informa a quantidade e tipo de material que deseja descartar
* Seleciona o colaborador (ponto de coleta/estabelecimento)
* O sistema exibe os pontos de coleta mais próximos com base na localização do usuário
* Após o descarte ser confirmado pelo administrador, os pontos são creditados automaticamente ao usuário

Usuario Comum: 
Como um usuário que esqueceu a senha, pode solicitar uma redefinição de senha (via e-mail) para que possa recuperar o acesso à conta. Podendo também fazer alterações de dados no perfil para que as informações se mantenham atualizadas.
Ao procurar pontos de coletas o usuário poderá colocar os pontos de coletas por filtro do meterial que sera descartado, para não correr o risco de ir até um local de coleta e não esta mais recebendo o tipo do material a ser descartado.Recebendo confirmação imediata a partir do momento em que o Adm confirmar a coleta, o usuáro receberam uma notificação de confirmação e o total de pontos que recebeu.

### Administrador (Colaborador do Ponto de Coleta):

O administrador acessa o aplicativo com um perfil especial (login de administrador). Ele visualiza todas as informações disponíveis ao usuário comum mais:
* Nível atual de enchimento dos contêineres
* Quantidade total de coletas recebidas no dia/semana/mês
* Lista de usuários que realizaram descartes
* Estabelecimentos parceiros vinculados ao ponto

Ao receber um descarte físico do usuário:
O administrador acessa o painel de **Validação de Coletas**, confere o tipo e quantidade do material entregue e liberar manualmente os pontos correspondentes ao usuário.

O administrador também pode:
* Atualizar horários e dias de recebimento de materiais
* Informar quais tipos de resíduos estão sendo aceitos atualmente
* Ajustar a pontuação atribuída por tipo de material (ex.: plástico vale 10 pontos/kg)
* Sinalizar temporariamente a indisponibilidade de contêineres (ex: lotados)
