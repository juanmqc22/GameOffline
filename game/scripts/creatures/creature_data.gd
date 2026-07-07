extends Resource
class_name CreatureData
## Definição orientada a dados de uma criatura individual (não uma espécie genérica).
## Cada criatura do elenco (~15 no total do jogo) é um recurso .tres separado,
## editável sem tocar em código. Ver docs/GDD.md secao 8.

@export var creature_id: String = ""
@export var display_name: String = ""
@export_multiline var flavor_text: String = ""

## Comida favorita descoberta por observação/tentativa, não exposta na UI.
@export var favorite_food_id: String = ""

## Pesos de personalidade (0.0 a 2.0). Multiplicam a pontuação de cada ação
## no Utility AI. Duas criaturas da "mesma espécie" podem ter pesos diferentes.
@export var explore_weight: float = 1.0
@export var rest_weight: float = 1.0
@export var help_weight: float = 1.0
@export var flee_weight: float = 1.0
@export var flee_threshold: float = 30.0 # abaixo de qual confiança ela foge de novos contatos

## Limiar de confiança para o "momento de vínculo" (seção 9 do GDD).
## Criaturas mais arredias exigem mais.
@export var bond_threshold: float = 70.0

## Paleta do visual em blocos (BlockyCreatureVisual) — o mesmo boneco de
## caixas serve pro elenco inteiro, cada criatura só troca as cores.
@export var body_color: Color = Color(0.7, 0.5, 0.3)
@export var accent_color: Color = Color(0.3, 0.2, 0.15)

## Estado runtime (persistido pelo SaveManager) — não editar no recurso base.
@export var trust: float = 0.0
@export var hunger: float = 100.0
@export var fatigue: float = 0.0
@export var is_bonded: bool = false
@export var is_injured: bool = false
@export var has_left: bool = false

## Memória: lista simples de flags de eventos marcantes (ex: "rescued_from_predator").
## Cada flag pode ajustar pesos em runtime via CreatureAI.apply_memory_flag().
@export var memory_flags: Array[String] = []
