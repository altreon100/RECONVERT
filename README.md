# Simulation Basée Agent pour RECONVERT

Se repertoire organise les éléments utile à la Simulation Basé Agent pour le project **RECONVERT**.
La simulation s'appuye sur la platfom-Gama.

Pour plus de détail sur:

- le projet : [./doc/reconvert.md](doc/reconvert.md).
- la platforme GAMA : [https://gama-platform.org](gama-platform.org)


## INSTALLATION

Dans un premier temps il vous faut installer Gama-Platform, ensuite vous pouvez cloner ce repertoire et charger le projet qu'il contiens.

### Gama-Platform

- Télégarger un installeur depuis la [https://gama-platform.org/download](download-page).
- Installer le logiciel (typiquement ouvrir le `.ded` téléchargé sous Ubuntu)
- Lancer Gama-Platfom
    * au premier lancement Gama vous demande de selectionné un repertoire de travaille. Créer/selectionner un repertoire à votre convenance sur votre machine.
- Pour tester la solution, vous pouvez vous référer aux [tutoriels](https://gama-platform.org/wiki/Tutorials).

### Projet RECONVERT

Le répertoire [./projet-gama](projet-gama) contient donc les sources et les fichier de configuration permettant de lancer la simulation **RECONVERT**.

Dans un premier temps récupérer localement de répertoire de travaille.
La solution geek et git consiste à cloner le repertoire

```sh
git clone https://github.com/altreon100/RECONVERT.git
```

Sur la page du projet, vous pouvais aussi télécharger manuellement (bouton `Code` puis `Download ZIP` )

Dans un second temps: pour lancer la simulation il faut:

- Importer dans **GAMA**. Une foix **GAMA** lancé, aller sur `User models`, `import` et `GAMA project`.
- Le repertoire n'iclus pas les fichiers les plus volumineux:
    * Télécharger les fichiers [Bati_Tissu_MEL_Union](https://partage.imt.fr/index.php/apps/files?dir=/Shared/SIMU_RECONVERT/New%20donn%C3%A9es%20SIG&fileid=539656037)
    * Ajouter les dans le dossier "includes" du projet
- Ya plus qu'a lancer la simulation:
    * Selectionner `RECONVERT`, `models` et `RECONVERT_V3.gaml` dans le menu des modèles
    * Puis sur `RECONVERT` et enfin sur `play` (stopper la simulation permet de revenir aux sources)


## SIMULATION DE RECONVERT

La construction de la simulation s'est faites de façon incrémentale.

### RECONVERT_V1

Cette version correspond à la 1er étape et de base pour la suite et n'a pas vocation à être utilisé
Dans cette première version il n'y a que 2 agents:
-les unités opératives qui déconstruisent les bâtiments
-les bâtiments (stockage,tri,bâtiment à déconstruire) suivant leur couleurs et étant basé sur 1 seul fichier QGIS 
En lançant la simulation dans l'onglet "information" il y a un graphe du taux d'occupation des centres de tri en fonction du temps 


### RECONVERT_V2

Dans cette nouvelle version il y a 5 agents:
-les unités opératives qui déconstruisent les bâtiments et envoie vers les centres de tri/stockage/valorisation
-les centres de stockage (enfouissement) qui ont une forte capacité et dont aucun matériaux ne sort 
-les centres de tri qui permettent de trier et d'envoyer ensuite en centre de valorisation ou de stockage
-les centres de valorisation qui permettent le recyclage des matériaux et donc le point central de cette étude 
-les bâtiments à déconstruire

Chacun de ces 4 bâtiments à son propre fichier QGIS et sa couleur afin de mieux les situer sur la carte finale 
Dans l'onglet information on peut voir le graphe du taux d'occupation des centres de tri et des centres de valorisation en fonction du temps 
La liste et l'ordre de sortie des matériaux est donné par des fichiers CSV 
Enfin un pourcentage de chaque matériaux déconstruit est envoyé à chaque centre. Ce pourcentage est influé par la note que l'on donne à la simulation (ex:Note 0 =pas de valorisation, Note 4 = version idéale beaucoup de valorisation et peu d'enfouissement).


### RECONVERT_V3


## PRENDRE LA MAIN


### CHANGER LE PLAN DES OPERATIV-UNIT


### CHANGER LES NOTES DES CHANTIERS


### PASSER SUR UN NOUVEAU TERRITOIRE


## AUTEURS

Maxence V. sous la suppervision de Guillaume L. Arnaud D. et Emmanuel L.

