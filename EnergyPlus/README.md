# main goal

optimal restart : déterminer le bon moment pour relancer le chauffage avant l’arrivée des occupants

Un des sujets les plus intéressants en thermique du bâtiment !

# fichiers osm

https://www.energycodes.gov/prototype-building-models

# build

```
docker build -t energyplus-python .
```

# outils gravitant autour de la modélisation du bâtiment

Outil | Usage
--|--
Rhino | Modélisation géométrique / paramétrique haut niveau.
Revit | BIM + coordination de projets, pas simulation.
Pollination | Pont moderne entre géométrie/BIM et simulation physique. Plateforme d’ingénierie avancée basée sur EnergyPlus pour experts, avec workflows paramétriques.
Pleiades | Outil d’ingénieur thermicien orienté réglementation française et audits.
EnergyPlus | Moteur de simulation thermique et énergétique de bâtiments développé par le DOE (Department of Energy américain).
openstudio application | free GUI pour visualiser l'idf qui va être utilisé par energyplus - https://github.com/openstudiocoalition/OpenStudioApplication

pour l'installation de openstudio application, aller dans les releases : https://github.com/openstudiocoalition/OpenStudioApplication/releases/
- pour windows, prendre l'exe
- pour linux, utiliser les tar.gz en choisissant la bonne version d'ubuntu. Ne pas passer par les fichiers sh qui sont trop lents à télécharger

sous linux/ubuntu, il peut etre necessaire de désinstaller openstudio lorsqu'on a essayé d'importer un idf incorrect

```
pkill -f OpenStudio
rm -rf ~/.openstudio
rm -rf ~/.local/share/OpenStudio*
rm -rf ~/.config/OpenStudio*
rm -rf ~/.cache/OpenStudio*
sudo rm -rf /usr/local/openstudio*
sudo rm -rf /opt/openstudio*
sudo dpkg -i OpenStudioApplication-1.6.0.deb
sudo apt-get install -f
```



# ladybug tools

des outils python pour produire un idf 

https://github.com/ladybug-tools

## géométrique

- honeybee - https://github.com/ladybug-tools/honeybee-core
- ladybug_geometry - https://github.com/ladybug-tools/ladybug-geometry

https://www.ladybug.tools/honeybee-energy/docs/index.html

## énergétique, matériaux

honeybee-energy - https://github.com/ladybug-tools/honeybee-energy


# epw files

epw = energy plus weather

https://climate.onebuilding.org

https://climate.onebuilding.org/WMO_Region_6_Europe/FRA_France/index.html

# idf files

Input Data File

# jupyter

run the jupyter server 

```
jupyter lab --ip=0.0.0.0 --port=8888 --allow-root --no-browser
```
