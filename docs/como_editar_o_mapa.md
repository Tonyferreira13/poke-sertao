# Tilesets do Pokémon Educativo Nordestino

## Etapas da produção

Cada região terá seus próprios recursos, mantendo células e escala iguais entre os mapas.

1. **Caatinga** — pisos, caminhos, transições, limite rochoso e plantas transparentes.
2. **Vilarejo Central** — casas, praça, centro de cura e caminhos.
3. **Beira do Rio** — água, margens, areia úmida e vegetação ribeirinha.
4. **Sertão Solar** — terreno árido, rochas quentes e vegetação xerófila.

## Caatinga

- Conceito de terreno: `assets/tilesets/stage01_caatinga_concept_v4.png`, redesenhado usando as referências de pixel art como guia.
- Conceito de plantas: `assets/tilesets/stage01_caatinga_plants_concept_v3.png`, na mesma linguagem de pixel art e com alpha.
- Atlas de terreno: `assets/tilesets/caatinga_128.png`, 8×8 tiles uniformes de 128×128 px.
- Atlas de caminhos: `assets/tilesets/caatinga_paths_128.png`, 4×4 conectores transparentes.
- Atlas de plantas: `assets/tilesets/caatinga_plants_128.png`, 4×2 sprites com transparência real.
- Todos os tiles do jogo medem 128×128 px e são pintados inteiros em uma célula.
- A cena de teste mede 32×22 células; a borda rochosa bloqueia passagem.

No atlas de terreno, as linhas 0–1 têm variações de grama, 2–3 areia e terra, 4–5 pedras, 6 transições visuais entre gramado e solo e 7 rochas de contorno.

## Pintar no Godot

1. Abra `scenes/main.tscn` no Godot 4.7.
2. Selecione `World/Ground` para pintar pisos e terrenos.
3. Selecione `World/Paths` para desenhar caminhos sobre o piso. O atlas 4×4 tem finais, retas, curvas, junções em T e cruzamentos.
4. Selecione `World/Plants` para colocar tufos, arbustos e mandacarus; a transparência deixa o chão visível em volta.
5. Os caminhos conectores estão em ordem por máscara: cima=1, direita=2, baixo=4, esquerda=8. Tile 5 liga cima e baixo; tile 10 liga esquerda e direita; tile 15 é cruzamento.
6. Use botão direito ou Eraser para apagar. Mantenha `(10, 11)` livre para o início do jogador.

## Regenerar os recursos da Caatinga

```powershell
godot --headless --path . --script res://tools/build_caatinga_assets.gd
godot --headless --path . --editor --import --quit
godot --headless --path . --script res://tools/setup_caatinga_layers.gd
```

O construtor recorta as células em dimensões iguais e usa vizinho mais próximo. Os caminhos ficam sobre uma camada transparente; as plantas também mantêm canal alpha.

NPCs e falas continuam em `data/route.json`. `data/world.json` e `assets/tileset_caatinga.tres` são referências antigas.
