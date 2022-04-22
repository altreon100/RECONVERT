# RECONVERT


Le projet Reconvert s'inscrit dans une démarche de recyclage des matériaux lors de la déconstruction des bâtiments. Le but serait de faire une déconstruction sélective des bâtiments et d'organiser des flux de produits et matériaux qui en sont issus pour un recyclage à une échelle locale. Le projet se positionne sur la métropole européenne de Lille (MEL) dans le cadre d'un partenariat entre cette dernière, les chercheurs de l'école IMT Nord Europe et d'acteurs du BTP (Rabot Dutilleul).

Ce projet est découpé en plusieurs thématique (numérique,environnemental,sociétal), ce répertoire git à pour but de rassembler les avancées de la thématique numérique.

# PARTIE NUMERIQUE

Dans le cadre de ce projet, il a été décidé de faire une simulation des différents bâtiments à déconstruire et de voir l'évolution des flux de matériaux au fil de leur déconstruction. Les agents doivent optimiser au mieux leur temps afin de déconstruire (voir reconstruire dans un second temps) les bâtiments le plus efficacement possible. Le simulateur GAMA a été choisi afin d'obtenir une SMA (Simulation Multi Agent) optimisé. Dans cette SMA nous avons plusieurs agents à savoir :

- les bâtiments à déconstruire 
- les zones de stockage/ressourcerie qui permettent aux matériaux récupérés d'être recyclés
- les unités opératives qui permettent la déconstruction des bâtiments

Afin de faire cette simulation, il a été necessaire de récupérer les données SIG(Système d'Information Géographique) de la MEL afin de pouvoir les traiter dans GAMA. Pour cela, il faut télécharger et installer QGIS sur votre PC via ce lien: https://www.qgis.org/fr/site/forusers/download.html.

Ensuite il faut télécharger les données SIG de la France grâce à ce lien :https://bdnb-data.s3.fr-par.scw.cloud/bnb_export.gpkg.zip

Ce dossier nous donne les informations des bâtiments en France classés selon leur année de construction ainsi que d'autre information comme par exemple le type de matériaux pour le toit et les murs. Une fois ouvert sur QGIS, vous pouvez récupérer la zone que vous voulait étudier (ici par exemple la MEL) en créant une couche qui effectue le contour de la zone avant de la couper grâce aux outils de géotraitement. Une fois découper et enregistré sous le format Shape vous pouvez importer les différents fichiers dans le dossier "include" de votre projet GAMA. Vous devez aussi enregistrer un rectangle de la zone à étudier également sous format Shape (ex:bounds.shp).
