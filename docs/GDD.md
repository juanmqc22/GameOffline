# SEIVA — Game Design Document
### v0.1 — Documento vivo, atualizado continuamente

---

## 1. Visão do Jogo

Um jogo de sobrevivência e construção de base, offline, para iPhone, onde a razão de continuar jogando não é o loot — é o elenco pequeno de criaturas selvagens que você conquista, uma por uma, ao longo do tempo. Cada uma tem personalidade própria, memória do que você fez por ela (ou deixou de fazer), e pode se machucar, morrer de verdade, ou ir embora se você a negligenciar. A base que você constrói não é decoração: é o lar onde essas criaturas vivem, trabalham e crescem com você.

Não existe prazo de lançamento. Não existe loja. Não existe ninguém além de você jogando. O jogo pode — e deve — evoluir por meses ou anos, um sistema de cada vez.

---

## 2. Identidade e Diferenciais

O cruzamento que ninguém faz hoje:

| Referência | O que pegamos | O que NÃO pegamos |
|---|---|---|
| The Forest / Green Hell | Sobrevivência crua, escassez real | Terror gráfico, sanidade, doenças complexas |
| Palworld | Criaturas que ajudam na base | Criaturas como ferramentas descartáveis, coleção em massa |
| Pokémon | O prazer do vínculo | Times de 6, troca de membros, times descartáveis |
| Minecraft / Valheim | **A base inteira (decisão de 2026-07): mundo voxel aberto, mineração, construção livre bloco a bloco, fauna, ameaças noturnas, biomas — e o visual em blocos** | Multiplayer, mecânicas de circuito/automação genérica (a automação aqui vem das criaturas, seção 9) |
| Zelda | Mundo com mistério, quer explorar mais | Combate estilizado, dungeons puzzle |

**A frase que resume o jogo:** *"Eu não coleciono criaturas. Eu conquisto quem fica."*

**Reposicionamento (2026-07):** o jogo é assumidamente um *Minecraft-like* — a fundação (mundo voxel aberto, minerar, construir livremente, caçar, sobreviver à noite, explorar biomas) copia o que o Minecraft já acertou, sem reinventar. O diferencial NÃO está na base: está no elenco pequeno de **criaturas especiais** com personalidade, memória e vínculo individual (seções 8 e 9), que o Minecraft não tem. Nenhum outro jogo do gênero faz **sobrevivência real + vínculo individual com memória + automação de base ligada diretamente a quem você conquistou**. Cada criatura bonded desbloqueia uma capacidade única de base (ver seção 9) — isso é o que faz os sistemas conversarem entre si em vez de existirem em paralelo.

---

## 3. Fantasia Central

Você é o único humano num lugar que não pediu por você. Fome, sede e sono são reais — não punitivos ao ponto de ser burocracia, mas presentes o bastante pra cada expedição ter peso. A única razão de aguentar esse lugar é que, aos poucos, seres de verdade passam a confiar em você tanto quanto você neles.

Sobrevivência e vínculo são **coprotagonistas** — nem um serve de pano de fundo pro outro.

---

## 4. Gameplay Loop

### 4.1 Loop de 5 minutos
Sair da base → coletar um recurso específico que uma criatura sua "pediu" (sinalização visual, não texto) → gerenciar fome/sede/sono no trajeto → voltar.

### 4.2 Loop de 30 minutos
Expedição real a uma área nova ou mais funda (caverna, clareira desconhecida) → uma criatura companheira acompanha e reage ao ambiente (medo, curiosidade, cansaço dela) → risco real de não voltar antes de escurecer.

### 4.3 Loop de horas
A base evolui de abrigo pra território. Cada criatura bonded muda fisicamente a base (constrói, protege, produz). Negligenciar quem já se juntou tem custo — enfraquece o vínculo, ela some por dias, ou parte (reversível, ver seção 8.4).

### 4.4 Loop de longo prazo
O mundo tem ciclos sazonais que mudam biomas e forçam adaptação — não power creep infinito, e sim ciclos reconhecíveis que o jogador aprende a antecipar (mestria real). Novas criaturas e biomas se tornam acessíveis conforme a base e o elenco crescem.

---

## 5. Sobrevivência

**Pilares (os únicos três):**
- **Fome** — caçar, colher, cozinhar.
- **Sede** — encontrar e tratar água.
- **Sono/Fadiga** — dormir afeta capacidade física no dia seguinte; ciclo dia/noite real.

**Vida (HP)** existe como consequência, não como quarto pilar: dano vem de combate (vultos, queda futura) e de negligência extrema (fome/sede zeradas corroem a vida). Zerar a vida não é morte permanente do jogador — ele acorda no acampamento com parte da vida (estilo Minecraft), o custo é o deslocamento e o que ficou pra trás.

**Explicitamente fora de escopo:** temperatura, doenças, sanidade. Não agregam divertimento suficiente pra pagar o custo de desenvolvimento e de atenção do jogador — vira barra chata, não tensão.

---

## 6. Construção de Base

**Construção livre bloco a bloco, estilo Minecraft** (decisão de 2026-07 — substitui a ideia anterior de construção "mais guiada"): tudo que se minera pode ser colocado de volta em qualquer lugar do mundo. A base é o que o jogador quiser erguer — parede por parede, sem receitas de estrutura obrigatórias.

Três pilares por cima disso, todos igualmente importantes:
1. **Automação de produção** — armadilhas, fazendas, processamento automático — mas desbloqueada por criaturas bonded, não por tecnologia genérica (ver seção 9).
2. **Defesa contra ameaças** — muros e torres construídos bloco a bloco contra os vultos e eventos noturnos maiores.
3. **Lar vivo** — a base é onde as criaturas realmente vivem: dormem, comem, interagem entre si e com você visivelmente. Não é um menu de status, é um lugar que você vê acontecer.

---

## 7. Exploração e Mundo

- **Mundo aberto voxel** (2026-07): terreno em blocos gerado por seed, com biomas distintos lado a lado (seção 13), totalmente escavável e construível. Começa como uma ilha grande; a ambição é crescer o mapa (mais ilhas/continente por chunks) conforme o jogo evolui — aberto em possibilidade, autoral em conteúdo.
- Cada bioma tem cara, recursos e fauna próprios — a razão de explorar é ver o que vive lá e o que dá pra trazer de volta.
- Verticalidade real: montanhas com neve no topo, cavar até a rocha-mãe atrás de minérios, e cavernas autorais mais à frente.
- Segredos e ruínas ambientais contam história sem texto obrigatório (ver seção 14 sobre narrativa ambiental).
- Eventos de mundo (uma tempestade, uma migração de criaturas selvagens) criam variedade sem exigir conteúdo infinito.

---

## 8. Criaturas

### 8.1 Escopo
Elenco pequeno e profundo: **3 criaturas no MVP, 12–15 na v1.0.** Cada uma com identidade única — não uma IA por espécie, uma IA por indivíduo.

### 8.2 IA — Utility AI, não rede neural treinada
Cada criatura tem:
- **Necessidades** (fome própria, fadiga, vínculo, medo, curiosidade) — valores 0–100.
- **Personalidade** — pesos fixos definidos por criatura (ela valoriza mais explorar do que descansar, por exemplo).
- **Memória** — log de eventos marcantes ("o jogador me salvou no dia X", "fiquei 3 dias sem comida") que altera pesos permanentemente.

A cada decisão, o jogo pontua as ações possíveis (ajudar, descansar, fugir, ir embora, explorar) somando necessidade + personalidade + memória, e escolhe a de maior pontuação. Determinístico, debugável, e ajustável só com dados — nenhum modelo treinado, nenhuma dependência de rede.

### 8.3 Quando bond está alto
A criatura ajuda autonomamente em tarefas repetitivas da base (coleta, vigia, produção) — ela **escolhe** ajudar porque o peso de "ajudar" supera outras ações, não porque foi comandada.

### 8.4 Consequências reais (as três coexistem)
1. **Ferimento/trauma** — sobrevive, mas muda (medo de algo específico, perde capacidade temporária, precisa de tempo pra curar a relação).
2. **Morte permanente** — negligência grave ou combate real pode matá-la de vez.
3. **Partida por negligência** — ela abandona a base, mas é **recuperável**: encontrá-la de novo no mundo permite reconstruir o vínculo com esforço real (não é reset automático).

---

## 9. Vínculo e Conquista de Confiança

Sistema único de **Confiança** (0–100) que serve para todo o elenco — consistente o bastante pra escalar pra 15 criaturas sem multiplicar sistemas.

**O que sobe confiança:** oferecer o alimento certo (descoberto por observação/tentativa, não por wiki no jogo), aproximação calma, defendê-la de uma ameaça real, dar espaço quando ela está assustada, presença consistente ao longo de vários encontros (não em um só).

**O que derruba confiança:** movimentos bruscos, ataques, ignorar sinais de necessidade dela, abandono em perigo.

Ao cruzar o limiar de confiança (varia por personalidade — criaturas arredias exigem mais), dispara um **momento de vínculo** — uma cena curta e única, autorada à mão (viável porque o elenco é pequeno) que formaliza a aliança e ela passa a seguir você.

**A ponte com construção (o que faz os sistemas conversarem):** cada criatura bonded desbloqueia uma capacidade de base ligada à sua natureza — a que cava bem libera mineração automática, a que tem faro pra plantas libera fazenda automática, a que é territorial libera uma torre de vigia. **Você não escolhe tecnologia numa árvore genérica — você ganha capacidades ao conquistar quem as carrega.**

---

## 10. Combate

Tempo real (não turnos) — coerente com o ritmo de sobrevivência/ação. Tocar num alvo ataca (mesmo gesto de minerar — o mundo inteiro responde ao toque). Combate direto do jogador (armas craftadas, esquiva, stamina simples) + criaturas bonded que **ajudam por vontade própria** com base em personalidade/confiança (não comando de menu, reforça a autonomia da seção 8).

**Três categorias de seres vivos, com papéis distintos:**
1. **Fauna comum** — animais por bioma (capivara, cabra, lagarto...), caçáveis por carne. Sem vínculo, IA simples. É o "gado selvagem" do mundo.
2. **Ameaças** — **vultos** surgem à noite e caçam o jogador; somem ao amanhecer; derrotá-los rende cristal (risco/recompensa de sair no escuro). Mais tipos de ameaça e eventos de ataque à base virão. "Guardiões" ligados a biomas funcionam como chefes que gateiam progressão de área.
3. **Criaturas especiais** (seções 8–9) — o elenco com nome, personalidade e memória. **Atacá-las nunca compensa:** derruba confiança e fica gravado na memória delas.

---

## 11. Progressão

- **Jogador:** evolui fazendo (crafting, sobrevivência, combate), não por XP abstrato — mestria real ao estilo Zelda/Forest.
- **Criaturas:** evoluem pelo nível de vínculo, não por grind de batalhas — aprofunda papéis e habilidades conforme a relação amadurece.
- **Base:** evolui por quem se juntou a você (seção 9) — progressão de base = progressão de relações.
- **Mundo:** ciclos sazonais mudam o que é possível/necessário, criando releitura do que já foi dominado.

---

## 12. Crafting e Economia

Recursos limitados e legíveis (não centenas de materiais) — cada recurso tem um propósito claro. Blocos minerados são o material de construção; **minérios na pedra (carvão, cristal — quanto mais fundo, mais raro)** e o cristal dos vultos são a moeda do crafting que vem a seguir (ferramentas, fogueira/cozinha, armas). Equipamentos servem sobrevivência e exploração, não power fantasy de números. Raridade vem de dificuldade de acesso (bioma perigoso, profundidade, noite), não de RNG puro.

---

## 13. Biomas

Decisão de 2026-07 (substitui o plano de 1 bioma no MVP): a ilha inicial já nasce com **4 biomas lado a lado**, gerados por ruído — variedade de exploração desde o primeiro dia, ao estilo Minecraft.

- **MVP:** *Campo* (spawn, fauna mansa), *Floresta* (madeira, cogumelos, sombra), *Deserto* (areia, lagartos) e *Montanha* (pedra exposta, neve, cabras).
- **v1.0:** mapa maior (mais ilhas/continente), + *Litoral* + *Cavernas Profundas*, fauna e recursos exclusivos por bioma.
- **Expansões:** biomas sazonais/especiais, desbloqueados por progressão de elenco e narrativa ambiental.

---

## 14. Uso de IA (desenvolvimento e jogo)

**No desenvolvimento (com apoio de LLM, sem depender de internet no jogo final):** geração de conteúdo em tempo de desenvolvimento — variações de diálogo, textos de flavor de itens, regras de povoamento de bioma, planilhas de balanceamento — tudo assado em arquivos de dados estáticos (JSON/Resources do Godot) antes do build. Zero dependência de rede em runtime.

**No jogo (runtime, 100% offline):** Utility AI (seção 8.2) para comportamento de criaturas — não é machine learning treinado, é lógica orientada a dados, gerável e ajustável comigo (Claude) como par de desenvolvimento contínuo.

---

## 15. Interface e Controles para iPhone

- Joystick virtual (polegar esquerdo) para movimento.
- Arraste no lado direito da tela para orbitar a câmera (câmera terceira pessoa, estilo "A Short Hike"/Genshin mobile, mas simplificada) — sem exigir botões dedicados de câmera.
- Botão de ação contextual (polegar direito) — interagir/atacar/coletar conforme o alvo.
- Gesto de swipe-up para chamar a criatura mais próxima.
- Menu radial (tap-hold) para inventário/crafting — poucos toques, alvos grandes.
- UI minimalista: barras de fome/sede/sono discretas, sem poluir a tela.

---

## 16. Arquitetura Técnica (Godot, 3D low-poly)

- **Motor:** Godot 4.x, GDScript.
- **Estilo de arte:** voxel/blocos estilo Minecraft (decisão de 2026-07, substituindo o "low-poly genérico" anterior que estava derivando sem alvo claro). O mundo é uma grade de cubos de 1 m (terreno, árvores, água); personagens e criaturas são bonecos de caixas com animação simples de balanço; cores chapadas por vértice/material com sombreamento por face (topo claro, laterais escuras) e leve variação de tom por bloco — sem texturas externas. Um visual-alvo conhecido e fácil de manter consistente, extremamente leve no iPhone.
- **Mundo voxel editável:** os blocos vivem numa estrutura de dados (`Vector3i -> id`), o mapa é dividido em chunks de 16×16 colunas e cada chunk tem malha + colisão próprias, remalhadas só quando um bloco daquele chunk muda (minerar/colocar). A geração é 100% derivada de uma **seed fixa**; o save guarda apenas o **diff de edições do jogador** (`GameState.world_edits`) — o mundo nunca é serializado inteiro. Isso também deixa o caminho aberto pra expandir o mapa por chunks no futuro.
- **Interação de toque unificada:** toque curto no mundo = raycast → minerar / colocar (slot da hotbar selecionado) / atacar. Arrastar = câmera. Botão "Agir" = gesto de cuidado (alimentar, colher, beber) — deliberadamente separado do gesto de violência/trabalho, pra interação com criaturas especiais nunca ser um mis-tap.
- **Build/deploy:** projeto é desenvolvido inteiramente no editor do Godot (não exige Xcode no dia a dia). O Xcode só entra no **passo final de exportação** para gerar o `.ipa` e instalar no iPhone 15 via cabo — isso o Mac dá conta tranquilamente. Quando chegarmos nesse ponto, eu te guio pelo processo (é a parte que você nunca fez, então vamos devagar nela especificamente).
- **Autoloads (singletons):** `GameState`, `SaveManager` (serialização local em `user://`), `TimeManager` (ciclo dia/noite, estações), `CreatureRegistry`.
- **Criaturas orientadas a dados:** cada espécie/indivíduo é um `Resource` (`.tres`) com necessidades, personalidade e referências de comportamento — novas criaturas se adicionam sem tocar em código central.
- **Save system:** JSON local em `user://saves/`, sem servidor, sem internet.
- **Estrutura de cenas:** `World` (cenas `Node3D` com meshes low-poly) → `Player` (`CharacterBody3D` + rig de câmera terceira pessoa) → `Creatures` (`CharacterBody3D` + componente UtilityAI) → `UI` (`CanvasLayer` com controles touch em 2D sobre a cena 3D).
- **Performance:** low-poly + flat shading é extremamente leve — o iPhone 15 roda isso sem esforço, sobra margem para efeitos (iluminação dinâmica simples, névoa de distância) mais pra frente.

---

## 17. Roadmap

### MVP (~2–3 meses, dedicação parcial)
- Ilha com 4 biomas (Campo, Floresta, Deserto, Montanha) ✅
- Mundo voxel editável: mineração + construção livre bloco a bloco ✅
- Fauna caçável por bioma + ameaça noturna (vultos) + vida/respawn ✅
- 3 criaturas especiais (necessidades, personalidade, memória, confiança ✅; momento de vínculo autorado ainda falta)
- Sobrevivência: fome, sede, sono ✅ (dormir de verdade ainda falta)
- Crafting básico (ferramentas, fogueira/cozinhar)
- Save local funcional ✅
- Controles touch completos ✅

### v1.0 (~6–12 meses)
- 3 biomas
- 12–15 criaturas completas
- Automação de base ligada a criaturas bonded
- Defesa de base (eventos noturnos)
- Crafting completo
- Progressão de habilidades do jogador
- Narrativa ambiental (ruínas, segredos, eventos de mundo)

### Expansões futuras
- Biomas sazonais/especiais
- Criaturas raras/migratórias
- Sistema de clima
- Novas capacidades de base ligadas a criaturas futuras
