# Pokémon Educativo Nordestino

Protótipo de jogo 2D educativo ambientado no sertão nordestino. O projeto combina exploração, personagens e cenários regionais; atualmente a primeira área, Caatinga, serve para validar a arte e a montagem do mapa antes da implementação das próximas mecânicas.

> Projeto de fã, não oficial e sem afiliação com Pokémon ou seus titulares. O uso de marcas e personagens de terceiros permanece sujeito aos direitos de seus respectivos titulares.

## Requisitos

- Godot **4.7.2** ou compatível com a série 4.7.
- Renderizador GL Compatibility.

O executável do Godot não é incluído neste repositório. Abra `project.godot` pelo Project Manager do Godot e execute o projeto com **Run Project**.

## Controles atuais

- **WASD** ou **setas**: mover
- **Shift**: correr
- **Z**: interagir

## Mapa da Caatinga

A cena inicial é `scenes/main.tscn`. O mapa usa três camadas editáveis:

- `World/Ground`: grama, areia, terra, rochas, transições e limite do mapa.
- `World/Paths`: caminhos em uma folha 4×4 com finais, retas, curvas, junções em T e cruzamentos. Escolha manualmente a peça de acordo com as direções que devem se conectar.
- `World/Plants`: vegetação em atlas separado com transparência.

Cada tile ocupa uma célula de 128×128 px. Veja [docs/como_editar_o_mapa.md](docs/como_editar_o_mapa.md) para a disposição dos conectores e o processo de edição.

## Estrutura

- `assets/`: sprites e atlas usados pelo jogo, além dos conceitos atuais da Caatinga.
- `data/route.json`: personagens e falas da rota de teste.
- `docs/`: planejamento e instruções de produção.
- `scenes/`: cenas Godot.
- `scripts/`: movimentação, mundo, NPCs e diálogos.
- `tools/`: construtores dos atlas atuais e verificação do protótipo.

As referências visuais de terceiros e os arquivos CDR de trabalho ficam fora do repositório. As artes conceituais atuais usadas para gerar os atlas estão em `assets/tilesets/`.

## Regenerar os atlas da Caatinga

Com o executável Godot 4.7.2 acessível como `godot` no terminal:

```sh
godot --headless --path . --script res://tools/build_caatinga_assets.gd
godot --headless --path . --editor --import --quit
godot --headless --path . --script res://tools/setup_caatinga_layers.gd
```

No Windows, se `godot` não estiver no `PATH`, substitua-o pelo caminho do executável local do Godot. Não versionamos o executável junto ao projeto.

## Verificação

```sh
godot --headless --path . --script res://tools/smoke_test.gd
```

## Licença

Ainda não foi definida uma licença para o código ou para as artes do projeto. Até que os autores escolham uma, não há concessão explícita de permissão para reutilização ou redistribuição.
