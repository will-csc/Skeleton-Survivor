# Skeleton Survivor

Jogo top-down survival feito em Godot, onde o jogador enfrenta ondas de inimigos, coleta armas derrubadas no mapa e tenta sobreviver o máximo possível.

## Visão Geral

- Movimento em arena com personagem controlado por teclado.
- Mira com o mouse e disparo com clique esquerdo.
- Inimigos perseguem o jogador e ficam mais perigosos com o tempo.
- Armas podem cair ao derrotar inimigos, incluindo uma arma lendária com chance especial.

## Controles

- `W`, `A`, `S`, `D`: mover
- `Mouse`: mirar
- `Botão esquerdo`: atirar

## Armas

- `Pistol`: arma base.
- `Airbow`: 1 tiro com velocidade dobrada.
- `Minigun`: 5 tiros por disparo.
- `Shotgun`: 5 tiros por disparo com espalhamento aleatório para frente.
- `Sniper`: 1 tiro a cada 3 segundos, projétil com velocidade dobrada e eliminação instantânea.
- `Legendary Minigun`: 10 tiros por disparo com espalhamento aleatório para frente e chance de drop separada.

## Progressão

- Armas não lendárias começam com `5%` de chance de drop.
- A cada `10` inimigos derrotados, a chance de drop normal aumenta em `1%`, até o máximo de `20%`.
- A `Legendary Minigun` começa com `0,1%` de chance de drop.
- A cada `10` inimigos derrotados, a chance da arma lendária aumenta em `0,5%`, até o máximo de `10%`.
- A cada `20` inimigos derrotados:
  - a velocidade dos inimigos aumenta em `10`;
  - a próxima leva recebe `+5` inimigos;
  - o limite total simultâneo também cresce.
- Inimigos surgem fora da tela e avançam até o jogador.

## Estrutura Do Projeto

- `scenes/main.tscn`: cena principal do jogo.
- `scripts/player.gd`: movimentação e estado do jogador.
- `scripts/enemy.gd`: comportamento, morte e drops dos inimigos.
- `scripts/enemy_spawner.gd`: geração e escalonamento das levas.
- `scripts/gun.gd`: lógica compartilhada das armas.
- `prefabs/`: cenas reutilizáveis para armas, inimigos e projéteis.

## Como Rodar

### Requisitos

- Godot `4.5` ou compatível.

### Passos

1. Abra o Godot.
2. Importe ou abra a pasta do projeto.
3. Abra `project.godot`.
4. Execute a cena principal do projeto.

## Repositório

Destino do código:

- [Skeleton-Survivor](https://github.com/will-csc/Skeleton-Survivor)
