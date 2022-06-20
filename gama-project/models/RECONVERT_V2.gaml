


model RECONVERTV2


global {
	file shape_file_buildings <- file("../includes/lille.shp"); // Fichier shape contenant les bâtiments de la zone à étudier
	file shape_file_bounds <- file("../includes/bounds.shp"); //Fichier shape d'un rectangle contenant la zone choisi
	file shape_file_tri <- file("../includes/centre_tri.shp"); //Fichier shape d'un rectangle contenant la zone choisi
	file shape_file_stockage <- file("../includes/centre_stockage.shp"); //Fichier shape d'un rectangle contenant la zone choisi
	file shape_file_valo <- file("../includes/centre_valo.shp"); //Fichier shape d'un rectangle contenant la zone choisi
	file ordre_mat <- csv_file("../includes/001ORDER.csv");// Fichier contenant l'ordre de sortie des matériaux
	//Fichiers avec le pourcentage de sorti des matériaux en fonction de la note
	file note0<-csv_file("../includes/002NOTE0.csv");
	file note1<-csv_file("../includes/003NOTE1.csv");
	file note2<-csv_file("../includes/004NOTE2.csv");
	file note3<-csv_file("../includes/005NOTE3.csv");
	file note4<-csv_file("../includes/006NOTE4.csv");
	file couts<-csv_file("../includes/007COUTS.csv");
	geometry shape <- envelope(shape_file_bounds); //Limite à la zone simulée 
	float step <- 0.5#day; //correspond au temps entre chaque cycle 
	int nb_people<-10; // nombre d'unité opérative  
	int id<-0; //l'id de tout les bâtiment
	int nb_building<-0; // calcul en temps réel le nombre de bâtiment qui reste à déconstruire 
	int nb_contrat<-0; // calcul en temps réel le nombre de contrat qui reste 
	float total_capacite<-0.0;// Permet de calculer le taux d'occupation des centres de tri
	float total_capacite2<-0.0; // Permet de calculer le taux d'occupation des centres de valo
	float total_capacite3<-0.0; // Permet de calculer le taux d'occupation des centres de stockage
	float init_tot_capacite<-0.0;
	float init_tot_capacite2<-0.0;
	float init_tot_capacite3<-0.0;
	int nb_stockage<-0; // calcul le nombre de centre de stockage
	int nb_valo<-0;//calcul le nombre de centre de valo
	int nb_tri<-0; //calcul le nombre de centre de tri
	float pourcentage_tri<-0.7; // Pourcentage du nombre de tonne envoyé du centre de tri vers le centre de stockage/valorisation
	float decay_tri<-2.0; //Règle le nombre de tonne éliminé par step dans les centres de tri
	float decay_valo<-2.0;//Règle le nombre de tonne éliminé par step dans les centres de valorisation
	float decay_building<-8.0; //nombre de tonne de matériaux déconstruit à chaque step (influ sur la vitesse de la déconstruction et sur le taux d'occupation des centres)
	matrix<float> note_ordre<-nil; 
	matrix<float> cout_ordre<-nil;
	float som_cout<-0.0;
	
	
	init {
		matrix<string> matrix_ordre <- matrix(ordre_mat); // On récupère le tableau de l'ordre de sorti et on enlève les "" propre aux fichiers CSV
		loop i from: 0 to: matrix_ordre.rows -1{
			matrix_ordre[0,i]<-copy_between(matrix_ordre[0,i],1,length(matrix_ordre[0,i]));
			matrix_ordre[2,i]<-copy_between(matrix_ordre[2,i],0,1);
		}
		matrix<string> copy_mat<-copy(matrix_ordre);
		matrix<string> matrix_note<-matrix(note0);// Idem ici il s'agit du tableau de note/ IL FAUT CHANGER LE NOMBRE APRES "matrix(note*)" POUR CHANGER LE FICHIER LU 
		
		loop i from: 0 to: matrix_note.rows -1{
			matrix_note[0,i]<-copy_between(matrix_note[0,i],1,length(matrix_note[0,i]));
			matrix_note[11,i]<-copy_between(matrix_note[2,i],0,length(matrix_note[0,i])-1);
		}
		
		matrix<string> matrix_cout<-matrix(couts);
		
		loop i from: 0 to: matrix_cout.rows -1{
			matrix_cout[0,i]<-copy_between(matrix_cout[0,i],1,length(matrix_cout[0,i]));
			matrix_cout[5,i]<-copy_between(matrix_cout[5,i],0,length(matrix_cout[5,i])-1);
		}
		
		point size<-point([1,matrix_ordre.rows]); // On ordonne le fichier par ordre de sorti
		int nb<-0;
		loop i from: 1 to: 8{
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
		point size2<-point([matrix_note.columns,10]);
		note_ordre<-matrix_with(size2,0.0);
		
		
		loop i from: 0 to: matrix_note.columns-1{ // On ordonne en fonction de l'ordre de sorti les pourcentages
				loop j from:0 to:matrix_note.columns-1{
					if(matrix_note[i,1]=matrix_ordre[1,j]){
						loop k from:2 to: matrix_note.rows-2{
							note_ordre[j,k-2]<-float(matrix_note[i,k]);
						}
					}	
				}
				
		}
		note_ordre<-transpose(note_ordre);
		
		matrix_cout<-transpose(matrix_cout);
		point size3<-[matrix_cout.columns,4];
		cout_ordre<-matrix_with(size3,0.0);
		
		loop i from: 0 to: matrix_cout.columns-1{
				loop j from:0 to:matrix_cout.columns-1{
					if(matrix_cout[i,1]=matrix_ordre[1,j]){
						loop k from:2 to: matrix_cout.rows-1{
							cout_ordre[j,k-2]<-float(matrix_cout[i,k]);
						}
					}	
				}
				
		}
		cout_ordre<-transpose(cout_ordre);
		/*
		loop i from: 0 to: note_ordre.rows -1{
			write"essai"+decay_building*(note_ordre[3,i]+note_ordre[4,i]+note_ordre[5,i]);
			loop j from: 0 to: note_ordre.columns -1{

				write "data rows:"+ i +" colums:" + j + " = " + note_ordre[j,i];
	
				
			}	

		}*/
		
		create centre_stockages from:shape_file_stockage{ // creation des centres de stockages avec une forte capacité
					capacite<-10000.0;	
					total_capacite3<-total_capacite3+capacite;
					init_tot_capacite3<-init_tot_capacite3+capacite;
					nb_stockage<-nb_stockage+1;
					materiaux<-matrix_with(size,0.0);
					loop i from:0 to:materiaux.rows-1{
						materiaux[0,i]<-0;
					}	
		}
		create centre_valo from: shape_file_valo{ //création des centres de valorisation
			capacite<-70.0;
			total_capacite2<-total_capacite2+capacite;
			init_tot_capacite2<-init_tot_capacite2+capacite;
				nb_valo<-nb_valo+1;
				materiaux<-matrix_with(size,0.0);
					loop i from:0 to:materiaux.rows-1{
						materiaux[0,i]<-0;
					}
		}
		
		create centre_tri from:shape_file_tri{ // creation des centres de tri
			capacite<-70.0;
			total_capacite<-total_capacite+capacite;
			init_tot_capacite<-init_tot_capacite+capacite;
				nb_tri<-nb_tri+1;
				materiaux<-matrix_with(size,0.0);
					loop i from:0 to:materiaux.rows-1{
						materiaux[0,i]<-0;
					}
			list_valo<-list(centre_valo);
			distance_stock<-list_with(length(centre_stockages),0.0);
			distance_valo<-list_with(length(centre_valo),0.0);
			loop i from:0 to:length(centre_stockages)-1{   // On calcule la distance entre le centre et tous les centres de stockage existant
				ask centre_stockages at i{
					myself.distance_stock[i]<-self distance_to myself;
				}
			}
			loop i from:0 to:length(list_valo)-1{   // On calcule la distance entre l'agent et tous les centres de valorisation existant
				ask list_valo at i{
					myself.distance_valo[i]<-self distance_to myself;
				}
			}
			
			tmp_dist<-copy(distance_stock);
			tmp_centre<-copy(list(centre_stockages));
			distance_stock<-distance_stock sort_by (each); // On classe par ordre croissant les distances
			loop i from:0 to: length(centre_stockages)-1{ // On prend le centre de stockage le plus proche
					if(distance_stock[0]=tmp_dist[i]){
						centre_stock<-tmp_centre[i];
					}
			}
			tmp_dist<-copy(distance_valo);
			tmp_centre<-copy(list_valo);
			distance_valo<-distance_valo sort_by (each); // On classe par ordre croissant les distances
			loop i from:0 to: length(list_valo)-1{ // On classe  la liste des centre de valorisation par ordre croissant de distance
				loop j from:0 to: length(list_valo)-1{
					if(distance_valo[i]=tmp_dist[j]){
						list_valo[i]<-tmp_centre[j];
					}
				}
			}
			centre_val<-list_valo[0];
			
		}
		
		create deconstruction from:shape_file_buildings{ // création des bâtiments à déconstruire
			id_building<-id+1;
			id<-id+1;
			nb_building<-nb_building+1;
			nb_contrat<-nb_contrat+1;
			materiaux<-matrix_with(size,0.0);
				loop i from:0 to:materiaux.rows-1{
					materiaux[0,i]<-rnd(30.0);
					mat_total<-mat_total+materiaux[0,i];
				}
		}
		
		create people number: nb_people { // creation des unités opératives
			batiment<-one_of(deconstruction);
			location <- any_location_in (batiment); // on affecte à l'agent une localisation aléatoire en choississant 1 bâtiment de la liste
			nb_contrat<-nb_contrat-1;
			id_person<-batiment.id_building;
			batiment.deconstruction<-true;
			list_bat<-list(deconstruction);
			materiaux<-batiment.mat_total;
			list_traitement<-list(centre_tri);
			list_stockage<-list(centre_stockages);
			list_valo<-list(centre_valo);
			distance<-list_with(length(list_traitement),0.0);
			distance_stock<-list_with(length(list_stockage),0.0);
			distance_valo<-list_with(length(list_valo),0.0);
			loop i from:0 to:length(list_traitement)-1{   // On calcule la distance entre l'agent et tous les centres de tri existant
				ask list_traitement at i{
					myself.distance[i]<-self distance_to myself;
				}
			}
			loop i from:0 to:length(list_stockage)-1{   // On calcule la distance entre l'agent et tous les centres de stockage existant
				ask list_stockage at i{
					myself.distance_stock[i]<-self distance_to myself;
				}
			}
			loop i from:0 to:length(list_valo)-1{   // On calcule la distance entre l'agent et tous les centres de valorisation existant
				ask list_valo at i{
					myself.distance_valo[i]<-self distance_to myself;
				}
			}
			tmp_dist<-copy(distance);
			tmp_centre<-copy(list_traitement);
			distance<-distance sort_by (each); // On classe par ordre croissant les distances
			loop i from:0 to: length(list_traitement)-1{ // On classe  la liste des centre de tri par ordre croissant de distance
				loop j from:0 to: length(list_traitement)-1{
					if(distance[i]=tmp_dist[j]){
						list_traitement[i]<-tmp_centre[j];
					}
				}
			}
			tmp_dist<-copy(distance_stock);
			tmp_centre<-copy(list_stockage);
			distance_stock<-distance_stock sort_by (each); // On classe par ordre croissant les distances
			loop i from:0 to: length(list_stockage)-1{ // On prend le centre de stockage le plus proche
					if(distance_stock[0]=tmp_dist[i]){
						centre_stock<-tmp_centre[i];
					}
				
			}
			tmp_dist<-copy(distance_valo);
			tmp_centre<-copy(list_valo);
			distance_valo<-distance_valo sort_by (each); // On classe par ordre croissant les distances
			loop i from:0 to: length(list_valo)-1{ // On classe  la liste des centre de valorisation par ordre croissant de distance
				loop j from:0 to: length(list_valo)-1{
					if(distance_valo[i]=tmp_dist[j]){
						list_valo[i]<-tmp_centre[j];
					}
				}
			}
			centre_trie<-list_traitement[0]; // Le centre de tri principal de l'agent est celui le plus proche
			centre_val<-list_valo[0]; // le centre de valorisation le plus proche devient le principal
			speed<-50#km/#h; // Correspond à la vitesse de déplacement de l'agent lors du changement de bâtiment
		}
	}
	
}

species building { 
	rgb color;
	float mat_total<-0.0; // Calcul du total de matériaux restant 
	float capacite; // Pour les centre de tri correspond à la capacité maximale du centre
	matrix<float>  materiaux<-nil; // liste de tous les matériaux existant
	int id_building; // id du batiment
	
	
	reflex tot{ // calcul le total de matériaux restant 
		mat_total<-0.0;
		loop i from:0 to:materiaux.rows-1{
			mat_total<-mat_total+materiaux[0,i];
		}
	
	}	
	
	reflex die when: color=#black{  // Si le bâtiment a finit d'être déconstruit on le tue
		do die;
	}
	aspect base {  
		draw shape color: color ;
	}
}

species centre_stockages parent:building {  // les centres de stockage sont passifs il n'y a pas de sorti
	rgb color<-#green;
	
}

species entreprise parent:building{
	
}

species centre_tri parent:building {  // les centres de tri vont disparaître une certaine quantité par step
	rgb color<-#red;
	centre_stockages centre_stockage<-nil;
	list<float>distance_stock<-nil;
	list<float>distance_valo<-nil;
	list<centre_valo>list_valo<-nil;
	list<float> tmp_dist<-nil;
	list<building> tmp_centre<-nil;
	centre_stockages centre_stock<-nil;
	centre_valo centre_val<-nil;
	bool find_new_centre_valo<-false;
	reflex decay{
		loop i from:0 to:materiaux.rows-1{
			find_new_centre_valo<-false;
			if(materiaux[0,i]>decay_tri){
				centre_stock.materiaux[0,i]<-centre_stock.materiaux[0,i] + pourcentage_tri*decay_tri;
				centre_stock.capacite<-centre_stock.capacite-pourcentage_tri*decay_tri;
				total_capacite3<-total_capacite3-pourcentage_tri*decay_tri;
				som_cout<-som_cout+cout_ordre[2,i]*pourcentage_tri*decay_tri;
				if(centre_val.capacite>=(1-pourcentage_tri)*decay_tri){
					centre_val.materiaux[0,i]<-centre_val.materiaux[0,i] + (1-pourcentage_tri)*decay_tri;
					centre_val.capacite<-centre_val.capacite-(1-pourcentage_tri)*decay_tri;
					total_capacite2<-total_capacite2-(1-pourcentage_tri)*decay_tri;
					som_cout<-som_cout+cout_ordre[3,i]*(1-pourcentage_tri)*decay_tri;
				}
				else{ 
						loop j from:0 to:length(list_valo)-1{
							if(list_valo[j].capacite>=(1-pourcentage_tri)*decay_tri and find_new_centre_valo=false){
								list_valo[j].materiaux[0,i]<-list_valo[j].materiaux[0,i]+(1-pourcentage_tri)*decay_tri;
								list_valo[j].capacite<-list_valo[j].capacite-(1-pourcentage_tri)*decay_tri;
								total_capacite2<-total_capacite2-(1-pourcentage_tri)*decay_tri;
								som_cout<-som_cout+cout_ordre[3,i]*(1-pourcentage_tri)*decay_tri;
								find_new_centre_valo<-true;
							}
						}
					}
				materiaux[0,i]<-materiaux[0,i]-decay_tri;
				capacite<-capacite+decay_tri;
				total_capacite<-total_capacite+decay_tri;
			}
			else if(materiaux[0,i]>0.0){
				centre_stock.materiaux[0,i]<-centre_stock.materiaux[0,i] + pourcentage_tri*materiaux[0,i];
				centre_stock.capacite<-centre_stock.capacite-pourcentage_tri*materiaux[0,i];
				total_capacite3<-total_capacite3-pourcentage_tri*materiaux[0,i];
				som_cout<-som_cout+cout_ordre[2,i]*pourcentage_tri*materiaux[0,i];
				if(centre_val.capacite>=(1-pourcentage_tri)*materiaux[0,i]){
					centre_val.materiaux[0,i]<-centre_val.materiaux[0,i] + (1-pourcentage_tri)*materiaux[0,i];
					centre_val.capacite<-centre_val.capacite-(1-pourcentage_tri)*materiaux[0,i];
					total_capacite2<-total_capacite2-(1-pourcentage_tri)*materiaux[0,i];
					som_cout<-som_cout+cout_ordre[3,i]*(1-pourcentage_tri)*materiaux[0,i];
				}
				else{ 
						loop j from:0 to:length(list_valo)-1{
							if(list_valo[j].capacite>=(1-pourcentage_tri)*materiaux[0,i] and find_new_centre_valo=false){
								list_valo[j].materiaux[0,i]<-list_valo[j].materiaux[0,i]+(1-pourcentage_tri)*materiaux[0,i];
								list_valo[j].capacite<-list_valo[j].capacite-(1-pourcentage_tri)*materiaux[0,i];
								total_capacite2<-total_capacite2-(1-pourcentage_tri)*materiaux[0,i];
								som_cout<-som_cout+cout_ordre[3,i]*(1-pourcentage_tri)*materiaux[0,i];
								find_new_centre_valo<-true;
							}
						}
					}
				capacite<-capacite+materiaux[0,i];
				total_capacite<-total_capacite+materiaux[0,i];
				materiaux[0,i]<-0.0;
			}
		}
	}
}

species centre_valo parent:building { // les centres de valorisation vont disparaître une certaine quantité par step
	rgb color<-#orange;
	reflex decay {
		loop i from:0 to:materiaux.rows-1{
			if(materiaux[0,i]>decay_valo){
				materiaux[0,i]<-materiaux[0,i]-decay_valo;
				capacite<-capacite+decay_valo;
				total_capacite2<-total_capacite2+decay_valo;
			}
			else if(materiaux[0,i]>0.0){
				capacite<-capacite+materiaux[0,i];
				total_capacite2<-total_capacite2+materiaux[0,i];
				materiaux[0,i]<-0.0;
			}
		}
		
	}
	
	
	
}

species deconstruction parent:building { 
	bool deconstruction<-false; // Si le bâtiment est en cours de déconstruction
	rgb color<-#blue;
}

species people skills:[moving]{ // Unité opérative
	rgb color<- #yellow;
	float materiaux; // Correspond au total de matériaux restant
	int id_person;
	deconstruction batiment<-nil; // bâtiment sur lequel l'agent travaille
	centre_tri centre_trie<-nil; // centre de tri le plus proche
	centre_stockages centre_stock<-nil; // centre de stockage le plus proche
	centre_valo centre_val<-nil;
	point the_target<-nil; //Pointe sur le prochain bâtiment à déconstruire
	list<deconstruction> list_bat<-nil; // liste de tous les bâtiments
	list<centre_tri>list_traitement<-nil; // liste de tous les centres de tri
	list<building> tmp_centre<-nil;
	list<centre_stockages>list_stockage<-nil;
	list<centre_valo>list_valo<-nil;
	list<float> distance<-nil; // liste des distances aux centres de tri
	list<float>distance_stock<-nil;
	list<float>distance_valo<-nil;
	list<float> tmp_dist<-nil;
	bool find_new_centre; // Pour trouver un autre centre si le plus proche est rempli
	bool sol;
	bool find_new_centre_valo;
	
	// Les decay diminue le matériaux d'un certain nombre et l'envoi dans les centres  les plus proche
	reflex decay when: nb_building!=0 and batiment.color=#blue {
		find_new_centre<-false;
		find_new_centre_valo<-false;
		sol<-false;
		loop i from:0 to:batiment.materiaux.rows -1{
			if(batiment.materiaux[0,i]!=0.0 and sol=false){
				sol<-true;
				if (batiment.materiaux[0,i]>=decay_building){
					batiment.materiaux[0,i]<-batiment.materiaux[0,i] -decay_building;
					// On envoit une partie en stockage
					centre_stock.materiaux[0,i]<-centre_stock.materiaux[0,i]+decay_building*(note_ordre[6,i]+note_ordre[7,i]+note_ordre[8,i]+note_ordre[9,i]);
					centre_stock.capacite<-centre_stock.capacite-decay_building*(note_ordre[6,i]+note_ordre[7,i]+note_ordre[8,i]+note_ordre[9,i]);
					total_capacite3<-total_capacite3-decay_building*(note_ordre[6,i]+note_ordre[7,i]+note_ordre[8,i]+note_ordre[9,i]);
					som_cout<-som_cout+cout_ordre[2,i]*decay_building*(note_ordre[6,i]+note_ordre[7,i]+note_ordre[8,i]+note_ordre[9,i]);
					// Un autre partie en centre de tri
					if(centre_trie.capacite>=(decay_building*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]))){
						centre_trie.materiaux[0,i]<-centre_trie.materiaux[0,i]+decay_building*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]);
						centre_trie.capacite<-centre_trie.capacite-decay_building*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]);
						total_capacite<-total_capacite-decay_building*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]);
						som_cout<-som_cout+cout_ordre[0,i]*decay_building*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]);
					}
					else{ // Si le centre de tri le plus proche n'a plus la capacité on va chercher le centre de tri le plus proche ayant la capacité nécessaire
						loop j from:0 to:length(list_traitement)-1{
							if(list_traitement[j].capacite>=decay_building*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]) and find_new_centre=false){
								list_traitement[j].materiaux[0,i]<-list_traitement[j].materiaux[0,i]+decay_building*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]);
								list_traitement[j].capacite<-list_traitement[j].capacite-decay_building*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]);
								total_capacite<-total_capacite-decay_building*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]);
								som_cout<-som_cout+cout_ordre[0,i]*decay_building*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]);
								find_new_centre<-true;
							}
						}
					}
					// et le reste en valo
					if(centre_val.capacite>=(decay_building*(note_ordre[3,i]+note_ordre[4,i]+note_ordre[5,i]))){
						centre_val.materiaux[0,i]<-centre_val.materiaux[0,i]+decay_building*(note_ordre[3,i]+note_ordre[4,i]+note_ordre[5,i]);
						centre_val.capacite<-centre_val.capacite-decay_building*(note_ordre[3,i]+note_ordre[4,i]+note_ordre[5,i]);
						total_capacite2<-total_capacite2-decay_building*(note_ordre[3,i]+note_ordre[4,i]+note_ordre[5,i]);
						som_cout<-som_cout+cout_ordre[3,i]*decay_building*(note_ordre[3,i]+note_ordre[4,i]+note_ordre[5,i]);
					}
					else{ // Si le centre de tri le plus proche n'a plus la capacité on va chercher le centre de tri le plus proche ayant la capacité nécessaire
						loop j from:0 to:length(list_valo)-1{
							if(list_valo[j].capacite>=decay_building*(note_ordre[3,i]+note_ordre[4,i]+note_ordre[5,i]) and find_new_centre_valo=false){
								list_valo[j].materiaux[0,i]<-list_valo[j].materiaux[0,i]+decay_building*(note_ordre[3,i]+note_ordre[4,i]+note_ordre[5,i]);
								list_valo[j].capacite<-list_valo[j].capacite-decay_building*(note_ordre[3,i]+note_ordre[4,i]+note_ordre[5,i]);
								total_capacite2<-total_capacite2-decay_building*(note_ordre[3,i]+note_ordre[4,i]+note_ordre[5,i]);
								som_cout<-som_cout+cout_ordre[3,i]*decay_building*(note_ordre[3,i]+note_ordre[4,i]+note_ordre[5,i]);
								find_new_centre_valo<-true;
							}
						}
					}
				}
				else{
					centre_stock.materiaux[0,i]<-centre_stock.materiaux[0,i]+batiment.materiaux[0,i]*(note_ordre[6,i]+note_ordre[7,i]+note_ordre[8,i]+note_ordre[9,i]);
					centre_stock.capacite<-centre_stock.capacite-batiment.materiaux[0,i]*(note_ordre[6,i]+note_ordre[7,i]+note_ordre[8,i]+note_ordre[9,i]);
					total_capacite3<-total_capacite3-batiment.materiaux[0,i]*(note_ordre[6,i]+note_ordre[7,i]+note_ordre[8,i]+note_ordre[9,i]);
					som_cout<-som_cout+cout_ordre[2,i]*batiment.materiaux[0,i]*(note_ordre[6,i]+note_ordre[7,i]+note_ordre[8,i]+note_ordre[9,i]);
					
					if(centre_trie.capacite>=(batiment.materiaux[0,i]*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]))){
						centre_trie.materiaux[0,i]<-centre_trie.materiaux[0,i]+batiment.materiaux[0,i]*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]);
						centre_trie.capacite<-centre_trie.capacite-batiment.materiaux[0,i]*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]);
						total_capacite<-total_capacite-batiment.materiaux[0,i]*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]);
						som_cout<-som_cout+cout_ordre[0,i]*batiment.materiaux[0,i]*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]);
					}
					else{ // Si le centre de tri le plus proche n'a plus la capacité on va chercher le centre de tri le plus proche ayant la capacité nécessaire
						loop j from:0 to:length(list_traitement)-1{
							if(list_traitement[j].capacite>=batiment.materiaux[0,i]*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]) and find_new_centre=false){
								list_traitement[j].materiaux[0,i]<-list_traitement[j].materiaux[0,i]+batiment.materiaux[0,i]*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]);
								list_traitement[j].capacite<-list_traitement[j].capacite-batiment.materiaux[0,i]*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]);
								total_capacite<-total_capacite-batiment.materiaux[0,i]*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]);
								som_cout<-som_cout+cout_ordre[0,i]*batiment.materiaux[0,i]*(note_ordre[0,i]+note_ordre[1,i]+note_ordre[2,i]);
								find_new_centre<-true;
							}
						}
					}
					if(centre_val.capacite>=(batiment.materiaux[0,i]*(note_ordre[3,i]+note_ordre[4,i]+note_ordre[5,i]))){
						centre_val.materiaux[0,i]<-centre_val.materiaux[0,i]+batiment.materiaux[0,i]*(note_ordre[3,i]+note_ordre[4,i]+note_ordre[5,i]);
						centre_val.capacite<-centre_val.capacite-batiment.materiaux[0,i]*(note_ordre[3,i]+note_ordre[4,i]+note_ordre[5,i]);
						total_capacite2<-total_capacite2-batiment.materiaux[0,i]*(note_ordre[3,i]+note_ordre[4,i]+note_ordre[5,i]);
						som_cout<-som_cout+cout_ordre[3,i]*batiment.materiaux[0,i]*(note_ordre[3,i]+note_ordre[4,i]+note_ordre[5,i]);
					}
					else{ // Si le centre de valo le plus proche n'a plus la capacité on va chercher le centre de tri le plus proche ayant la capacité nécessaire
						loop j from:0 to:length(list_valo)-1{
							if(list_valo[j].capacite>=batiment.materiaux[0,i]*(note_ordre[3,i]+note_ordre[4,i]+note_ordre[5,i]) and find_new_centre_valo=false){
								list_valo[j].materiaux[0,i]<-list_valo[j].materiaux[0,i]+batiment.materiaux[0,i]*(note_ordre[3,i]+note_ordre[4,i]+note_ordre[5,i]);
								list_valo[j].capacite<-list_valo[j].capacite-batiment.materiaux[0,i]*(note_ordre[3,i]+note_ordre[4,i]+note_ordre[5,i]);
								total_capacite2<-total_capacite2-batiment.materiaux[0,i]*(note_ordre[3,i]+note_ordre[4,i]+note_ordre[5,i]);
								som_cout<-som_cout+cout_ordre[3,i]*batiment.materiaux[0,i]*(note_ordre[3,i]+note_ordre[4,i]+note_ordre[5,i]);
								find_new_centre_valo<-true;
							}
						}
					}
				batiment.materiaux[0,i]<-0.0;
				}
				
			}
		}
	}
				
	reflex MAJ_bat when:nb_building!=0 and batiment.color!=#black { // On met à jour le montant total des matériaux. Si cela vaut 0 on passe la couleur du bâtiment à noir
		materiaux<-batiment.mat_total;
		id_person<-batiment.id_building;
		if materiaux=0{
			batiment.color<-#black;
			
		}
	}
	reflex change when:nb_contrat!=0 and batiment.color=#black { // Quand le bâtiment est déconstruit on reprend un nouveau bâtiment dans la liste
		list_bat<-list(deconstruction);
		if(list_bat!=nil){
			batiment<-one_of(list_bat);
			the_target<-any_location_in(batiment);
			nb_contrat<-nb_contrat-1;
			nb_building<-nb_building-1;
			batiment.deconstruction<-true;
		}
	}
	
	reflex move when: the_target !=nil{ // permet le déplacement de l'agent vers le nouveau bâtiment
		do goto target:the_target ;
		if the_target=location{
			the_target<-nil;
			loop i from:0 to:length(list_traitement)-1{   // On calcule la distance entre l'agent et tous les centres de tri existant
				ask list_traitement at i{
					myself.distance[i]<-self distance_to myself;
				}
			}
			loop i from:0 to:length(list_stockage)-1{   // On calcule la distance entre l'agent et tous les centres de stockage existant
				ask list_stockage at i{
					myself.distance_stock[i]<-self distance_to myself;
				}
			}
			loop i from:0 to:length(list_valo)-1{   // On calcule la distance entre l'agent et tous les centres de valorisation existant
				ask list_valo at i{
					myself.distance_valo[i]<-self distance_to myself;
				}
			}
			tmp_dist<-copy(distance);
			tmp_centre<-copy(list_traitement);
			distance<-distance sort_by (each); // On classe par ordre croissant les distances
			loop i from:0 to: length(list_traitement)-1{ // On classe  la liste des centre de tri par ordre croissant de distance
				loop j from:0 to: length(list_traitement)-1{
					if(distance[i]=tmp_dist[j]){
						list_traitement[i]<-tmp_centre[j];
					}
				}
			}
			tmp_dist<-copy(distance_stock);
			tmp_centre<-copy(list_stockage);
			distance_stock<-distance_stock sort_by (each); // On classe par ordre croissant les distances
			loop i from:0 to: length(list_stockage)-1{ // On prend le centre de stockage le plus proche
					if(distance_stock[0]=tmp_dist[i]){
						centre_stock<-tmp_centre[i];
					}
				
			}
			tmp_dist<-copy(distance_valo);
			tmp_centre<-copy(list_valo);
			distance_valo<-distance_valo sort_by (each); // On classe par ordre croissant les distances
			loop i from:0 to: length(list_valo)-1{ // On classe  la liste des centre de valorisation par ordre croissant de distance
				loop j from:0 to: length(list_valo)-1{
					if(distance_valo[i]=tmp_dist[j]){
						list_valo[i]<-tmp_centre[j];
					}
				}
			}
			centre_trie<-list_traitement[0]; // Le centre de tri principal de l'agent est celui le plus proche
			centre_val<-list_valo[0]; // Le centre de valo principal de l'agent est celui le plus proche
		}
	}
	
	reflex die when:nb_contrat=0 and batiment.color=#black{ // Quand tous les bâtiments sont déconstruits on tue les unité opérative
		nb_building<-nb_building-1;
		do die;
	}
	
	aspect base{
		draw circle(30) color: color border: #black;
	}
}

experiment road_traffic type: gui {
	output {
		display city_display type:opengl {
			species centre_tri aspect: base ;
			species centre_stockages aspect: base ;
			species centre_valo aspect: base ;
			species deconstruction aspect: base ;
			species people aspect: base;
		}
		
		display information refresh:every(5#cycles){
			chart "Taux d'occupation des centres  (en %)" type:series size:{1,0.5} position:{0,0}{
				data "tri" value:(1-(total_capacite/init_tot_capacite))*100 color:#red;
				data "valo" value:(1-(total_capacite2/init_tot_capacite2))*100 color:#blue;
				data "stock" value:(1-(total_capacite3/init_tot_capacite3))*100 color:#green;
			}
		}
		
		
		
		monitor "Number of building" value: nb_building;
		monitor "Number of tri" value: nb_tri;
		monitor "Number of stockage" value: nb_stockage;
		monitor "Number of valo" value: nb_valo;
		monitor "tot capacite" value: total_capacite;
		monitor "ini tot capacite" value: init_tot_capacite;
		monitor "cout total" value:som_cout;
	}
}