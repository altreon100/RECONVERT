


model RECONVERTV4

global {
	file shape_file_buildings <- file("../includes/permis de démolir.shp"); // Fichier shape contenant les bâtiments à déconstruire
	file shape_file_bounds <- file("../includes/Contiurs simple MEL.shp"); //Fichier shape du périmètre de la zone choisi
	file shape_file_tri <- file("../includes/Centre de tri.shp"); //Fichier shape avec les centres de tri
	file shape_file_enfouissement <- file("../includes/Enfouissement.shp"); //Fichier shape avec les zones d'enfouissement
	file shape_file_valo <- file("../includes/Centre de valorisation.shp"); //Fichier shape avec les centres de valorisation
	file shape_file_reemploi <-file("../includes/Réemploi.shp");// Fichier shape avec les centres de réemploi
	file shape_file_deconstruction<-file("../includes/Démolition.shp");// Fichier shape avec les entreprise de déconstruction
	file shape_file_MEL<-file("../includes/Bati_Tissu_MEL_Union.shp");// Fichier shape avec la carte de la MEL
	file ordre_mat <- csv_file("../includes/001ORDER.csv");// Fichier contenant l'ordre de sortie des matériaux
	
	//Fichiers avec le pourcentage de sorti des matériaux en fonction de la note
	file note0<-csv_file("../includes/002NOTE0.csv");
	file note1<-csv_file("../includes/003NOTE1.csv");
	file note2<-csv_file("../includes/004NOTE2.csv");
	file note3<-csv_file("../includes/005NOTE3.csv");
	file note4<-csv_file("../includes/006NOTE4.csv");
	file csv_note<-nil;
	
	file couts<-csv_file("../includes/007COUTS.csv"); // Fichier des coûts en fonction du centre et du matériaux choisi
	file capacity<-csv_file("../includes/009CAPACITY.csv");// Fichier des capacités des entreprises par matériaux par heure et par employé en fonction du code APE
	file tissus<-csv_file("../includes/010tissus.csv"); // Fichier contenant la liste des  quantités de matériaux en fonction du tissus
	file remploi<-csv_file("../includes/011remploi.csv"); // Fichier contenant la liste des entreprises classées "réemploi"
	file csv_tri<-csv_file("../includes/012tri.csv"); //Fichier contenant la liste des entreprises classées "centre de tri"
	file csv_enfouissement<-csv_file("../includes/013enfouissement.csv"); //Fichier contenant la liste des entreprises classées "enfouissement"
	file csv_valorisation<-csv_file("../includes/014valorisation.csv"); //Fichier contenant la liste des entreprises classées "valorisation"
	file csv_demolition<-csv_file("../includes/015demolition.csv"); //Fichier contenant la liste des entreprises de demolition
	file couts_env<-csv_file("../includes/017ENV2.csv"); // Fichier des coûts environnementaux en fonction  du matériaux choisi
	geometry shape <- envelope(shape_file_bounds); //Limite à la zone simulée 
	
	//Variables utilisées pour le monitoring
	float total_capacite<-0.0;// Permet de calculer le taux d'occupation des centres de tri
	float total_capacite2<-0.0; // Permet de calculer le taux d'occupation des centres de valo
	float total_capacite3<-0.0; // Permet de calculer le taux d'occupation des centres de stockage
	float total_capacite4<-0.0; // Permet de calculer le taux d'occupation des centres de reemploi
	float init_tot_capacite<-0.0;
	float init_tot_capacite2<-0.0;
	float init_tot_capacite3<-0.0;
	float init_tot_capacite4<-0.0;
	float som_cout<-0.0; // Calcul le coûts en € de la déconstruction des bâtiments
	float som_env_eau<-0.0; // Calcul le coûts en eau  de la déconstruction des bâtiments 
	float som_env_co2<-0.0; // Calcul le coûts en CO2  de la déconstruction des bâtiments 
	float som_env_energie<-0.0; // Calcul le coûts en energie  de la déconstruction des bâtiments
	float som_reemploi_site<-0.0;
	float som_reemploi_hors_site<-0.0;
	float som_reutilisation_site<-0.0;
	float som_reutilisation_hors_site<-0.0;
	float som_envoi_tri<-0.0;
	float som_valo_matiere;
	float som_valo_energetique<-0.0;
	float som_REP<-0.0;
	float som_stockage_ISDI<-0.0;
	float som_stockage_ISDND<-0.0;
	float som_stockage_ISDD<-0.0;
	float som_autre_elimination<-0.0;
	float tot_cout<-0.0; 
	float tot_env_eau<-0.0; 
	float tot_env_co2<-0.0;  
	float tot_env_energie<-0.0; 
	float tot_reemploi_site<-0.0;
	float tot_reemploi_hors_site<-0.0;
	float tot_reutilisation_site<-0.0;
	float tot_reutilisation_hors_site<-0.0;
	float tot_envoi_tri<-0.0;
	float tot_valo_matiere;
	float tot_valo_energetique<-0.0;
	float tot_REP<-0.0;
	float tot_stockage_ISDI<-0.0;
	float tot_stockage_ISDND<-0.0;
	float tot_stockage_ISDD<-0.0;
	float tot_autre_elimination<-0.0;
	int id<-0; //l'id de tout les bâtiment
	int nb_building<-0; // calcul en temps réel le nombre de bâtiment qui reste à déconstruire 
	int nb_contrat<-0; // calcul en temps réel le nombre de contrat qui reste  
	int nb_stockage<-0; // calcul le nombre de centre de stockage
	int nb_valo<-0;//calcul le nombre de centre de valo
	int nb_tri<-0; //calcul le nombre de centre de tri
	int nb_reemploi<-0;// calcul le nombre de centre de reemploi
	int nb_demolition<-0;// calcul le nombre d'entreprise de déconstruction
	int nb_groupe<-0;
	int note<-0;
	float tot_materiaux<-0.0;
	
	//Matrice résultante du classement des matériaux
	matrix<float> note_ordre<-nil; 
	matrix<float> cout_ordre<-nil;
	matrix<float> env_ordre<-nil;
	matrix<string> capacite_ordre<-nil;
	matrix<float> tissus_ordre<-nil;
	matrix<string> enfouissement_ordre<-nil;
	matrix<string> valorisation_ordre<-nil;
	matrix<string> reemploi_ordre<-nil;
	matrix<string> tri_ordre<-nil;
	matrix<string> demolition_ordre<-nil;
	
	//VARIABLE POUVANT ETRE MODIFIE
	float step <- 0.5#day; //correspond au temps entre chaque cycle
	float pourcentage_tri<-0.7; // Pourcentage du nombre de tonne envoyé du centre de tri vers le centre de stockage/valorisation
	float decay_building<-60.0; //nombre de tonne de matériaux déconstruit à chaque step (influ sur la vitesse de la déconstruction et sur le taux d'occupation des centres)
	int nb_heure<-4; // Règle le nombre d'heure de travail éffectué par step (ici step=0.5 day donc 4h de travail)
	int nb_ouvrier<-20;
	init {
		// On récupère les tableau  et on enlève les "" propre aux fichiers CSV
		matrix<string> matrix_ordre <- matrix(ordre_mat); 
		
		loop i from: 0 to: matrix_ordre.rows -1{
			matrix_ordre[0,i]<-copy_between(matrix_ordre[0,i],1,length(matrix_ordre[0,i]));
			matrix_ordre[2,i]<-copy_between(matrix_ordre[2,i],0,1);
		}
		
		if(note=0){ // choix du fichier du note à charger
			csv_note<-note0;
		}
		else if(note=1){
			csv_note<-note1;
		}
		else if(note=2){
			csv_note<-note2;
		}
		else if(note=3){
			csv_note<-note3;
		}else{
			csv_note<-note4;
		}
		matrix<string> copy_mat<-copy(matrix_ordre);
		matrix<string> matrix_note<-matrix(csv_note);
		
		loop i from: 0 to: matrix_note.rows -1{
			matrix_note[0,i]<-copy_between(matrix_note[0,i],1,length(matrix_note[0,i]));
			matrix_note[13,i]<-copy_between(matrix_note[13,i],0,length(matrix_note[13,i])-1);
		}
		
		matrix<string> matrix_cout<-matrix(couts);
		
		loop i from: 0 to: matrix_cout.rows -1{
			matrix_cout[0,i]<-copy_between(matrix_cout[0,i],1,length(matrix_cout[0,i]));
			matrix_cout[5,i]<-copy_between(matrix_cout[5,i],0,length(matrix_cout[5,i])-1);
		}
		
		matrix<string> matrix_env<-matrix(couts_env);
		
		
		loop i from: 0 to: matrix_env.rows -1{
			matrix_env[0,i]<-copy_between(matrix_env[0,i],1,length(matrix_env[0,i]));
			matrix_env[4,i]<-copy_between(matrix_env[4,i],0,length(matrix_env[4,i])-1);
		}
		/*loop i from: 0 to: matrix_env.rows - 1 {
			loop j from: 0 to: matrix_env.columns - 1 {
				write "The element at row: " +i + " and column: " + j + " of the matrix is: " + matrix_env[j,i];				
			}
		}*/
		matrix<string> matrix_tissus<-matrix(tissus);
		
		loop i from: 0 to: matrix_tissus.rows -1{
			matrix_tissus[0,i]<-copy_between(matrix_tissus[0,i],1,length(matrix_tissus[0,i]));
			matrix_tissus[11,i]<-copy_between(matrix_tissus[11,i],0,length(matrix_tissus[11,i])-1);
		}
		
		matrix<string> matrix_reemploi<-matrix(remploi);
		matrix<string>matrix_tri<-matrix(csv_tri);
		matrix<string>matrix_enfouissement<-matrix(csv_enfouissement);
		matrix<string>matrix_valorisation<-matrix(csv_valorisation);
		matrix<string>matrix_demolition<-matrix(csv_demolition);
		
		
		loop i from: 0 to: matrix_valorisation.rows -1{
			matrix_valorisation[0,i]<-copy_between(matrix_valorisation[0,i],1,length(matrix_valorisation[0,i]));
			matrix_valorisation[45,i]<-copy_between(matrix_valorisation[45,i],0,length(matrix_valorisation[45,i])-1);
		}
		
		
		loop i from: 0 to: matrix_enfouissement.rows -1{
			matrix_enfouissement[0,i]<-copy_between(matrix_enfouissement[0,i],1,length(matrix_enfouissement[0,i]));
			matrix_enfouissement[45,i]<-copy_between(matrix_enfouissement[45,i],0,length(matrix_enfouissement[45,i])-1);
		}
		loop i from: 0 to: matrix_demolition.rows -1{
			matrix_demolition[0,i]<-copy_between(matrix_demolition[0,i],1,length(matrix_demolition[0,i]));
			matrix_demolition[45,i]<-copy_between(matrix_demolition[45,i],0,length(matrix_demolition[45,i])-1);
		}
		
		matrix<string>matrix_capacite<-matrix(capacity);
		loop i from: 0 to: matrix_capacite.rows -1{
			matrix_capacite[0,i]<-copy_between(matrix_capacite[0,i],1,length(matrix_capacite[0,i]));
			matrix_capacite[39,i]<-copy_between(matrix_capacite[39,i],0,length(matrix_capacite[39,i])-1);
		}
		
		point size<-point([1,matrix_ordre.rows]); 
		int nb<-0;
		loop i from: 1 to: 8{// On ordonne le fichier par ordre de sorti
			loop j from: 0 to: matrix_ordre.rows -1{
				if(copy_mat[2,j] = string(i)){
					matrix_ordre[0,nb]<-copy_mat[0,j];
					matrix_ordre[1,nb]<-copy_mat[1,j];
					matrix_ordre[2,nb]<-copy_mat[2,j];
					nb<-nb+1;
				}
			}	
		}
		matrix_note<-transpose(matrix_note);
		point size2<-point([matrix_note.columns,matrix_note.rows-2]);
		note_ordre<-matrix_with(size2,0.0);
		capacite_ordre<-copy(matrix_capacite);
		enfouissement_ordre<-copy(matrix_enfouissement);
		valorisation_ordre<-copy(matrix_valorisation);
		reemploi_ordre<-copy(matrix_reemploi);
		demolition_ordre<-copy(matrix_demolition);
		tri_ordre<-copy(matrix_tri);
		matrix_tissus<-transpose(matrix_tissus);
		tissus_ordre<-matrix_with(point(matrix_tissus.columns,matrix_tissus.rows-2),0.0);

		loop i from: 0 to: matrix_note.columns-1{ // On ordonne en fonction de l'ordre de sorti les pourcentages du tableau et les capacités
				loop j from:0 to:matrix_note.columns-1{
					if(matrix_note[i,1]=matrix_ordre[1,j]){
						loop k from:2 to: matrix_note.rows-2{
							note_ordre[j,k-2]<-float(matrix_note[i,k]);
						}
						
						loop l from:0 to: matrix_capacite.rows-1{
							
							capacite_ordre[j+2,l]<-matrix_capacite[i+2,l];
							
						}
						loop m from:0 to: matrix_tissus.rows-1{
							
							tissus_ordre[j,m-2]<-float(matrix_tissus[i,m]);
							
						}
						loop n from:0 to: matrix_enfouissement.rows-1{
							
							enfouissement_ordre[j+8,n]<-matrix_enfouissement[i+8,n];
							
						}
						loop o from:0 to: matrix_valorisation.rows-1{
							
							valorisation_ordre[j+8,o]<-matrix_valorisation[i+8,o];
							
						}
						loop p from:0 to: matrix_reemploi.rows-1{
							
							reemploi_ordre[j+8,p]<-matrix_reemploi[i+8,p];
							
						}
						loop q from:0 to: matrix_tri.rows-1{
							
							tri_ordre[j+8,q]<-matrix_tri[i+8,q];
							
						}
						loop r from:0 to: matrix_demolition.rows-1{
							
							demolition_ordre[j+8,r]<-matrix_demolition[i+8,r];
							
						}
					}	
				}
		
		}
		note_ordre<-transpose(note_ordre);
		tissus_ordre<-transpose(tissus_ordre);
		
		matrix_cout<-transpose(matrix_cout);
		point size3<-point([matrix_cout.columns,4]);
		cout_ordre<-matrix_with(size3,0.0);
		matrix_env<-transpose(matrix_env);
		env_ordre<-matrix_with(point([matrix_env.columns,3]),0.0);
		loop i from: 0 to: matrix_cout.columns-1{ // Idem pour le tableau des coûts
				loop j from:0 to:matrix_cout.columns-1{
					if(matrix_cout[i,1]=matrix_ordre[1,j]){
						loop k from:2 to: matrix_cout.rows-1{
							cout_ordre[j,k-2]<-float(matrix_cout[i,k]);
						}
						loop l from:2 to: matrix_env.rows-1{
							env_ordre[j,l-2]<-float(matrix_env[i,l]);
						}
					}	
				}
				
		}
		cout_ordre<-transpose(cout_ordre);
		env_ordre<-transpose(env_ordre);
		
		
		/*create building from:shape_file_MEL{
			
		}*/
		create enfouissement from:shape_file_enfouissement{ // creation des centres de stockages avec une forte capacité
					capacite<-3000.0;	
					total_capacite3<-total_capacite3+capacite;
					init_tot_capacite3<-init_tot_capacite3+capacite;
					nb_stockage<-nb_stockage+1;
					stockage_ISDI<-list_with(note_ordre.rows,0.0);
					stockage_ISDND<-list_with(note_ordre.rows,0.0);
					stockage_ISDD<-list_with(note_ordre.rows,0.0);
					autre_elimination<-list_with(note_ordre.rows,0.0);
					info_acteur<-list_with(matrix_enfouissement.columns,"0");
					info_capacite<-list_with(capacite_ordre.columns-2,0.0);
					loop i from:0 to:enfouissement_ordre.columns-1{ // Pour chaque centre d'enfouissement on récupère les infos de la matrice
				info_acteur[i]<-enfouissement_ordre[i,nb_stockage-1];
			}
			id_acteur<-int(info_acteur[0]);
			nb_employe<-int(info_acteur[2]);
			code_APE<-info_acteur[3];
			loop i from:0 to:capacite_ordre.rows-1{ // On récupère la bonne ligne de la matrice capacité en regardant son code APE
				if(capacite_ordre[1,i] contains (code_APE)){
					loop j from:2 to: capacite_ordre.columns-1{
						info_capacite[j-2]<-float(capacite_ordre[j,i]);
					}
				}
			}
						
		}
		create valorisation from: shape_file_valo{ //création des centres de valorisation
			capacite<-60.0;
			total_capacite2<-total_capacite2+capacite;
			init_tot_capacite2<-init_tot_capacite2+capacite;
			nb_valo<-nb_valo+1;
			valo_matiere<-list_with(note_ordre.rows,0.0);
			valo_energetique<-list_with(note_ordre.rows,0.0);
			REP<-list_with(note_ordre.rows,0.0);
			info_acteur<-list_with(matrix_valorisation.columns,"0");
			info_capacite<-list_with(capacite_ordre.columns-2,0.0);
			loop i from:0 to:valorisation_ordre.columns-1{ // Pour chaque valorisation on récupère les infos de la matrice
				info_acteur[i]<-valorisation_ordre[i,nb_valo-1];
			}
			id_acteur<-int(info_acteur[0]);
			nb_employe<-int(info_acteur[2]);
			code_APE<-info_acteur[3];
			loop i from:0 to:capacite_ordre.rows-1{ // On récupère la bonne ligne de la matrice capacité en regardant son code APE
				if(capacite_ordre[1,i] contains (code_APE)){
					loop j from:2 to: capacite_ordre.columns-1{
						info_capacite[j-2]<-float(capacite_ordre[j,i]);
					}
				}
			}
					
		}
		
		create tri from:shape_file_tri{ // creation des centres de tri
			capacite<-600.0;
			total_capacite<-total_capacite+capacite;
			init_tot_capacite<-init_tot_capacite+capacite;
			nb_tri<-nb_tri+1;
			envoi_tri<-list_with(note_ordre.rows,0.0);
			list_enfouissement<-list(enfouissement);
			list_valo<-list(valorisation);
			distance_enfouissement<-list_with(length(enfouissement),0.0);
			distance_valo<-list_with(length(valorisation),0.0);
			loop i from:0 to:length(enfouissement)-1{   // On calcule la distance entre le centre et tous les centres d'enfouissement existant
				ask enfouissement at i{
					myself.distance_enfouissement[i]<-self distance_to myself;
				}
			}
			loop i from:0 to:length(list_valo)-1{   // On calcule la distance entre l'agent et tous les centres de valorisation existant
				ask list_valo at i{
					myself.distance_valo[i]<-self distance_to myself;
				}
			}
			
			tmp_dist<-copy(distance_enfouissement);
			tmp_centre<-copy(list(enfouissement));
			distance_enfouissement<-distance_enfouissement sort_by (each); // On classe par ordre croissant les distances
			loop i from:0 to: length(list_enfouissement)-1{ // On prend le centre de stockage le plus proche
				loop j from:0 to: length(list_enfouissement)-1{
					if(distance_enfouissement[i]=tmp_dist[j]){
						list_enfouissement[i]<-enfouissement(tmp_centre[j]);
					}
				}				
			}
			tmp_dist<-copy(distance_valo);
			tmp_centre<-copy(list_valo);
			distance_valo<-distance_valo sort_by (each); // On classe par ordre croissant les distances
			loop i from:0 to: length(list_valo)-1{ // On classe  la liste des centre de valorisation par ordre croissant de distance
				loop j from:0 to: length(list_valo)-1{
					if(distance_valo[i]=tmp_dist[j]){
						list_valo[i]<-valorisation(tmp_centre[j]);
					}
				}
			}
			centre_val<-list_valo[0];
			centre_enfouissement<-list_enfouissement[0];
			info_acteur<-list_with(matrix_tri.columns,"0");
			info_capacite<-list_with(capacite_ordre.columns-2,0.0);
			loop i from:0 to:tri_ordre.columns-1{ // Pour chaque centre de tri on récupère les infos de la matrice
				info_acteur[i]<-tri_ordre[i,nb_tri-1];
			}
			id_acteur<-int(info_acteur[0]);
			nb_employe<-int(info_acteur[2]);
			code_APE<-info_acteur[3];
			loop i from:0 to:capacite_ordre.rows-1{ // On récupère la bonne ligne de la matrice capacité en regardant son code APE
				if(capacite_ordre[1,i] contains (code_APE)){
					loop j from:2 to: capacite_ordre.columns-1{
						info_capacite[j-2]<-float(capacite_ordre[j,i]);
					}
				}
			}
			
		}
		create reemploi from:shape_file_reemploi{ // création des centres de réemploi
			capacite<-100.0;
			total_capacite4<-total_capacite4+capacite;
			init_tot_capacite4<-init_tot_capacite4+capacite;
			reemploi_site<-list_with(note_ordre.rows,0.0);
			reemploi_hors_site<-list_with(note_ordre.rows,0.0);
			reutilisation_site<-list_with(note_ordre.rows,0.0);
			reutilisation_hors_site<-list_with(note_ordre.rows,0.0);
			nb_reemploi<-nb_reemploi+1;
			info_acteur<-list_with(matrix_reemploi.columns,"0");
			info_capacite<-list_with(capacite_ordre.columns-2,0.0);
			loop i from:0 to:reemploi_ordre.columns-1{ // Pour chaque reemploi on récupère les infos de la matrice
				info_acteur[i]<-reemploi_ordre[i,nb_reemploi-1];
			}
			id_acteur<-int(info_acteur[0]);
			nb_employe<-int(info_acteur[2]);
			code_APE<-info_acteur[3];
			loop i from:0 to:capacite_ordre.rows-1{ // On récupère la bonne ligne de la matrice capacité en regardant son code APE
				if(capacite_ordre[1,i] contains (code_APE)){
					loop j from:2 to: capacite_ordre.columns-1{
						info_capacite[j-2]<-float(capacite_ordre[j,i]);
					}
				}
			}
		}
		
		create entreprise_deconstruction from:shape_file_deconstruction{ // création des entreprises de déconstruction
			materiaux<-matrix_with(size,0.0); 
			nb_demolition<-nb_demolition+1;
			info_acteur<-list_with(matrix_demolition.columns,"0");
			info_capacite<-list_with(capacite_ordre.columns-2,0.0);
			loop i from:0 to:demolition_ordre.columns-1{ // Pour chaque valorisation on récupère les infos de la matrice
				info_acteur[i]<-demolition_ordre[i,nb_demolition-1];
			}
			id_acteur<-int(info_acteur[0]);
			nb_employe<-int(info_acteur[2]);
			code_APE<-info_acteur[3];
			loop i from:0 to:capacite_ordre.rows-1{ // On récupère la bonne ligne de la matrice capacité en regardant son code APE
				if(capacite_ordre[1,i] contains (code_APE)){
					loop j from:2 to: capacite_ordre.columns-1{
						info_capacite[j-2]<-float(capacite_ordre[j,i]);
					}
				}
			}
		/*if(nb_employe mod nb_ouvrier=0){ // on crée des groupes d'ouvrier pour travailler sur les batiment
				nb_groupe<-int(nb_employe/nb_ouvrier);
				create people number:nb_groupe{
				nb_groupe<-nb_groupe+1;
				location <- any_location_in (entreprise_deconstruction[nb_demolition-1]);
				entreprise_demolition<-entreprise_deconstruction[nb_demolition-1];
				nb_employe<-nb_ouvrier;
				}
			}
			else{
				nb_groupe<-int(nb_employe/nb_ouvrier);
				create people number:nb_groupe{
				nb_groupe<-nb_groupe+1;
				location <- any_location_in (entreprise_deconstruction[nb_demolition-1]);
				entreprise_demolition<-entreprise_deconstruction[nb_demolition-1];
				nb_employe<-nb_ouvrier;
				}
				create people number:1{
				nb_groupe<-nb_groupe+1;
				location <- any_location_in (entreprise_deconstruction[nb_demolition-1]);
				entreprise_demolition<-entreprise_deconstruction[nb_demolition-1];
				nb_employe<-myself.nb_employe mod nb_ouvrier;
				}
			}*/
			
			
		}
		create deconstruction  from:shape_file_buildings with:[surface::float(read("Surfaces"))]{ // création des bâtiments à déconstruire
			id_building<-id+1;
			id<-id+1;
			nb_building<-nb_building+1;
			nb_contrat<-nb_contrat+1;
			materiaux<-matrix_with(size,0.0);
				loop i from:0 to:materiaux.rows-1{ // On affecte pour chaque matériaux et pour chaque bâtiment un nombre de tonne en fonction de sq surface
					materiaux[0,i]<-surface*tissus_ordre[9,i];
					tot_materiaux<-tot_materiaux+materiaux[0,i];
				}
		}
		create people number:1{
				location <- any_location_in (entreprise_deconstruction[0]);
				entreprise_demolition<-entreprise_deconstruction[0];
				nb_employe<-20;
				}
		
		
	}
	
}

species building { 
	rgb color<-#gray;
	float mat_total<-0.0; // Calcul du total de matériaux restant 
	float capacite; // Pour les centre de tri correspond à la capacité maximale du centre
	
	list<string> info_acteur; // Liste contenant les informations de l'acteur (code APE,ID,matériaux traités,...)
	list<float>info_capacite;// Liste contenant les capacités de l'acteur pour chaque matériaux
	int id_building; // id du batiment
	int id_acteur; // Correspond à l'ID de l'acteur donné dans les fichiers CSV
	int nb_employe<-0; // Correspond aux nombres d'employés salariés de l'acteur
	string code_APE<-nil; // Correspond au Code APE de l'acteur
	
	reflex die when: color=#black{  // Si le bâtiment a finit d'être déconstruit on le tue
		do die;
	}
	aspect base {  
		draw shape color: color ;
	}
}

species enfouissement parent:building {  // les centres de stockage sont passifs il n'y a pas de sorti
	list<float> stockage_ISDI<-nil;
	list<float> stockage_ISDND<-nil;
	list<float> stockage_ISDD<-nil;
	list<float> autre_elimination<-nil;
	rgb color<-#green;
	
}


species tri parent:building {  // les centres de tri vont disparaître une certaine quantité par step
	rgb color<-#red;
	enfouissement centre_stockage<-nil;
	list<float> envoi_tri<-nil;
	list<float>distance_enfouissement<-nil;
	list<float>distance_valo<-nil;
	list<valorisation>list_valo<-nil;
	list<enfouissement>list_enfouissement<-nil;
	list<float> tmp_dist<-nil;
	list<building> tmp_centre<-nil;
	enfouissement centre_enfouissement<-nil;
	valorisation centre_val<-nil;
	bool find_new_centre_valo<-false;
	bool find_new_enfouissement<-false;
	reflex decay{
		loop i from:0 to:length(envoi_tri)-1{
			find_new_centre_valo<-false;
			find_new_enfouissement<-false;
			if(envoi_tri[i]>= info_capacite[i]*nb_heure and nb_employe!=0){
				nb_employe<-nb_employe-1;
				if(centre_enfouissement.capacite>=pourcentage_tri*info_capacite[i]*nb_heure and centre_enfouissement.info_acteur[i+8]="1"){
					
					centre_enfouissement.stockage_ISDI[i]<-centre_enfouissement.stockage_ISDI[i]+(pourcentage_tri*info_capacite[i]*nb_heure)/4.0;
					centre_enfouissement.stockage_ISDND[i]<-centre_enfouissement.stockage_ISDND[i]+(pourcentage_tri*info_capacite[i]*nb_heure)/4.0;
					centre_enfouissement.stockage_ISDD[i]<-centre_enfouissement.stockage_ISDD[i]+(pourcentage_tri*info_capacite[i]*nb_heure)/4.0;
					centre_enfouissement.autre_elimination[i]<-centre_enfouissement.autre_elimination[i]+(pourcentage_tri*info_capacite[i]*nb_heure)/4.0;
					
					som_stockage_ISDI<-som_stockage_ISDI+(pourcentage_tri*info_capacite[i]*nb_heure)/4.0;
					som_stockage_ISDND<-som_stockage_ISDND+(pourcentage_tri*info_capacite[i]*nb_heure)/4.0;
					som_stockage_ISDI<-som_stockage_ISDD+(pourcentage_tri*info_capacite[i]*nb_heure)/4.0;
					som_autre_elimination<-som_autre_elimination+(pourcentage_tri*info_capacite[i]*nb_heure)/4.0;
					tot_stockage_ISDI<-tot_stockage_ISDI+(pourcentage_tri*info_capacite[i]*nb_heure)/4.0;
					tot_stockage_ISDND<-tot_stockage_ISDND+(pourcentage_tri*info_capacite[i]*nb_heure)/4.0;
					tot_stockage_ISDI<-tot_stockage_ISDD+(pourcentage_tri*info_capacite[i]*nb_heure)/4.0;
					tot_autre_elimination<-tot_autre_elimination+(pourcentage_tri*info_capacite[i]*nb_heure)/4.0;
					centre_enfouissement.capacite<-centre_enfouissement.capacite-pourcentage_tri*info_capacite[i]*nb_heure;
					total_capacite3<-total_capacite3-pourcentage_tri*info_capacite[i]*nb_heure;
					som_cout<-som_cout+cout_ordre[2,i]*pourcentage_tri*info_capacite[i]*nb_heure;
					som_env_eau<-som_env_eau-env_ordre[0,i]*pourcentage_tri*info_capacite[i]*nb_heure;
					som_env_energie<-som_env_energie-env_ordre[1,i]*pourcentage_tri*info_capacite[i]*nb_heure;
					som_env_co2<-som_env_co2-env_ordre[2,i]*pourcentage_tri*info_capacite[i]*nb_heure;
					tot_cout<-tot_cout+cout_ordre[2,i]*pourcentage_tri*info_capacite[i]*nb_heure;
					tot_env_eau<-tot_env_eau-env_ordre[0,i]*pourcentage_tri*info_capacite[i]*nb_heure;
					tot_env_energie<-tot_env_energie-env_ordre[1,i]*pourcentage_tri*info_capacite[i]*nb_heure;
					tot_env_co2<-tot_env_co2-env_ordre[2,i]*pourcentage_tri*info_capacite[i]*nb_heure;
					}
					else{ // Si le centre d'enfouissement le plus proche n'a plus la capacité on va chercher le centre d'enfouissement le plus proche ayant la capacité nécessaire
						loop j from:0 to:length(list_enfouissement)-1{
							if(list_enfouissement[j].capacite>=pourcentage_tri*info_capacite[i]*nb_heure and list_enfouissement[j].info_acteur[i+8]="1" and find_new_enfouissement=false){
			
								list_enfouissement[j].stockage_ISDI[i]<-list_enfouissement[j].stockage_ISDI[i]+(pourcentage_tri*info_capacite[i]*nb_heure)/4.0;
								list_enfouissement[j].stockage_ISDND[i]<-list_enfouissement[j].stockage_ISDND[i]+(pourcentage_tri*info_capacite[i]*nb_heure)/4.0;
								list_enfouissement[j].stockage_ISDD[i]<-list_enfouissement[j].stockage_ISDD[i]+(pourcentage_tri*info_capacite[i]*nb_heure)/4.0;
								list_enfouissement[j].autre_elimination[i]<-list_enfouissement[j].autre_elimination[i]+(pourcentage_tri*info_capacite[i]*nb_heure)/4.0;
								
								som_stockage_ISDI<-som_stockage_ISDI+(pourcentage_tri*info_capacite[i]*nb_heure)/4.0;
								som_stockage_ISDND<-som_stockage_ISDND+(pourcentage_tri*info_capacite[i]*nb_heure)/4.0;
								som_stockage_ISDI<-som_stockage_ISDD+(pourcentage_tri*info_capacite[i]*nb_heure)/4.0;
								som_autre_elimination<-som_autre_elimination+(pourcentage_tri*info_capacite[i]*nb_heure)/4.0;
								tot_stockage_ISDI<-tot_stockage_ISDI+(pourcentage_tri*info_capacite[i]*nb_heure)/4.0;
								tot_stockage_ISDND<-tot_stockage_ISDND+(pourcentage_tri*info_capacite[i]*nb_heure)/4.0;
								tot_stockage_ISDI<-tot_stockage_ISDD+(pourcentage_tri*info_capacite[i]*nb_heure)/4.0;
								tot_autre_elimination<-tot_autre_elimination+(pourcentage_tri*info_capacite[i]*nb_heure)/4.0;
								list_enfouissement[j].capacite<-list_enfouissement[j].capacite-pourcentage_tri*info_capacite[i]*nb_heure;
								total_capacite<-total_capacite-pourcentage_tri*info_capacite[i]*nb_heure;
								som_cout<-som_cout+cout_ordre[0,i]*pourcentage_tri*info_capacite[i]*nb_heure;
								som_env_eau<-som_env_eau-env_ordre[0,i]*pourcentage_tri*info_capacite[i]*nb_heure;
								som_env_energie<-som_env_energie-env_ordre[1,i]*pourcentage_tri*info_capacite[i]*nb_heure;
								som_env_co2<-som_env_co2-env_ordre[2,i]*pourcentage_tri*info_capacite[i]*nb_heure;
								tot_cout<-tot_cout+cout_ordre[2,i]*pourcentage_tri*info_capacite[i]*nb_heure;
								tot_env_eau<-tot_env_eau-env_ordre[0,i]*pourcentage_tri*info_capacite[i]*nb_heure;
								tot_env_energie<-tot_env_energie-env_ordre[1,i]*pourcentage_tri*info_capacite[i]*nb_heure;
								tot_env_co2<-tot_env_co2-env_ordre[2,i]*pourcentage_tri*info_capacite[i]*nb_heure;
								find_new_enfouissement<-true;
							}
						}
					}
				
				if(centre_val.capacite>=(1-pourcentage_tri)*info_capacite[i]*nb_heure and centre_val.info_acteur[i+8]="1"){
					
					centre_val.valo_matiere[i]<-centre_val.valo_matiere[i]+((1-pourcentage_tri)*info_capacite[i]*nb_heure)/3.0;
					centre_val.valo_energetique[i]<-centre_val.valo_energetique[i]+((1-pourcentage_tri)*info_capacite[i]*nb_heure)/3.0;
					centre_val.REP[i]<-centre_val.REP[i]+((1-pourcentage_tri)*info_capacite[i]*nb_heure)/3.0;
						
					som_valo_matiere<-som_valo_matiere+((1-pourcentage_tri)*info_capacite[i]*nb_heure)/3.0;
					som_valo_energetique<-som_valo_energetique+((1-pourcentage_tri)*info_capacite[i]*nb_heure)/3.0;
					som_REP<-som_REP+((1-pourcentage_tri)*info_capacite[i]*nb_heure)/3.0;
					tot_valo_matiere<-tot_valo_matiere+((1-pourcentage_tri)*info_capacite[i]*nb_heure)/3.0;
					tot_valo_energetique<-tot_valo_energetique+((1-pourcentage_tri)*info_capacite[i]*nb_heure)/3.0;
					tot_REP<-tot_REP+((1-pourcentage_tri)*info_capacite[i]*nb_heure)/3.0;
					centre_val.capacite<-centre_val.capacite-(1-pourcentage_tri)*info_capacite[i]*nb_heure;
					total_capacite2<-total_capacite2-(1-pourcentage_tri)*info_capacite[i]*nb_heure;
					som_cout<-som_cout+cout_ordre[3,i]*(1-pourcentage_tri)*info_capacite[i]*nb_heure;
					som_env_eau<-som_env_eau+env_ordre[0,i]*(1-pourcentage_tri)*info_capacite[i]*nb_heure;
					som_env_energie<-som_env_energie+env_ordre[1,i]*(1-pourcentage_tri)*info_capacite[i]*nb_heure;
					som_env_co2<-som_env_co2+env_ordre[2,i]*(1-pourcentage_tri)*info_capacite[i]*nb_heure;
					tot_cout<-tot_cout+cout_ordre[3,i]*(1-pourcentage_tri)*info_capacite[i]*nb_heure;
					tot_env_eau<-tot_env_eau+env_ordre[0,i]*(1-pourcentage_tri)*info_capacite[i]*nb_heure;
					tot_env_energie<-tot_env_energie+env_ordre[1,i]*(1-pourcentage_tri)*info_capacite[i]*nb_heure;
					tot_env_co2<-tot_env_co2+env_ordre[2,i]*(1-pourcentage_tri)*info_capacite[i]*nb_heure;
				}
				else{ 
						loop j from:0 to:length(list_valo)-1{
							if(list_valo[j].capacite>=(1-pourcentage_tri)*info_capacite[i]*nb_heure and list_valo[j].info_acteur[i+8]="1" and find_new_centre_valo=false){
								
								list_valo[j].valo_matiere[i]<-list_valo[j].valo_matiere[i]+((1-pourcentage_tri)*info_capacite[i]*nb_heure)/3.0;
								list_valo[j].valo_energetique[i]<-list_valo[j].valo_energetique[i]+((1-pourcentage_tri)*info_capacite[i]*nb_heure)/3.0;
								list_valo[j].REP[i]<-list_valo[j].REP[i]+((1-pourcentage_tri)*info_capacite[i]*nb_heure)/3.0;
								
								tot_valo_matiere<-tot_valo_matiere+((1-pourcentage_tri)*info_capacite[i]*nb_heure)/3.0;
								tot_valo_energetique<-tot_valo_energetique+((1-pourcentage_tri)*info_capacite[i]*nb_heure)/3.0;
								tot_REP<-tot_REP+((1-pourcentage_tri)*info_capacite[i]*nb_heure)/3.0;
								som_valo_matiere<-som_valo_matiere+((1-pourcentage_tri)*info_capacite[i]*nb_heure)/3.0;
								som_valo_energetique<-som_valo_energetique+((1-pourcentage_tri)*info_capacite[i]*nb_heure)/3.0;
								som_REP<-som_REP+((1-pourcentage_tri)*info_capacite[i]*nb_heure)/3.0;
								list_valo[j].capacite<-list_valo[j].capacite-(1-pourcentage_tri)*info_capacite[i]*nb_heure;
								total_capacite2<-total_capacite2-(1-pourcentage_tri)*info_capacite[i]*nb_heure;
								som_cout<-som_cout+cout_ordre[3,i]*(1-pourcentage_tri)*info_capacite[i]*nb_heure;
								som_env_eau<-som_env_eau+env_ordre[0,i]*(1-pourcentage_tri)*info_capacite[i]*nb_heure;
								som_env_energie<-som_env_energie+env_ordre[1,i]*(1-pourcentage_tri)*info_capacite[i]*nb_heure;
								som_env_co2<-som_env_co2+env_ordre[2,i]*(1-pourcentage_tri)*info_capacite[i]*nb_heure;
								tot_cout<-tot_cout+cout_ordre[3,i]*(1-pourcentage_tri)*info_capacite[i]*nb_heure;
								tot_env_eau<-tot_env_eau+env_ordre[0,i]*(1-pourcentage_tri)*info_capacite[i]*nb_heure;
								tot_env_energie<-tot_env_energie+env_ordre[1,i]*(1-pourcentage_tri)*info_capacite[i]*nb_heure;
								tot_env_co2<-tot_env_co2+env_ordre[2,i]*(1-pourcentage_tri)*info_capacite[i]*nb_heure;
								find_new_centre_valo<-true;
							}
						}
					}
				envoi_tri[i]<-envoi_tri[i]-info_capacite[i]*nb_heure;
				capacite<-capacite+info_capacite[i]*nb_heure;
				total_capacite<-total_capacite+info_capacite[i]*nb_heure;
			}
			else if(envoi_tri[i]>0.0 and nb_employe!=0){
				nb_employe<-nb_employe-1;
				if(centre_enfouissement.capacite>=pourcentage_tri*envoi_tri[i] and centre_enfouissement.info_acteur[i+8]="1"){
	
					centre_enfouissement.stockage_ISDI[i]<-centre_enfouissement.stockage_ISDI[i]+(pourcentage_tri*envoi_tri[i])/4.0;
					centre_enfouissement.stockage_ISDND[i]<-centre_enfouissement.stockage_ISDND[i]+(pourcentage_tri*envoi_tri[i])/4.0;
					centre_enfouissement.stockage_ISDD[i]<-centre_enfouissement.stockage_ISDD[i]+(pourcentage_tri*envoi_tri[i])/4.0;
					centre_enfouissement.autre_elimination[i]<-centre_enfouissement.autre_elimination[i]+(pourcentage_tri*envoi_tri[i])/4.0;
					
					som_stockage_ISDI<-som_stockage_ISDI+(pourcentage_tri*envoi_tri[i])/4.0;
					som_stockage_ISDND<-som_stockage_ISDND+(pourcentage_tri*envoi_tri[i])/4.0;
					som_stockage_ISDI<-som_stockage_ISDD+(pourcentage_tri*envoi_tri[i])/4.0;
					som_autre_elimination<-som_autre_elimination+(pourcentage_tri*envoi_tri[i])/4.0;
					tot_stockage_ISDI<-tot_stockage_ISDI+(pourcentage_tri*envoi_tri[i])/4.0;
					tot_stockage_ISDND<-tot_stockage_ISDND+(pourcentage_tri*envoi_tri[i])/4.0;
					tot_stockage_ISDI<-tot_stockage_ISDD+(pourcentage_tri*envoi_tri[i])/4.0;
					tot_autre_elimination<-tot_autre_elimination+(pourcentage_tri*envoi_tri[i])/4.0;
					centre_enfouissement.capacite<-centre_enfouissement.capacite-pourcentage_tri*envoi_tri[i];
					total_capacite3<-total_capacite3-pourcentage_tri*envoi_tri[i];
					som_cout<-som_cout+cout_ordre[2,i]*pourcentage_tri*envoi_tri[i];
					som_env_eau<-som_env_eau-env_ordre[0,i]*pourcentage_tri*envoi_tri[i];
					som_env_energie<-som_env_energie-env_ordre[1,i]*pourcentage_tri*envoi_tri[i];
					som_env_co2<-som_env_co2-env_ordre[2,i]*pourcentage_tri*envoi_tri[i];
					tot_cout<-tot_cout+cout_ordre[2,i]*pourcentage_tri*envoi_tri[i];
					tot_env_eau<-tot_env_eau-env_ordre[0,i]*pourcentage_tri*envoi_tri[i];
					tot_env_energie<-tot_env_energie-env_ordre[1,i]*pourcentage_tri*envoi_tri[i];
					tot_env_co2<-tot_env_co2-env_ordre[2,i]*pourcentage_tri*envoi_tri[i];
					}
					else{ // Si le centre d'enfouissement le plus proche n'a plus la capacité on va chercher le centre d'enfouissement le plus proche ayant la capacité nécessaire
						loop j from:0 to:length(list_enfouissement)-1{
							if(list_enfouissement[j].capacite>=pourcentage_tri*envoi_tri[i] and list_enfouissement[j].info_acteur[i+8]="1" and find_new_enfouissement=false){
								
								list_enfouissement[j].stockage_ISDI[i]<-list_enfouissement[j].stockage_ISDI[i]+(pourcentage_tri*envoi_tri[i])/4.0;
								list_enfouissement[j].stockage_ISDND[i]<-list_enfouissement[j].stockage_ISDND[i]+(pourcentage_tri*envoi_tri[i])/4.0;
								list_enfouissement[j].stockage_ISDD[i]<-list_enfouissement[j].stockage_ISDD[i]+(pourcentage_tri*envoi_tri[i])/4.0;
								list_enfouissement[j].autre_elimination[i]<-list_enfouissement[j].autre_elimination[i]+(pourcentage_tri*envoi_tri[i])/4.0;
								
								som_stockage_ISDI<-som_stockage_ISDI+(pourcentage_tri*envoi_tri[i])/4.0;
								som_stockage_ISDND<-som_stockage_ISDND+(pourcentage_tri*envoi_tri[i])/4.0;
								som_stockage_ISDI<-som_stockage_ISDD+(pourcentage_tri*envoi_tri[i])/4.0;
								som_autre_elimination<-som_autre_elimination+(pourcentage_tri*envoi_tri[i])/4.0;
								tot_stockage_ISDI<-tot_stockage_ISDI+(pourcentage_tri*envoi_tri[i])/4.0;
								tot_stockage_ISDND<-tot_stockage_ISDND+(pourcentage_tri*envoi_tri[i])/4.0;
								tot_stockage_ISDI<-tot_stockage_ISDD+(pourcentage_tri*envoi_tri[i])/4.0;
								tot_autre_elimination<-tot_autre_elimination+(pourcentage_tri*envoi_tri[i])/4.0;
								list_enfouissement[j].capacite<-list_enfouissement[j].capacite-pourcentage_tri*envoi_tri[i];
								total_capacite<-total_capacite-pourcentage_tri*envoi_tri[i];
								som_cout<-som_cout+cout_ordre[0,i]*pourcentage_tri*envoi_tri[i];
								som_env_eau<-som_env_eau-env_ordre[0,i]*pourcentage_tri*envoi_tri[i];
								som_env_energie<-som_env_energie-env_ordre[1,i]*pourcentage_tri*envoi_tri[i];
								som_env_co2<-som_env_co2-env_ordre[2,i]*pourcentage_tri*envoi_tri[i];
								tot_cout<-tot_cout+cout_ordre[2,i]*pourcentage_tri*envoi_tri[i];
								tot_env_eau<-tot_env_eau-env_ordre[0,i]*pourcentage_tri*envoi_tri[i];
								tot_env_energie<-tot_env_energie-env_ordre[1,i]*pourcentage_tri*envoi_tri[i];
								tot_env_co2<-tot_env_co2-env_ordre[2,i]*pourcentage_tri*envoi_tri[i];
								find_new_enfouissement<-true;
							}
						}
					}
				if(centre_val.capacite>=(1-pourcentage_tri)*envoi_tri[i] and centre_val.info_acteur[i+8]="1"){
					
					centre_val.valo_matiere[i]<-centre_val.valo_matiere[i]+((1-pourcentage_tri)*envoi_tri[i])/3.0;
					centre_val.valo_energetique[i]<-centre_val.valo_energetique[i]+((1-pourcentage_tri)*envoi_tri[i])/3.0;
					centre_val.REP[i]<-centre_val.REP[i]+((1-pourcentage_tri)*envoi_tri[i])/3.0;
						
					som_valo_matiere<-som_valo_matiere+((1-pourcentage_tri)*envoi_tri[i])/3.0;
					som_valo_energetique<-som_valo_energetique+((1-pourcentage_tri)*envoi_tri[i])/3.0;
					som_REP<-som_REP+((1-pourcentage_tri)*envoi_tri[i])/3.0;
					tot_valo_matiere<-tot_valo_matiere+((1-pourcentage_tri)*envoi_tri[i])/3.0;
					tot_valo_energetique<-tot_valo_energetique+((1-pourcentage_tri)*envoi_tri[i])/3.0;
					tot_REP<-tot_REP+((1-pourcentage_tri)*envoi_tri[i])/3.0;
					centre_val.capacite<-centre_val.capacite-(1-pourcentage_tri)*envoi_tri[i];
					total_capacite2<-total_capacite2-(1-pourcentage_tri)*envoi_tri[i];
					som_cout<-som_cout+cout_ordre[3,i]*(1-pourcentage_tri)*envoi_tri[i];
					som_env_eau<-som_env_eau+env_ordre[0,i]*(1-pourcentage_tri)*envoi_tri[i];
					som_env_energie<-som_env_energie+env_ordre[1,i]*(1-pourcentage_tri)*envoi_tri[i];
					som_env_co2<-som_env_co2+env_ordre[2,i]*(1-pourcentage_tri)*envoi_tri[i];
					tot_cout<-tot_cout+cout_ordre[3,i]*(1-pourcentage_tri)*envoi_tri[i];
					tot_env_eau<-tot_env_eau+env_ordre[0,i]*(1-pourcentage_tri)*envoi_tri[i];
					tot_env_energie<-tot_env_energie+env_ordre[1,i]*(1-pourcentage_tri)*envoi_tri[i];
					tot_env_co2<-tot_env_co2+env_ordre[2,i]*(1-pourcentage_tri)*envoi_tri[i];
				}
				else{ 
						loop j from:0 to:length(list_valo)-1{
							if(list_valo[j].capacite>=(1-pourcentage_tri)*envoi_tri[i] and list_valo[j].info_acteur[i+8]="1" and find_new_centre_valo=false){
								
								list_valo[j].valo_matiere[i]<-list_valo[j].valo_matiere[i]+((1-pourcentage_tri)*envoi_tri[i])/3.0;
								list_valo[j].valo_energetique[i]<-list_valo[j].valo_energetique[i]+((1-pourcentage_tri)*envoi_tri[i])/3.0;
								list_valo[j].REP[i]<-list_valo[j].REP[i]+((1-pourcentage_tri)*envoi_tri[i])/3.0;
								
								som_valo_matiere<-som_valo_matiere+(1-pourcentage_tri)*envoi_tri[i];
								som_valo_energetique<-som_valo_energetique+(1-pourcentage_tri)*envoi_tri[i];
								som_REP<-som_REP+(1-pourcentage_tri)*envoi_tri[i];
								tot_valo_matiere<-tot_valo_matiere+((1-pourcentage_tri)*envoi_tri[i])/3.0;
								tot_valo_energetique<-tot_valo_energetique+((1-pourcentage_tri)*envoi_tri[i])/3.0;
								tot_REP<-tot_REP+((1-pourcentage_tri)*envoi_tri[i])/3.0;
								list_valo[j].capacite<-list_valo[j].capacite-(1-pourcentage_tri)*envoi_tri[i];
								total_capacite2<-total_capacite2-(1-pourcentage_tri)*envoi_tri[i];
								som_cout<-som_cout+cout_ordre[3,i]*(1-pourcentage_tri)*envoi_tri[i];
								som_env_eau<-som_env_eau+env_ordre[0,i]*(1-pourcentage_tri)*envoi_tri[i];
								som_env_energie<-som_env_energie+env_ordre[1,i]*(1-pourcentage_tri)*envoi_tri[i];
								som_env_co2<-som_env_co2+env_ordre[2,i]*(1-pourcentage_tri)*envoi_tri[i];
								tot_cout<-tot_cout+cout_ordre[3,i]*(1-pourcentage_tri)*envoi_tri[i];
								tot_env_eau<-tot_env_eau+env_ordre[0,i]*(1-pourcentage_tri)*envoi_tri[i];
								tot_env_energie<-tot_env_energie+env_ordre[1,i]*(1-pourcentage_tri)*envoi_tri[i];
								tot_env_co2<-tot_env_co2+env_ordre[2,i]*(1-pourcentage_tri)*envoi_tri[i];
								find_new_centre_valo<-true;
							}
						}
					}
				capacite<-capacite+envoi_tri[i];
				total_capacite<-total_capacite+envoi_tri[i];
				envoi_tri[i]<-0.0;
			}
		}
		nb_employe<-int(info_acteur[2]);
	}
}

species valorisation parent:building { // les centres de valorisation vont disparaître une certaine quantité par step
	list<float> valo_matiere<-nil;
	list<float> valo_energetique<-nil;
	list<float> REP<-nil;
	rgb color<-#orange;
	reflex decay {
		loop i from:0 to:length(valo_matiere)-1{
			
			if(valo_matiere[i]>=(info_capacite[i]*nb_heure)/3.0 and nb_employe!=0){
				nb_employe<-nb_employe-1;
				valo_matiere[i]<-valo_matiere[i]-(info_capacite[i]*nb_heure)/3.0;
				capacite<-capacite+(info_capacite[i]*nb_heure)/3.0;
				total_capacite2<-total_capacite2+(info_capacite[i]*nb_heure)/3.0;
			}
			else if(valo_matiere[i]>0.0 and nb_employe!=0){
				nb_employe<-nb_employe-1;
				capacite<-capacite+valo_matiere[i];
				total_capacite2<-total_capacite2+valo_matiere[i];
				valo_matiere[i]<-0.0;
			}
			if(valo_energetique[i]>=(info_capacite[i]*nb_heure)/3.0 and nb_employe!=0){
				valo_energetique[i]<-valo_energetique[i]-(info_capacite[i]*nb_heure)/3.0;
				capacite<-capacite+(info_capacite[i]*nb_heure)/3.0;
				total_capacite2<-total_capacite2+(info_capacite[i]*nb_heure)/3.0;
			}
			else if(valo_energetique[i]>0.0 and nb_employe!=0){
				capacite<-capacite+valo_energetique[i];
				total_capacite2<-total_capacite2+valo_energetique[i];
				valo_energetique[i]<-0.0;
			}
			if(REP[i]>=(info_capacite[i]*nb_heure)/3.0 and nb_employe!=0){
				REP[i]<-REP[i]-(info_capacite[i]*nb_heure)/3.0;
				capacite<-capacite+(info_capacite[i]*nb_heure)/3.0;
				total_capacite2<-total_capacite2+(info_capacite[i]*nb_heure)/3.0;
			}
			else if(REP[i]>0.0 and nb_employe!=0){
				capacite<-capacite+REP[i];
				total_capacite2<-total_capacite2+REP[i];
				REP[i]<-0.0;
			}
		}
		nb_employe<-int(info_acteur[2]);
	}
}

species reemploi parent:building {
	list<float> reemploi_site<-nil;
	list<float> reemploi_hors_site<-nil;
	list<float> reutilisation_site<-nil;
	list<float> reutilisation_hors_site<-nil;
	rgb color<-#pink;
	reflex decay {
		loop i from:0 to:length(reemploi_site)-1{
			if(reemploi_site[i]>=(info_capacite[i]*nb_heure)/4.0 and nb_employe!=0){
				nb_employe<-nb_employe-1;
				reemploi_site[i]<-reemploi_site[i]-(info_capacite[i]*nb_heure)/4.0;
				reemploi_hors_site[i]<-reemploi_hors_site[i]-(info_capacite[i]*nb_heure)/4.0;
				reutilisation_site[i]<-reutilisation_site[i]-(info_capacite[i]*nb_heure)/4.0;
				reutilisation_hors_site[i]<-reutilisation_hors_site[i]-(info_capacite[i]*nb_heure)/4.0;
				capacite<-capacite+info_capacite[i]*nb_heure;
				total_capacite4<-total_capacite4+info_capacite[i]*nb_heure;
			}
			else if(reemploi_site[i]>0.0 and nb_employe!=0){
				nb_employe<-nb_employe-1;
				capacite<-capacite+reemploi_site[i]+reemploi_hors_site[i]+reutilisation_site[i]+reutilisation_hors_site[i];
				total_capacite4<-total_capacite4+reemploi_site[i]+reemploi_hors_site[i]+reutilisation_site[i]+reutilisation_hors_site[i];
				reemploi_site[i]<-0.0;
				reemploi_hors_site[i]<-0.0;
				reutilisation_site[i]<-0.0;
				reutilisation_hors_site[i]<-0.0;
			}
		}
		nb_employe<-int(info_acteur[2]);
	}
}

species entreprise_deconstruction parent:building {
	matrix<float>  materiaux<-nil; 
	rgb color<-#purple;
	int nb_groupe;
	aspect base{
		draw circle(60) color: color border: #black;
	}
}

species deconstruction parent:building { 
	matrix<float>  materiaux<-nil; // liste de tous les matériaux existant
	float surface;
	bool deconstruction<-false; // Si le bâtiment est en cours de déconstruction
	entreprise_deconstruction entreprise_principale<-nil;
	rgb color<-#blue;
	
	reflex tot when: color!=#gray{ // calcul le total de matériaux restant 
		mat_total<-0.0;
		loop i from:0 to:materiaux.rows-1{
			mat_total<-mat_total+materiaux[0,i];
		}
	
	}
}

species people skills:[moving]{ // Unité opérative
	rgb color<- #yellow;
	float materiaux; // Correspond au total de matériaux restant
	int id_person;
	deconstruction batiment<-nil; // bâtiment sur lequel l'agent travaille
	tri centre_trie<-nil; // centre de tri le plus proche
	enfouissement centre_enfouissement<-nil; // centre de stockage le plus proche
	entreprise_deconstruction entreprise_demolition<-nil;
	valorisation centre_val<-nil;
	point the_target<-nil; //Pointe sur le prochain bâtiment à déconstruire
	list<deconstruction> list_bat<-nil; // liste de tous les bâtiments
	list<tri>list_traitement<-nil; // liste de tous les centres de tri
	list<building> tmp_centre<-nil;
	list<enfouissement>list_enfouissement<-nil;
	list<valorisation>list_valo<-nil;
	list<reemploi>list_reemploi<-nil;
	reemploi centre_reemploi<-nil;
	list<float> distance<-nil; // liste des distances aux centres de tri
	list<float>distance_enfouissement<-nil;
	list<float>distance_valo<-nil;
	list<float>distance_reemploi<-nil;
	list<float> tmp_dist<-nil;
	bool find_new_centre; // Pour trouver un autre centre si le plus proche est rempli
	bool sol;
	bool find_new_centre_valo;
	bool find_new_reemploi;
	bool find_new_enfouissement;
	bool retour;
	bool depart;
	bool find_new_deconstruction;
	bool actif;
	int nb_employe;
	init{
		list_traitement<-list(tri);
		list_reemploi<-list(reemploi);
		list_enfouissement<-list(enfouissement);
		list_valo<-list(valorisation);
		distance<-list_with(length(list_traitement),0.0);
		distance_enfouissement<-list_with(length(list_enfouissement),0.0);
		distance_valo<-list_with(length(list_valo),0.0);
		distance_reemploi<-list_with(length(list_reemploi),0.0);
		speed<-50#km/#h; // Correspond à la vitesse de déplacement de l'agent lors du changement de bâtiment
		retour<-false;
		depart<-true;
		actif<-false;
	}
	
	// Les decay diminue le matériaux d'un certain nombre et l'envoi dans les centres  les plus proche
	reflex decay when: actif=true {
		find_new_enfouissement<-false;
		find_new_reemploi<-false;
		find_new_centre<-false;
		find_new_centre_valo<-false;
		sol<-false;
		loop i from:0 to:batiment.materiaux.rows -1{
			if(batiment.materiaux[0,i]!=0.0 and sol=false){
				sol<-true;
				if (batiment.materiaux[0,i]>=decay_building){
					batiment.materiaux[0,i]<-batiment.materiaux[0,i] -decay_building;
					tot_materiaux<-tot_materiaux-decay_building;
					// On envoit une partie en enfouissement
					if(centre_enfouissement.capacite>=(decay_building*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i])) and centre_enfouissement.info_acteur[i+8]="1"){
					centre_enfouissement.stockage_ISDI[i]<-centre_enfouissement.stockage_ISDI[i]+decay_building*note_ordre[8,i];
					centre_enfouissement.stockage_ISDND[i]<-centre_enfouissement.stockage_ISDND[i]+decay_building*note_ordre[9,i];
					centre_enfouissement.stockage_ISDD[i]<-centre_enfouissement.stockage_ISDD[i]+decay_building*note_ordre[10,i];
					centre_enfouissement.autre_elimination[i]<-centre_enfouissement.autre_elimination[i]+decay_building*note_ordre[11,i];
					
					som_stockage_ISDI<-som_stockage_ISDI+decay_building*note_ordre[8,i];
					som_stockage_ISDND<-som_stockage_ISDND+decay_building*note_ordre[9,i];
					som_stockage_ISDI<-som_stockage_ISDD+decay_building*note_ordre[10,i];
					som_autre_elimination<-som_autre_elimination+decay_building*note_ordre[11,i];
					tot_stockage_ISDI<-tot_stockage_ISDI+decay_building*note_ordre[8,i];
					tot_stockage_ISDND<-tot_stockage_ISDND+decay_building*note_ordre[9,i];
					tot_stockage_ISDI<-tot_stockage_ISDD+decay_building*note_ordre[10,i];
					tot_autre_elimination<-tot_autre_elimination+decay_building*note_ordre[11,i];
					centre_enfouissement.capacite<-centre_enfouissement.capacite-decay_building*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
					total_capacite3<-total_capacite3-decay_building*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
					som_cout<-som_cout+cout_ordre[2,i]*decay_building*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
					som_env_eau<-som_env_eau-env_ordre[0,i]*decay_building*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
					som_env_energie<-som_env_energie-env_ordre[1,i]*decay_building*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
					som_env_co2<-som_env_co2-env_ordre[2,i]*decay_building*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
					tot_cout<-tot_cout+cout_ordre[2,i]*decay_building*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
					tot_env_eau<-tot_env_eau-env_ordre[0,i]*decay_building*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
					tot_env_energie<-tot_env_energie-env_ordre[1,i]*decay_building*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
					tot_env_co2<-tot_env_co2-env_ordre[2,i]*decay_building*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
					}
					else{ // Si le centre d'enfouissement le plus proche n'a plus la capacité on va chercher le centre d'enfouissement le plus proche ayant la capacité nécessaire
						loop j from:0 to:length(list_enfouissement)-1{
							if(list_enfouissement[j].capacite>=decay_building*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]) and list_enfouissement[j].info_acteur[i+8]="1" and find_new_enfouissement=false){
								list_enfouissement[j].stockage_ISDI[i]<-list_enfouissement[j].stockage_ISDI[i]+decay_building*note_ordre[8,i];
								list_enfouissement[j].stockage_ISDND[i]<-list_enfouissement[j].stockage_ISDND[i]+decay_building*note_ordre[9,i];
								list_enfouissement[j].stockage_ISDD[i]<-list_enfouissement[j].stockage_ISDD[i]+decay_building*note_ordre[10,i];
								list_enfouissement[j].autre_elimination[i]<-list_enfouissement[j].autre_elimination[i]+decay_building*note_ordre[11,i];
					
								som_stockage_ISDI<-som_stockage_ISDI+decay_building*note_ordre[8,i];
								som_stockage_ISDND<-som_stockage_ISDND+decay_building*note_ordre[9,i];
								som_stockage_ISDI<-som_stockage_ISDD+decay_building*note_ordre[10,i];
								som_autre_elimination<-som_autre_elimination+decay_building*note_ordre[11,i];
								tot_stockage_ISDI<-tot_stockage_ISDI+decay_building*note_ordre[8,i];
								tot_stockage_ISDND<-tot_stockage_ISDND+decay_building*note_ordre[9,i];
								tot_stockage_ISDI<-tot_stockage_ISDD+decay_building*note_ordre[10,i];
								tot_autre_elimination<-tot_autre_elimination+decay_building*note_ordre[11,i];
								list_enfouissement[j].capacite<-list_enfouissement[j].capacite-decay_building*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
								total_capacite<-total_capacite-decay_building*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
								som_cout<-som_cout+cout_ordre[0,i]*decay_building*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
								som_env_eau<-som_env_eau-env_ordre[0,i]*decay_building*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
								som_env_energie<-som_env_energie-env_ordre[1,i]*decay_building*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
								som_env_co2<-som_env_co2-env_ordre[2,i]*decay_building*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
								tot_cout<-tot_cout+cout_ordre[2,i]*decay_building*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
								tot_env_eau<-tot_env_eau-env_ordre[0,i]*decay_building*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
								tot_env_energie<-tot_env_energie-env_ordre[1,i]*decay_building*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
								tot_env_co2<-tot_env_co2-env_ordre[2,i]*decay_building*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
								find_new_enfouissement<-true;
							}
						}
					}
					// Un autre partie en centre de tri
					if(centre_trie.capacite>=(decay_building*note_ordre[4,i])and centre_trie.info_acteur[i+8]="1" and centre_trie.info_capacite[i]!=0.0){
						centre_trie.envoi_tri[i]<-centre_trie.envoi_tri[i]+decay_building*note_ordre[4,i];
						
						tot_envoi_tri<-tot_envoi_tri+decay_building*note_ordre[4,i];
						som_envoi_tri<-som_envoi_tri+decay_building*note_ordre[4,i];
						centre_trie.capacite<-centre_trie.capacite-decay_building*note_ordre[4,i];
						total_capacite<-total_capacite-decay_building*note_ordre[4,i];
						som_cout<-som_cout+cout_ordre[0,i]*decay_building*note_ordre[4,i];
						tot_cout<-tot_cout+cout_ordre[0,i]*decay_building*note_ordre[4,i];
					}
					else{ // Si le centre de tri le plus proche n'a plus la capacité on va chercher le centre de tri le plus proche ayant la capacité nécessaire
						loop j from:0 to:length(list_traitement)-1{
							if(list_traitement[j].capacite>=decay_building*note_ordre[4,i] and list_traitement[j].info_acteur[i+8]="1" and list_traitement[j].info_capacite[i]!=0.0 and find_new_centre=false){
								list_traitement[j].envoi_tri[i]<-list_traitement[j].envoi_tri[i]+decay_building*note_ordre[4,i];
								
								tot_envoi_tri<-tot_envoi_tri+decay_building*note_ordre[4,i];
								som_envoi_tri<-som_envoi_tri+decay_building*note_ordre[4,i];
								list_traitement[j].capacite<-list_traitement[j].capacite-decay_building*note_ordre[4,i];
								total_capacite<-total_capacite-decay_building*note_ordre[4,i];
								som_cout<-som_cout+cout_ordre[0,i]*decay_building*note_ordre[4,i];
								tot_cout<-tot_cout+cout_ordre[0,i]*decay_building*note_ordre[4,i];
								find_new_centre<-true;
							}
						}
					}
					// Ensuite les centres de réemploi
					if(centre_reemploi.capacite>=(decay_building*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i])) and centre_reemploi.info_capacite[i]!=0.0 and centre_reemploi.info_acteur[i+8]="1"){
						centre_reemploi.reemploi_site[i]<-centre_reemploi.reemploi_site[i]+decay_building*note_ordre[0,i];
						centre_reemploi.reutilisation_site[i]<-centre_reemploi.reutilisation_site[i]+decay_building*note_ordre[1,i];
						centre_reemploi.reemploi_hors_site[i]<-centre_reemploi.reemploi_hors_site[i]+decay_building*note_ordre[2,i];
						centre_reemploi.reutilisation_hors_site[i]<-centre_reemploi.reutilisation_hors_site[i]+decay_building*note_ordre[3,i];
						
						som_reemploi_site<-som_reemploi_site+decay_building*note_ordre[0,i];
						som_reutilisation_site<-som_reutilisation_site+decay_building*note_ordre[1,i];
						som_reemploi_hors_site<-som_reemploi_hors_site+decay_building*note_ordre[2,i];
						som_reutilisation_hors_site<-som_reutilisation_hors_site+decay_building*note_ordre[3,i];
						tot_reemploi_site<-tot_reemploi_site+decay_building*note_ordre[0,i];
						tot_reutilisation_site<-tot_reutilisation_site+decay_building*note_ordre[1,i];
						tot_reemploi_hors_site<-tot_reemploi_hors_site+decay_building*note_ordre[2,i];
						tot_reutilisation_hors_site<-tot_reutilisation_hors_site+decay_building*note_ordre[3,i];
						centre_reemploi.capacite<-centre_reemploi.capacite-decay_building*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
						total_capacite4<-total_capacite4-decay_building*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
						som_cout<-som_cout+cout_ordre[1,i]*decay_building*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
						som_env_eau<-som_env_eau+env_ordre[0,i]*decay_building*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
						som_env_energie<-som_env_energie+env_ordre[1,i]*decay_building*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
						som_env_co2<-som_env_co2+env_ordre[2,i]*decay_building*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
						tot_cout<-tot_cout+cout_ordre[1,i]*decay_building*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
						tot_env_eau<-tot_env_eau+env_ordre[0,i]*decay_building*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
						tot_env_energie<-tot_env_energie+env_ordre[1,i]*decay_building*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
						tot_env_co2<-tot_env_co2+env_ordre[2,i]*decay_building*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
					}
					else{ // Si le centre de reemploi le plus proche n'a plus la capacité on va chercher le centre de reemploi le plus proche ayant la capacité nécessaire
						loop j from:0 to:length(list_reemploi)-1{
							if(list_reemploi[j].capacite>=decay_building*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]) and list_reemploi[j].info_capacite[i]!=0.0 and list_reemploi[j].info_acteur[i+8]="1" and find_new_reemploi=false){
								list_reemploi[j].reemploi_site[i]<-list_reemploi[j].reemploi_site[i]+decay_building*note_ordre[0,i];
								list_reemploi[j].reutilisation_site[i]<-list_reemploi[j].reutilisation_site[i]+decay_building*note_ordre[1,i];
								list_reemploi[j].reemploi_hors_site[i]<-list_reemploi[j].reemploi_hors_site[i]+decay_building*note_ordre[2,i];
								list_reemploi[j].reutilisation_hors_site[i]<-list_reemploi[j].reutilisation_hors_site[i]+decay_building*note_ordre[3,i];
								
								som_reemploi_site<-som_reemploi_site+decay_building*note_ordre[0,i];
								som_reutilisation_site<-som_reutilisation_site+decay_building*note_ordre[1,i];
								som_reemploi_hors_site<-som_reemploi_hors_site+decay_building*note_ordre[2,i];
								som_reutilisation_hors_site<-som_reutilisation_hors_site+decay_building*note_ordre[3,i];
								tot_reemploi_site<-tot_reemploi_site+decay_building*note_ordre[0,i];
								tot_reutilisation_site<-tot_reutilisation_site+decay_building*note_ordre[1,i];
								tot_reemploi_hors_site<-tot_reemploi_hors_site+decay_building*note_ordre[2,i];
								tot_reutilisation_hors_site<-tot_reutilisation_hors_site+decay_building*note_ordre[3,i];
								list_reemploi[j].capacite<-list_reemploi[j].capacite-decay_building*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
								total_capacite4<-total_capacite4-decay_building*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
								som_cout<-som_cout+cout_ordre[1,i]*decay_building*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
								som_env_eau<-som_env_eau+env_ordre[0,i]*decay_building*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
								som_env_energie<-som_env_energie+env_ordre[1,i]*decay_building*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
								som_env_co2<-som_env_co2+env_ordre[2,i]*decay_building*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
								tot_cout<-tot_cout+cout_ordre[1,i]*decay_building*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
								tot_env_eau<-tot_env_eau+env_ordre[0,i]*decay_building*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
								tot_env_energie<-tot_env_energie+env_ordre[1,i]*decay_building*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
								tot_env_co2<-tot_env_co2+env_ordre[2,i]*decay_building*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
								find_new_reemploi<-true;
							}
						}
					}
					// et le reste en valorisation
					if(centre_val.capacite>=(decay_building*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i])) and centre_val.info_capacite[i]!=0.0 and centre_val.info_acteur[i+8]="1"){
						centre_val.valo_matiere[i]<-centre_val.valo_matiere[i]+decay_building*note_ordre[5,i];
						centre_val.valo_energetique[i]<-centre_val.valo_energetique[i]+decay_building*note_ordre[6,i];
						centre_val.REP[i]<-centre_val.REP[i]+decay_building*note_ordre[7,i];
						
						som_valo_matiere<-som_valo_matiere+decay_building*note_ordre[5,i];
						som_valo_energetique<-som_valo_energetique+decay_building*note_ordre[6,i];
						som_REP<-som_REP+decay_building*note_ordre[7,i];
						tot_valo_matiere<-tot_valo_matiere+decay_building*note_ordre[5,i];
						tot_valo_energetique<-tot_valo_energetique+decay_building*note_ordre[6,i];
						tot_REP<-tot_REP+decay_building*note_ordre[7,i];
						centre_val.capacite<-centre_val.capacite-decay_building*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
						total_capacite2<-total_capacite2-decay_building*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
						som_cout<-som_cout+cout_ordre[3,i]*decay_building*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
						som_env_eau<-som_env_eau+env_ordre[0,i]*decay_building*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
						som_env_energie<-som_env_energie+env_ordre[1,i]*decay_building*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
						som_env_co2<-som_env_co2+env_ordre[2,i]*decay_building*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
						tot_cout<-tot_cout+cout_ordre[3,i]*decay_building*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
						tot_env_eau<-tot_env_eau+env_ordre[0,i]*decay_building*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
						tot_env_energie<-tot_env_energie+env_ordre[1,i]*decay_building*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
						tot_env_co2<-tot_env_co2+env_ordre[2,i]*decay_building*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
					}
					else{ // Si le centre de valo le plus proche n'a plus la capacité on va chercher le centre de valo le plus proche ayant la capacité nécessaire
						loop j from:0 to:length(list_valo)-1{
							if(list_valo[j].capacite>=decay_building*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]) and list_valo[j].info_acteur[i+8]="1" and list_valo[j].info_capacite[i]!=0.0 and find_new_centre_valo=false){
								list_valo[j].valo_matiere[i]<-list_valo[j].valo_matiere[i]+decay_building*note_ordre[5,i];
								list_valo[j].valo_energetique[i]<-list_valo[j].valo_energetique[i]+decay_building*note_ordre[6,i];
								list_valo[j].REP[i]<-list_valo[j].REP[i]+decay_building*note_ordre[7,i];
								
								som_valo_matiere<-som_valo_matiere+decay_building*note_ordre[5,i];
								som_valo_energetique<-som_valo_energetique+decay_building*note_ordre[6,i];
								som_REP<-som_REP+decay_building*note_ordre[7,i];
								tot_valo_matiere<-tot_valo_matiere+decay_building*note_ordre[5,i];
								tot_valo_energetique<-tot_valo_energetique+decay_building*note_ordre[6,i];
								tot_REP<-tot_REP+decay_building*note_ordre[7,i];
								list_valo[j].capacite<-list_valo[j].capacite-decay_building*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
								total_capacite2<-total_capacite2-decay_building*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
								som_cout<-som_cout+cout_ordre[3,i]*decay_building*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
								som_env_eau<-som_env_eau+env_ordre[0,i]*decay_building*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
								som_env_energie<-som_env_energie+env_ordre[1,i]*decay_building*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
								som_env_co2<-som_env_co2+env_ordre[2,i]*decay_building*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
								tot_cout<-tot_cout+cout_ordre[3,i]*decay_building*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
								tot_env_eau<-tot_env_eau+env_ordre[0,i]*decay_building*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
								tot_env_energie<-tot_env_energie+env_ordre[1,i]*decay_building*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
								tot_env_co2<-tot_env_co2+env_ordre[2,i]*decay_building*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
								find_new_centre_valo<-true;
							}
						}
					}
				}
				else{ // Si le nombre de tonnes du matériaux est < decay_building il faut enlever le reste pour atteindre 0
					if(centre_enfouissement.capacite>=(batiment.materiaux[0,i]*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i])) and centre_enfouissement.info_acteur[i+8]="1"){
				
					centre_enfouissement.stockage_ISDI[i]<-centre_enfouissement.stockage_ISDI[i]+batiment.materiaux[0,i]*note_ordre[8,i];
					centre_enfouissement.stockage_ISDND[i]<-centre_enfouissement.stockage_ISDND[i]+batiment.materiaux[0,i]*note_ordre[9,i];
					centre_enfouissement.stockage_ISDD[i]<-centre_enfouissement.stockage_ISDD[i]+batiment.materiaux[0,i]*note_ordre[10,i];
					centre_enfouissement.autre_elimination[i]<-centre_enfouissement.autre_elimination[i]+batiment.materiaux[0,i]*note_ordre[11,i];
					
					som_stockage_ISDI<-som_stockage_ISDI+batiment.materiaux[0,i]*note_ordre[8,i];
					som_stockage_ISDND<-som_stockage_ISDND+batiment.materiaux[0,i]*note_ordre[9,i];
					som_stockage_ISDI<-som_stockage_ISDD+batiment.materiaux[0,i]*note_ordre[10,i];
					som_autre_elimination<-som_autre_elimination+batiment.materiaux[0,i]*note_ordre[11,i];
					tot_stockage_ISDI<-tot_stockage_ISDI+batiment.materiaux[0,i]*note_ordre[8,i];
					tot_stockage_ISDND<-tot_stockage_ISDND+batiment.materiaux[0,i]*note_ordre[9,i];
					tot_stockage_ISDI<-tot_stockage_ISDD+batiment.materiaux[0,i]*note_ordre[10,i];
					tot_autre_elimination<-tot_autre_elimination+batiment.materiaux[0,i]*note_ordre[11,i];
					centre_enfouissement.capacite<-centre_enfouissement.capacite-batiment.materiaux[0,i]*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
					total_capacite3<-total_capacite3-batiment.materiaux[0,i]*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
					som_cout<-som_cout+cout_ordre[2,i]*batiment.materiaux[0,i]*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
					som_env_eau<-som_env_eau-env_ordre[0,i]*batiment.materiaux[0,i]*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
					som_env_energie<-som_env_energie-env_ordre[1,i]*batiment.materiaux[0,i]*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
					som_env_co2<-som_env_co2-env_ordre[2,i]*batiment.materiaux[0,i]*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
					tot_cout<-tot_cout+cout_ordre[2,i]*batiment.materiaux[0,i]*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
					tot_env_eau<-tot_env_eau-env_ordre[0,i]*batiment.materiaux[0,i]*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
					tot_env_energie<-tot_env_energie-env_ordre[1,i]*batiment.materiaux[0,i]*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
					tot_env_co2<-tot_env_co2-env_ordre[2,i]*batiment.materiaux[0,i]*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
					}
					else{ // Si le centre d'enfouissement le plus proche n'a plus la capacité on va chercher le centre d'enfouissement le plus proche ayant la capacité nécessaire
						loop j from:0 to:length(list_enfouissement)-1{
							if(list_enfouissement[j].capacite>=batiment.materiaux[0,i]*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i])  and list_enfouissement[j].info_acteur[i+8]="1" and find_new_enfouissement=false){
							
								list_enfouissement[j].stockage_ISDI[i]<-list_enfouissement[j].stockage_ISDI[i]+batiment.materiaux[0,i]*note_ordre[8,i];
								list_enfouissement[j].stockage_ISDND[i]<-list_enfouissement[j].stockage_ISDND[i]+batiment.materiaux[0,i]*note_ordre[9,i];
								list_enfouissement[j].stockage_ISDD[i]<-list_enfouissement[j].stockage_ISDD[i]+batiment.materiaux[0,i]*note_ordre[10,i];
								list_enfouissement[j].autre_elimination[i]<-list_enfouissement[j].autre_elimination[i]+batiment.materiaux[0,i]*note_ordre[11,i];
								
								som_stockage_ISDI<-som_stockage_ISDI+batiment.materiaux[0,i]*note_ordre[8,i];
								som_stockage_ISDND<-som_stockage_ISDND+batiment.materiaux[0,i]*note_ordre[9,i];
								som_stockage_ISDI<-som_stockage_ISDD+batiment.materiaux[0,i]*note_ordre[10,i];
								som_autre_elimination<-som_autre_elimination+batiment.materiaux[0,i]*note_ordre[11,i];
								tot_stockage_ISDI<-tot_stockage_ISDI+batiment.materiaux[0,i]*note_ordre[8,i];
								tot_stockage_ISDND<-tot_stockage_ISDND+batiment.materiaux[0,i]*note_ordre[9,i];
								tot_stockage_ISDI<-tot_stockage_ISDD+batiment.materiaux[0,i]*note_ordre[10,i];
								tot_autre_elimination<-tot_autre_elimination+batiment.materiaux[0,i]*note_ordre[11,i];
								list_enfouissement[j].capacite<-list_enfouissement[j].capacite-batiment.materiaux[0,i]*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
								total_capacite<-total_capacite-batiment.materiaux[0,i]*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
								som_cout<-som_cout+cout_ordre[0,i]*batiment.materiaux[0,i]*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
								som_env_eau<-som_env_eau-env_ordre[0,i]*batiment.materiaux[0,i]*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
								som_env_energie<-som_env_energie-env_ordre[1,i]*batiment.materiaux[0,i]*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
								som_env_co2<-som_env_co2-env_ordre[2,i]*batiment.materiaux[0,i]*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
								tot_cout<-tot_cout+cout_ordre[2,i]*batiment.materiaux[0,i]*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
								tot_env_eau<-tot_env_eau-env_ordre[0,i]*batiment.materiaux[0,i]*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
								tot_env_energie<-tot_env_energie-env_ordre[1,i]*batiment.materiaux[0,i]*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
								tot_env_co2<-tot_env_co2-env_ordre[2,i]*batiment.materiaux[0,i]*(note_ordre[8,i]+note_ordre[9,i]+note_ordre[10,i]+note_ordre[11,i]);
								find_new_enfouissement<-true;
							}
						}
					}
					
					if(centre_trie.capacite>=(batiment.materiaux[0,i]*note_ordre[4,i])and centre_trie.info_acteur[i+8]="1" and centre_trie.info_capacite[i]!=0.0){
						
						centre_trie.envoi_tri[i]<-centre_trie.envoi_tri[i]+batiment.materiaux[0,i]*note_ordre[4,i];
						
						tot_envoi_tri<-tot_envoi_tri+batiment.materiaux[0,i]*note_ordre[4,i];
						som_envoi_tri<-som_envoi_tri+batiment.materiaux[0,i]*note_ordre[4,i];
						centre_trie.capacite<-centre_trie.capacite-batiment.materiaux[0,i]*note_ordre[4,i];
						total_capacite<-total_capacite-batiment.materiaux[0,i]*note_ordre[4,i];
						som_cout<-som_cout+cout_ordre[0,i]*batiment.materiaux[0,i]*note_ordre[4,i];
						tot_cout<-tot_cout+cout_ordre[0,i]*batiment.materiaux[0,i]*note_ordre[4,i];
					}
					else{ // Si le centre de tri le plus proche n'a plus la capacité on va chercher le centre de tri le plus proche ayant la capacité nécessaire
						loop j from:0 to:length(list_traitement)-1{
							if(list_traitement[j].capacite>=batiment.materiaux[0,i]*note_ordre[4,i] and list_traitement[j].info_acteur[i+8]="1" and list_traitement[j].info_capacite[i]!=0.0 and find_new_centre=false){
								
								list_traitement[j].envoi_tri[i]<-list_traitement[j].envoi_tri[i]+batiment.materiaux[0,i]*note_ordre[4,i];
								
								tot_envoi_tri<-tot_envoi_tri+batiment.materiaux[0,i]*note_ordre[4,i];
								som_envoi_tri<-som_envoi_tri+batiment.materiaux[0,i]*note_ordre[4,i];
								list_traitement[j].capacite<-list_traitement[j].capacite-batiment.materiaux[0,i]*note_ordre[4,i];
								total_capacite<-total_capacite-batiment.materiaux[0,i]*note_ordre[4,i];
								som_cout<-som_cout+cout_ordre[0,i]*batiment.materiaux[0,i]*note_ordre[4,i];
								tot_cout<-tot_cout+cout_ordre[0,i]*batiment.materiaux[0,i]*note_ordre[4,i];
								find_new_centre<-true;
							}
						}
					}
					
					if(centre_reemploi.capacite>=(batiment.materiaux[0,i]*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]))and centre_reemploi.info_capacite[i]!=0.0 and centre_reemploi.info_acteur[i+8]="1"){
						
						centre_reemploi.reemploi_site[i]<-centre_reemploi.reemploi_site[i]+batiment.materiaux[0,i]*note_ordre[0,i];
						centre_reemploi.reutilisation_site[i]<-centre_reemploi.reutilisation_site[i]+batiment.materiaux[0,i]*note_ordre[1,i];
						centre_reemploi.reemploi_hors_site[i]<-centre_reemploi.reemploi_hors_site[i]+batiment.materiaux[0,i]*note_ordre[2,i];
						centre_reemploi.reutilisation_hors_site[i]<-centre_reemploi.reutilisation_hors_site[i]+batiment.materiaux[0,i]*note_ordre[3,i];
						
						som_reemploi_site<-som_reemploi_site+batiment.materiaux[0,i]*note_ordre[0,i];
						som_reutilisation_site<-som_reutilisation_site+batiment.materiaux[0,i]*note_ordre[1,i];
						som_reemploi_hors_site<-som_reemploi_hors_site+batiment.materiaux[0,i]*note_ordre[2,i];
						som_reutilisation_hors_site<-som_reutilisation_hors_site+batiment.materiaux[0,i]*note_ordre[3,i];
						tot_reemploi_site<-tot_reemploi_site+batiment.materiaux[0,i]*note_ordre[0,i];
						tot_reutilisation_site<-tot_reutilisation_site+batiment.materiaux[0,i]*note_ordre[1,i];
						tot_reemploi_hors_site<-tot_reemploi_hors_site+batiment.materiaux[0,i]*note_ordre[2,i];
						tot_reutilisation_hors_site<-tot_reutilisation_hors_site+batiment.materiaux[0,i]*note_ordre[3,i];
						centre_reemploi.capacite<-centre_reemploi.capacite-batiment.materiaux[0,i]*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
						total_capacite4<-total_capacite4-batiment.materiaux[0,i]*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
						som_cout<-som_cout+cout_ordre[1,i]*batiment.materiaux[0,i]*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
						som_env_eau<-som_env_eau+env_ordre[0,i]*batiment.materiaux[0,i]*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
						som_env_energie<-som_env_energie+env_ordre[1,i]*batiment.materiaux[0,i]*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
						som_env_co2<-som_env_co2+env_ordre[2,i]*batiment.materiaux[0,i]*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
						tot_cout<-tot_cout+cout_ordre[1,i]*batiment.materiaux[0,i]*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
						tot_env_eau<-tot_env_eau+env_ordre[0,i]*batiment.materiaux[0,i]*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
						tot_env_energie<-tot_env_energie+env_ordre[1,i]*batiment.materiaux[0,i]*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
						tot_env_co2<-tot_env_co2+env_ordre[2,i]*batiment.materiaux[0,i]*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
					}
					else{ // Si le centre de reemploi le plus proche n'a plus la capacité on va chercher le centre de reemploi le plus proche ayant la capacité nécessaire
						loop j from:0 to:length(list_reemploi)-1{
							if(list_reemploi[j].capacite>=batiment.materiaux[0,i]*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]) and list_reemploi[j].info_capacite[i]!=0.0 and list_reemploi[j].info_acteur[i+8]="1" and find_new_reemploi=false){
								
								list_reemploi[j].reemploi_site[i]<-list_reemploi[j].reemploi_site[i]+batiment.materiaux[0,i]*note_ordre[0,i];
								list_reemploi[j].reutilisation_site[i]<-list_reemploi[j].reutilisation_site[i]+batiment.materiaux[0,i]*note_ordre[1,i];
								list_reemploi[j].reemploi_hors_site[i]<-list_reemploi[j].reemploi_hors_site[i]+batiment.materiaux[0,i]*note_ordre[2,i];
								list_reemploi[j].reutilisation_hors_site[i]<-list_reemploi[j].reutilisation_hors_site[i]+batiment.materiaux[0,i]*note_ordre[3,i];
								
								som_reemploi_site<-som_reemploi_site+batiment.materiaux[0,i]*note_ordre[0,i];
								som_reutilisation_site<-som_reutilisation_site+batiment.materiaux[0,i]*note_ordre[1,i];
								som_reemploi_hors_site<-som_reemploi_hors_site+batiment.materiaux[0,i]*note_ordre[2,i];
								som_reutilisation_hors_site<-som_reutilisation_hors_site+batiment.materiaux[0,i]*note_ordre[3,i];
								tot_reemploi_site<-tot_reemploi_site+batiment.materiaux[0,i]*note_ordre[0,i];
								tot_reutilisation_site<-tot_reutilisation_site+batiment.materiaux[0,i]*note_ordre[1,i];
								tot_reemploi_hors_site<-tot_reemploi_hors_site+batiment.materiaux[0,i]*note_ordre[2,i];
								tot_reutilisation_hors_site<-tot_reutilisation_hors_site+batiment.materiaux[0,i]*note_ordre[3,i];
								list_reemploi[j].capacite<-list_reemploi[j].capacite-batiment.materiaux[0,i]*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
								total_capacite4<-total_capacite4-batiment.materiaux[0,i]*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
								som_cout<-som_cout+cout_ordre[1,i]*batiment.materiaux[0,i]*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
								som_env_eau<-som_env_eau+env_ordre[0,i]*batiment.materiaux[0,i]*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
								som_env_energie<-som_env_energie+env_ordre[1,i]*batiment.materiaux[0,i]*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
								som_env_co2<-som_env_co2+env_ordre[2,i]*batiment.materiaux[0,i]*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
								tot_cout<-tot_cout+cout_ordre[1,i]*batiment.materiaux[0,i]*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
								tot_env_eau<-tot_env_eau+env_ordre[0,i]*batiment.materiaux[0,i]*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
								tot_env_energie<-tot_env_energie+env_ordre[1,i]*batiment.materiaux[0,i]*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
								tot_env_co2<-tot_env_co2+env_ordre[2,i]*batiment.materiaux[0,i]*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]+note_ordre[3,i]);
								find_new_reemploi<-true;
							}
						}
					}
					
					if(centre_val.capacite>=(batiment.materiaux[0,i]*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]))and centre_val.info_capacite[i]!=0.0 and centre_val.info_acteur[i+8]="1"){
						
						centre_val.valo_matiere[i]<-centre_val.valo_matiere[i]+batiment.materiaux[0,i]*note_ordre[5,i];
						centre_val.valo_energetique[i]<-centre_val.valo_energetique[i]+batiment.materiaux[0,i]*note_ordre[6,i];
						centre_val.REP[i]<-centre_val.REP[i]+batiment.materiaux[0,i]*note_ordre[7,i];
						
						som_valo_matiere<-som_valo_matiere+batiment.materiaux[0,i]*note_ordre[5,i];
						som_valo_energetique<-som_valo_energetique+batiment.materiaux[0,i]*note_ordre[6,i];
						som_REP<-som_REP+batiment.materiaux[0,i]*note_ordre[7,i];
						tot_valo_matiere<-tot_valo_matiere+batiment.materiaux[0,i]*note_ordre[5,i];
						tot_valo_energetique<-tot_valo_energetique+batiment.materiaux[0,i]*note_ordre[6,i];
						tot_REP<-tot_REP+batiment.materiaux[0,i]*note_ordre[7,i];
						centre_val.capacite<-centre_val.capacite-batiment.materiaux[0,i]*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
						total_capacite2<-total_capacite2-batiment.materiaux[0,i]*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
						som_cout<-som_cout+cout_ordre[3,i]*batiment.materiaux[0,i]*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
						som_env_eau<-som_env_eau+env_ordre[0,i]*batiment.materiaux[0,i]*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
						som_env_energie<-som_env_energie+env_ordre[1,i]*batiment.materiaux[0,i]*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
						som_env_co2<-som_env_co2+env_ordre[2,i]*batiment.materiaux[0,i]*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
						tot_cout<-tot_cout+cout_ordre[3,i]*batiment.materiaux[0,i]*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
						tot_env_eau<-tot_env_eau+env_ordre[0,i]*batiment.materiaux[0,i]*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
						tot_env_energie<-tot_env_energie+env_ordre[1,i]*batiment.materiaux[0,i]*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
						tot_env_co2<-tot_env_co2+env_ordre[2,i]*batiment.materiaux[0,i]*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
					}
					else{ // Si le centre de valo le plus proche n'a plus la capacité on va chercher le centre de tri le plus proche ayant la capacité nécessaire
						loop j from:0 to:length(list_valo)-1{
							if(list_valo[j].capacite>=batiment.materiaux[0,i]*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]) and list_valo[j].info_capacite[i]!=0.0 and list_valo[j].info_acteur[i+8]="1" and find_new_centre_valo=false){
								
								list_valo[j].valo_matiere[i]<-list_valo[j].valo_matiere[i]+batiment.materiaux[0,i]*note_ordre[5,i];
								list_valo[j].valo_energetique[i]<-list_valo[j].valo_energetique[i]+batiment.materiaux[0,i]*note_ordre[6,i];
								list_valo[j].REP[i]<-list_valo[j].REP[i]+batiment.materiaux[0,i]*note_ordre[7,i];
								
								som_valo_matiere<-som_valo_matiere+batiment.materiaux[0,i]*note_ordre[5,i];
								som_valo_energetique<-som_valo_energetique+batiment.materiaux[0,i]*note_ordre[6,i];
								som_REP<-som_REP+batiment.materiaux[0,i]*note_ordre[7,i];
								tot_valo_matiere<-tot_valo_matiere+batiment.materiaux[0,i]*note_ordre[5,i];
								tot_valo_energetique<-tot_valo_energetique+batiment.materiaux[0,i]*note_ordre[6,i];
								tot_REP<-tot_REP+batiment.materiaux[0,i]*note_ordre[7,i];
								list_valo[j].capacite<-list_valo[j].capacite-batiment.materiaux[0,i]*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
								total_capacite2<-total_capacite2-batiment.materiaux[0,i]*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
								som_cout<-som_cout+cout_ordre[3,i]*batiment.materiaux[0,i]*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
								som_env_eau<-som_env_eau+env_ordre[0,i]*batiment.materiaux[0,i]*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
								som_env_energie<-som_env_energie+env_ordre[1,i]*batiment.materiaux[0,i]*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
								som_env_co2<-som_env_co2+env_ordre[2,i]*batiment.materiaux[0,i]*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
								tot_cout<-tot_cout+cout_ordre[3,i]*batiment.materiaux[0,i]*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
								tot_env_eau<-tot_env_eau+env_ordre[0,i]*batiment.materiaux[0,i]*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
								tot_env_energie<-tot_env_energie+env_ordre[1,i]*batiment.materiaux[0,i]*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
								tot_env_co2<-tot_env_co2+env_ordre[2,i]*batiment.materiaux[0,i]*(note_ordre[5,i]+note_ordre[6,i]+note_ordre[7,i]);
								find_new_centre_valo<-true;
							}
						}
					}
					tot_materiaux<-tot_materiaux-batiment.materiaux[0,i];
				batiment.materiaux[0,i]<-0.0;
				}
				
			}
		}
	}
				
	reflex MAJ_bat when:nb_building!=0 and actif=true { // On met à jour le montant total des matériaux. Si cela vaut 0 on passe la couleur du bâtiment à noir
		materiaux<-batiment.mat_total;
		if materiaux=0.0{
			actif<-false;
			batiment.color<-#black;
			retour<-true;
			nb_building<-nb_building-1;
			
		}
	}
	reflex retour_entreprise when:retour=true{
		the_target<-any_location_in(entreprise_demolition);
		retour<-false;
	}
	reflex change when:nb_contrat!=0 and depart=true { // Quand le bâtiment est déconstruit on reprend un nouveau bâtiment dans la liste
		find_new_deconstruction<-false;
		list_bat<-list(deconstruction);
		depart<-false;
		loop while:find_new_deconstruction=false{
			//batiment<-one_of(list_bat);
			batiment<-deconstruction(15);
			if( batiment.deconstruction=false){
				the_target<-any_location_in(batiment);
				write name;
				write batiment.name;
				nb_contrat<-nb_contrat-1;
				batiment.deconstruction<-true;
				batiment.nb_employe<-batiment.nb_employe+1;
				batiment.entreprise_principale<-entreprise_demolition;
				find_new_deconstruction<-true;
				materiaux<-batiment.mat_total;
				id_person<-batiment.id_building;
			}
			
		}
	}
	
	reflex move when: the_target !=nil{ // permet le déplacement de l'agent vers le nouveau bâtiment
		do goto target:the_target ;
		if the_target=location and materiaux!=0.0{
			actif<-true;
			the_target<-nil;
			loop i from:0 to:length(list_traitement)-1{   // On calcule la distance entre l'agent et tous les centres de tri existant
				ask list_traitement at i{
					myself.distance[i]<-self distance_to myself;
				}
			}
			loop i from:0 to:length(list_enfouissement)-1{   // On calcule la distance entre l'agent et tous les centres de stockage existant
				ask list_enfouissement at i{
					myself.distance_enfouissement[i]<-self distance_to myself;
				}
			}
			loop i from:0 to:length(list_valo)-1{   // On calcule la distance entre l'agent et tous les centres de valorisation existant
				ask list_valo at i{
					myself.distance_valo[i]<-self distance_to myself;
				}
			}
			loop i from:0 to:length(list_reemploi)-1{   // On calcule la distance entre l'agent et tous les centres de reemploi existant
				ask list_reemploi at i{
					myself.distance_reemploi[i]<-self distance_to myself;
				}
			}
			tmp_dist<-copy(distance);
			tmp_centre<-copy(list_traitement);
			distance<-distance sort_by (each); // On classe par ordre croissant les distances
			loop i from:0 to: length(list_traitement)-1{ // On classe  la liste des centre de tri par ordre croissant de distance
				loop j from:0 to: length(list_traitement)-1{
					if(distance[i]=tmp_dist[j]){
						list_traitement[i]<-tri(tmp_centre[j]);
					}
				}
			}
			tmp_dist<-copy(distance_enfouissement);
			tmp_centre<-copy(list_enfouissement);
			distance_enfouissement<-distance_enfouissement sort_by (each); // On classe par ordre croissant les distances
			loop i from:0 to: length(list_enfouissement)-1{ // On prend le centre de stockage le plus proche
					if(distance_enfouissement[0]=tmp_dist[i]){
						centre_enfouissement<-enfouissement(tmp_centre[i]);
					}
				
			}
			tmp_dist<-copy(distance_valo);
			tmp_centre<-copy(list_valo);
			distance_valo<-distance_valo sort_by (each); // On classe par ordre croissant les distances
			loop i from:0 to: length(list_valo)-1{ // On classe  la liste des centre de valorisation par ordre croissant de distance
				loop j from:0 to: length(list_valo)-1{
					if(distance_valo[i]=tmp_dist[j]){
						list_valo[i]<-valorisation(tmp_centre[j]);
					}
				}
			}
			tmp_dist<-copy(distance_reemploi);
			tmp_centre<-copy(list_reemploi);
			distance_reemploi<-distance_reemploi sort_by (each); // On classe par ordre croissant les distances
			loop i from:0 to: length(list_reemploi)-1{ // On classe  la liste des centre de reemploi par ordre croissant de distance
				loop j from:0 to: length(list_reemploi)-1{
					if(distance_reemploi[i]=tmp_dist[j]){
						list_reemploi[i]<-reemploi(tmp_centre[j]);
					}
				}
			}
			centre_trie<-list_traitement[0]; // Le centre de tri principal de l'agent est celui le plus proche
			centre_val<-list_valo[0]; // Le centre de valo principal de l'agent est celui le plus proche
			centre_reemploi<-list_reemploi[0];
		}
		else if the_target=location and materiaux=0.0{
			the_target<-nil;
			depart<-true;
		}
	}
	
	reflex die when:nb_contrat=0 and dead(batiment){ // Quand tous les bâtiments sont déconstruits on tue les unité opérative
		nb_groupe<-nb_groupe-1;
		do die;
	}
	
	aspect base{
		draw circle(60) color: color border: #black;
	}
}

experiment RECONVERT type: gui {
	parameter "Note" var: note min:0 max:4 category: "Parametres" ;
	parameter "Nb heure" var: nb_heure min:1  category: "Parametres" ;
	parameter "Nb_ouvrier" var: nb_ouvrier min:1  category: "Parametres" ;
	parameter "decay_building" var: decay_building  category: "Parametres" ;
	output {
		display VISUEL type:opengl {
			species tri aspect: base ;
			species enfouissement aspect: base ;
			species valorisation aspect: base ;
			species deconstruction aspect: base ;
			species reemploi aspect:base;
			species entreprise_deconstruction aspect:base;
			species people aspect: base;
			//species building aspect:base;
		}
		
		display OCCUPATION refresh:every(5#cycles){
			chart "Taux d'occupation des centres  (en %)" type:series size:{1,0.5} position:{0,0}{
				data "tri" value:(1-(total_capacite/init_tot_capacite))*100 color:#red;
				data "valo" value:(1-(total_capacite2/init_tot_capacite2))*100 color:#blue;
				data "stock" value:(1-(total_capacite3/init_tot_capacite3))*100 color:#green;
				data "reemploi" value:(1-(total_capacite4/init_tot_capacite4))*100 color:#black;
			}
			chart "Nombre de tonnes restantes à déconstruire" type:series size:{1,0.5} position:{0,0.5}{
				data "matériaux restants" value:tot_materiaux color:#red;
			}
		}
		
		display GAINS refresh:every(1#cycles){
			chart "GAINS pour différents critères" type:series size:{1,0.5} position:{0,0}{
				data "Gain en €" value:tot_cout color:#red;
				data "Gain en eau(m³/t)" value:tot_env_eau color:#blue;
				data "Gain en energie(MJ/t)" value:tot_env_energie color:#green;
				data "Gain en CO2(t CO2 eq/t)" value:tot_env_co2 color:#black;
				
			}
		}
		
		display MAT_SORTIE refresh:every(1#cycles){
			chart "Nombre de tonnes évacuée dans les centre de tri" type:series size:{1,0.5} position:{0,0}{
				data "tri" value:tot_envoi_tri color:#red;
				
			}
			chart "Nombre de tonnes évacuée dans les centre d'enfouissement" type:series size:{1,0.5} position:{0,0.5}{
				data "Stockage ISDI" value:tot_stockage_ISDI color:#red;
				data "Stockage ISDND" value:tot_stockage_ISDND color:#blue;
				data "Stockage ISDD" value:tot_stockage_ISDD color:#green;
				data "Autre filière d'elimination" value:tot_autre_elimination color:#black;
				
				}
			
		}
		display MAT_SORTIE2 refresh:every(1#cycles){
			chart "Nombre de tonnes évacuée dans les centre de valorisation" type:series size:{1,0.5} position:{0,0}{
				data "Valorisation matière" value:tot_valo_matiere color:#red;
				data "Valorisation energétique" value:tot_valo_energetique color:#blue;
				data "REP" value:tot_REP color:#green;
				
			}
			chart "Nombre de tonnes évacuée dans les centre de reemploi" type:series size:{1,0.5} position:{0,0.5}{
				data "Réemploi sur site" value:tot_reemploi_site color:#red;
				data "Réemploi hors site" value:tot_reemploi_hors_site color:#blue;
				data "Réutilisation sur site" value:tot_reutilisation_site color:#green;
				data "Réutilisation hors site" value:tot_reutilisation_hors_site color:#black;
				
			}
			
		}
		
		monitor "Nombre de bâtiments" value: nb_building;
		monitor "Nombre de contrat" value: nb_contrat;
		monitor "Nombre d'ouvrier" value: nb_groupe;
		monitor "Nombre de centre de tri" value: nb_tri;
		monitor "Nombre de centre d'enfouissement" value: nb_stockage;
		monitor "Nombre de centre de réemploi" value: nb_reemploi;
		monitor "Nombre d'entreprise de demolition" value: nb_demolition;
		monitor "Nombre de centre de valorisation" value: nb_valo;
	}
	reflex test{
		tot_envoi_tri<-0.0;
		tot_cout<-0.0;
		tot_env_eau<-0.0;
		tot_env_energie<-0.0;
		tot_env_co2<-0.0;
		tot_stockage_ISDI<-0.0;
		tot_stockage_ISDND<-0.0;
		tot_stockage_ISDD<-0.0;
		tot_autre_elimination<-0.0;
		tot_valo_matiere<-0.0;
		tot_valo_energetique<-0.0;
		tot_REP<-0.0;
		tot_reemploi_site<-0.0;
		tot_reemploi_hors_site<-0.0;
		tot_reutilisation_site<-0.0;
		tot_reutilisation_hors_site<-0.0;
	}
}