# Seiva — projeto Godot

Documento de design completo em [`../docs/GDD.md`](../docs/GDD.md). Leia antes de mexer em sistemas — cada decisão aqui vem de uma escolha explícita feita ali.

## Estado atual

**Um Minecraft-like assumido** (GDD seção 2): a fundação copia o que o Minecraft acertou; o diferencial é o elenco de criaturas especiais com vínculo e memória.

- Motor: Godot 4.3+, GDScript. Visual em blocos, tudo gerado em código, sem assets externos.
- **Mundo voxel editável** (`scripts/world/voxel_world.gd`): ilha 64×64 com 4 biomas (Campo, Floresta, Deserto, Montanha com neve), lago, praias, árvores de blocos e minérios na pedra (carvão; cristal no fundo). Chunks de 16×16 remalham só quando um bloco muda. Seed fixa; o save guarda apenas o diff do que o jogador minerou/construiu.
- **Mineração e construção livre**: toque curto num bloco minera; com um slot da hotbar selecionado (terra/pedra/areia/tronco/neve), o toque coloca o bloco. Rocha-mãe (y=0) é inquebrável. Arrastar continua sendo câmera; degraus de 1 bloco sobem sozinhos (auto-jump).
- **Fauna por bioma, caçável**: capivara (campo/floresta), cabra (montanha), lagarto (deserto) — tocar ataca, derrubar rende carne.
- **Ameaça noturna**: vultos surgem ao anoitecer, perseguem e batem; somem ao amanhecer; derrotá-los dá cristal.
- **Vida do jogador**: dano de vulto e de fome/sede zeradas; zerar a vida = acordar no acampamento com parte da vida.
- **Criaturas especiais** (o diferencial — `resources/creatures/*.tres` + `CreatureAI`): Vix (arredia), Brum (calmo), Lume (curiosa). Utility AI com confiança, memória e momento de vínculo. Botão "Agir" alimenta/aproxima (parado = aproximação calma); **atacar uma criatura especial derruba confiança e fica na memória dela**.
- Sobrevivência (fome/sede/sono) drenando com o ciclo dia/noite; coleta de bagas/cogumelos; comer/beber; HUD com barras, relógio, inventário e mensagens.
- Save/load local em `user://saves/slot_1.json` — inclui inventário, vida, edições de mundo e estado/memória das criaturas.

## Abrir o projeto

1. Baixe o Godot 4.3+ (gratuito): https://godotengine.org/download
2. Abra o Godot, "Import", aponte para `game/project.godot`.
3. Rode a cena principal (F5) — ela já está configurada (`Main.tscn`).

## Rodar no seu iPhone 15 (mais pra frente)

Isso exige o Xcode instalado no seu Mac (só nesse passo final, não no dia a dia de desenvolvimento). Quando os sistemas do MVP estiverem prontos, o processo é:
1. Godot exporta um projeto Xcode (`Project > Export`, preset iOS).
2. Abre esse projeto no Xcode, conecta o iPhone por cabo, seleciona seu dispositivo, roda.
3. Como você nunca fez isso, faremos esse passo juntos, devagar, quando chegar a hora.

## Próximos passos sugeridos

- Crafting básico (bancada: ferramentas de pedra, fogueira pra cozinhar carne).
- Dormir de verdade (cama pula a noite — e decide se você enfrenta ou evita os vultos).
- Momento de vínculo autorado por criatura + criaturas bonded ajudando visivelmente na base.
- Mapa maior (mais chunks/ilhas) e cavernas.
