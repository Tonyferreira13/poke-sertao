# Produção dos tilesets por região

## Padrão visual

- Visão superior ortográfica, células regulares e sem suavização.
- Cada tile mede 128×128 px e é pintado inteiro em uma célula do mapa.
- `texture_filter=nearest` mantém as bordas firmes.
- Piso, caminho conectável e objetos transparentes ficam em camadas separadas.

## Sequência

| Etapa | Região | Conteúdo principal | Estado |
|---|---|---|---|
| 1 | Caatinga | pisos, transições, caminhos 4×4, borda rochosa e plantas com alpha | gerada e integrada |
| 2 | Vilarejo Central | praça, casas, centro de cura, fachadas e mobiliário | próxima |
| 3 | Beira do Rio | água, margens, areia úmida, plantas e pedras ribeirinhas | pendente |
| 4 | Sertão Solar | terreno árido, rochas quentes e vegetação xerófila | pendente |

Produzir e revisar cada etapa dentro do mapa antes de começar a seguinte, mantendo dimensões, grid, paleta e escala entre regiões.
