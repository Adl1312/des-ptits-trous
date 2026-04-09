# des-ptits-trous
Génération d’images tramées pour impression xp grand format

Ce programme permet de transformer une image en trame composée de formes simples (ellipses ou carrés), afin de produire des visuels adaptés à une impression grand format expérimentale, une découpe plotter ou des techniques artisanales (emporte-pièces, pochoirs, etc.).

Il a été développé dans le cadre d’un projet d’impression sur très grande longueur (jusqu’à 18 mètres) sans imprimante adaptée.

## Principe

L’image est convertie en niveaux de gris puis reconstituée sous forme de trame :

- chaque cellule de la grille correspond à une forme

- la taille de la forme dépend de la luminosité

- la trame peut être continue ou discrète (4 tailles)

- les formes peuvent être elliptiques ou carrées

L’objectif est d’obtenir une image lisible à distance, reproductible avec des outils simples, et adaptée à des contraintes matérielles.

## Installation
Installer Processing

Ajouter la librairie processing.svg

Ouvrir le sketch dans Processing

## Utilisation
Déposer une image dans le dossier data
(formats acceptés : .png, .jpg, .jpeg)

Lancer le programme

Ajuster les paramètres en direct :

- taille de la grille

- échelle des formes

- proportion (aspect)

- rotation

- inversion noir/blanc

- mode discret ou continu

- type de forme
### Exporter le résultat :
- PNG transparent

- PNG haute résolution

- SVG vectoriel

## Raccourcis principaux

### Navigation :

n : image suivante

p : image précédente

### Réglages :

flèches ↑ ↓ : taille des cellules

+ / - : échelle des formes

flèches ← → : aspect

r / R : rotation

i : inversion

c : mode discret / continu

m : ellipse / carré

### Export :

s : PNG transparent

J : PNG haute résolution

v : SVG

g : SVG haute résolution

### HUD (interface) :

h : afficher / masquer

glisser la barre : déplacer

coin bas droit : redimensionner

## À quoi ça sert ?

### Le programme est pensé pour une fabrication réelle :

- impression en très grand format par assemblage

- découpe plotter ou manuelle

- usage avec emporte-pièces ou pochoirs

- lecture de l’image à distance

Le mode discret permet notamment de limiter le nombre de tailles utilisées, ce qui facilite la production.

### Formats de sortie
PNG transparent : pour réimport dans Illustrator ou mise en page
SVG : pour découpe vectorielle (plotter, laser, etc.)

Le SVG est recommandé pour la production physique.
