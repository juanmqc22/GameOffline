# Seiva — projeto Godot

Documento de design completo em [`../docs/GDD.md`](../docs/GDD.md). Leia antes de mexer em sistemas — cada decisão aqui vem de uma escolha explícita feita ali.

## Estado atual

- Motor: Godot 4.3+, GDScript.
- **Visual: blocos estilo Minecraft** (GDD seção 16) — terreno em cubos de 1 m gerado proceduralmente com seed fixa (`scripts/world/block_world.gd`: colinas, lago raso, praia, árvores), personagens e criaturas são bonecos de caixas com animação de passada (`scripts/visuals/`). Tudo em código, sem assets externos.
- Ciclo dia/noite visível: sol, cor do céu e da luz seguem o `TimeManager` (`scripts/world/day_night_cycle.gd`).
- Movimento por joystick virtual (esquerda da tela) + órbita de câmera por arraste (direita da tela). Degraus de 1 bloco sobem sozinhos (auto-jump, como no Minecraft mobile).
- **3 criaturas do elenco do MVP** com Utility AI (vagar, descansar, seguir, fugir, ajudar), cada uma um `.tres` em `resources/creatures/`:
  - **Vix** — raposa-do-musgo arredia (foge fácil; fique parado perto dela pra ela tolerar você).
  - **Brum** — tatu-pedra calmo que quase não foge, mas exige consistência.
  - **Lume** — ave-vagalume curiosa com o limiar de vínculo mais alto do trio.
- **Botão "Agir" contextual**: alimentar/aproximar-se de criatura > colher bagas/cogumelos > beber água do lago. Botão "Comer" consome comida do inventário.
- Coleta: arbustos de baga (rebrotam em 12h in-game) e cogumelos azuis perto de árvores (24h). Alimentar com a comida favorita da criatura sobe confiança bem mais rápido.
- Fome/sede/sono do jogador drenam com o ciclo dia/noite e aparecem no HUD, junto com relógio/dia, inventário e mensagens contextuais.
- Save/load local em `user://saves/slot_1.json` (offline, sem servidor) — inclui inventário e estado/memória das criaturas. O mundo não vai pro save: a seed é fixa, ele é sempre o mesmo.

## Abrir o projeto

1. Baixe o Godot 4.3+ (gratuito): https://godotengine.org/download
2. Abra o Godot, "Import", aponte para `game/project.godot`.
3. Rode a cena principal (F5) — ela já está configurada (`Main.tscn`).

## Rodar no seu iPhone 15 (mais pra frente)

Isso exige o Xcode instalado no seu Mac (só nesse passo final, não no dia a dia de desenvolvimento). Quando os sistemas do MVP estiverem prontos, o processo é:
1. Godot exporta um projeto Xcode (`Project > Export`, preset iOS).
2. Abre esse projeto no Xcode, conecta o iPhone por cabo, seleciona seu dispositivo, roda.
3. Como você nunca fez isso, faremos esse passo juntos, devagar, quando chegar a hora — não precisa se preocupar com isso agora.

## Próximos passos sugeridos

- Momento de vínculo autorado por criatura (hoje é só uma mensagem no HUD).
- Dormir de verdade (interagir com um lugar de descanso pra recuperar Sono e pular a noite).
- Primeiro pedaço de construção de base (GDD seção 6) e criaturas bonded ajudando visivelmente.
- Combate simples + primeira ameaça noturna.
