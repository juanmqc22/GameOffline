# Seiva — projeto Godot

Documento de design completo em [`../docs/GDD.md`](../docs/GDD.md). Leia antes de mexer em sistemas — cada decisão aqui vem de uma escolha explícita feita ali.

## Estado atual (esqueleto MVP)

- Motor: Godot 4.3+, GDScript, 3D low-poly.
- 1 cena jogável (`scenes/world/Main.tscn`): chão placeholder, jogador, uma criatura (`Vix`).
- Movimento por joystick virtual (esquerda da tela) + órbita de câmera por arraste (direita da tela).
- Criatura com Utility AI funcional (vagar, descansar, seguir, fugir, ajudar) baseada em `resources/creatures/example_creature.tres` — dados, não código, definem personalidade.
- Fome/sede/sono do jogador drenam com o ciclo dia/noite (`TimeManager`) e aparecem no HUD.
- Save/load local em `user://saves/slot_1.json` (offline, sem servidor).

Nada disso tem arte final — tudo é placeholder geométrico (cápsulas, caixas) de propósito, pra não gastar tempo em arte antes dos sistemas estarem certos.

## Abrir o projeto

1. Baixe o Godot 4.3+ (gratuito): https://godotengine.org/download
2. Abra o Godot, "Import", aponte para `game/project.godot`.
3. Rode a cena principal (F5) — vai pedir a cena padrão, ela já está configurada (`Main.tscn`).

## Rodar no seu iPhone 15 (mais pra frente)

Isso exige o Xcode instalado no seu Mac (só nesse passo final, não no dia a dia de desenvolvimento). Quando os sistemas do MVP estiverem prontos, o processo é:
1. Godot exporta um projeto Xcode (`Project > Export`, preset iOS).
2. Abre esse projeto no Xcode, conecta o iPhone por cabo, seleciona seu dispositivo, roda.
3. Como você nunca fez isso, faremos esse passo juntos, devagar, quando chegar a hora — não precisa se preocupar com isso agora.

## Próximos passos sugeridos

- Trocar formas placeholder por meshes low-poly simples (ainda sem textura).
- Implementar o gatilho de alimentar/interagir com a criatura (botão "Agir" já existe na UI, falta a lógica de detectar alvo próximo).
- Adicionar as outras 2 criaturas do elenco do MVP (ver `docs/GDD.md` seção 17).
