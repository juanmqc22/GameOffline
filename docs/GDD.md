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
| Minecraft / Valheim | Base evolui, defesa, automação | Blocos infinitos livres — aqui a construção é mais guiada |
| Zelda | Mundo com mistério, quer explorar mais | Combate estilizado, dungeons puzzle |

**A frase que resume o jogo:** *"Eu não coleciono criaturas. Eu conquisto quem fica."*

O diferencial técnico-de-design: nenhum outro jogo do gênero faz **sobrevivência real + vínculo individual com memória + automação de base ligada diretamente a quem você conquistou**. Cada criatura bonded desbloqueia uma capacidade única de base (ver seção 9) — isso é o que faz os sistemas conversarem entre si em vez de existirem em paralelo.

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

**Explicitamente fora de escopo:** temperatura, doenças, sanidade. Não agregam divertimento suficiente pra pagar o custo de desenvolvimento e de atenção do jogador — vira barra chata, não tensão.

---

## 6. Construção de Base

Três pilares, todos igualmente importantes:
1. **Automação de produção** — armadilhas, fazendas, processamento automático — mas desbloqueada por criaturas bonded, não por tecnologia genérica (ver seção 9).
2. **Defesa contra ameaças** — paliçadas, torres, eventos de ataque noturno.
3. **Lar vivo** — a base é onde as criaturas realmente vivem: dormem, comem, interagem entre si e com você visivelmente. Não é um menu de status, é um lugar que você vê acontecer.

---

## 7. Exploração e Mundo

- Mundo semi-aberto, biomas conectados (não infinito/procedural puro — permite mão autoral em segredos e ruínas, mais viável pra dev solo que geração infinita balanceada).
- Verticalidade real (cavernas, penhascos, copas de árvore) — natural em 3D, sem precisar simular profundidade como em 2D.
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

Tempo real (não turnos) — coerente com o ritmo de sobrevivência/ação. Combate direto do jogador (armas craftadas, esquiva, stamina simples) + criaturas bonded que **ajudam por vontade própria** com base em personalidade/confiança (não comando de menu, reforça a autonomia da seção 8). "Guardiões" ligados a biomas funcionam como chefes que gateiam progressão de área.

---

## 11. Progressão

- **Jogador:** evolui fazendo (crafting, sobrevivência, combate), não por XP abstrato — mestria real ao estilo Zelda/Forest.
- **Criaturas:** evoluem pelo nível de vínculo, não por grind de batalhas — aprofunda papéis e habilidades conforme a relação amadurece.
- **Base:** evolui por quem se juntou a você (seção 9) — progressão de base = progressão de relações.
- **Mundo:** ciclos sazonais mudam o que é possível/necessário, criando releitura do que já foi dominado.

---

## 12. Crafting e Economia

Recursos limitados e legíveis (não centenas de materiais) — cada recurso tem um propósito claro. Equipamentos servem sobrevivência e exploração, não power fantasy de números. Raridade vem de dificuldade de acesso (bioma perigoso, criatura selvagem territorial), não de RNG puro.

---

## 13. Biomas

- **MVP:** 1 bioma completo — *Floresta Viva*.
- **v1.0:** + *Litoral* + *Cavernas Profundas*.
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
- **Estilo de arte:** 3D low-poly básico — formas geométricas simples, cor vertex/flat shading em vez de texturas complexas, pouca ou nenhuma animação de rig avançada no início (blend simples de poses). Prioriza tempo de sistemas sobre fidelidade visual, mas entrega volume/profundidade real que o 2D não dava.
- **Build/deploy:** projeto é desenvolvido inteiramente no editor do Godot (não exige Xcode no dia a dia). O Xcode só entra no **passo final de exportação** para gerar o `.ipa` e instalar no iPhone 15 via cabo — isso o Mac dá conta tranquilamente. Quando chegarmos nesse ponto, eu te guio pelo processo (é a parte que você nunca fez, então vamos devagar nela especificamente).
- **Autoloads (singletons):** `GameState`, `SaveManager` (serialização local em `user://`), `TimeManager` (ciclo dia/noite, estações), `CreatureRegistry`.
- **Criaturas orientadas a dados:** cada espécie/indivíduo é um `Resource` (`.tres`) com necessidades, personalidade e referências de comportamento — novas criaturas se adicionam sem tocar em código central.
- **Save system:** JSON local em `user://saves/`, sem servidor, sem internet.
- **Estrutura de cenas:** `World` (cenas `Node3D` com meshes low-poly) → `Player` (`CharacterBody3D` + rig de câmera terceira pessoa) → `Creatures` (`CharacterBody3D` + componente UtilityAI) → `UI` (`CanvasLayer` com controles touch em 2D sobre a cena 3D).
- **Performance:** low-poly + flat shading é extremamente leve — o iPhone 15 roda isso sem esforço, sobra margem para efeitos (iluminação dinâmica simples, névoa de distância) mais pra frente.

---

## 17. Roadmap

### MVP (~2–3 meses, dedicação parcial)
- 1 bioma (Floresta Viva)
- 3 criaturas completas (necessidades, personalidade, memória, confiança, momento de vínculo)
- Sobrevivência: fome, sede, sono
- Base manual (construção básica, sem automação ainda)
- Combate simples
- Save local funcional
- Controles touch completos

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
