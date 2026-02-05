-- =====================================================
-- TABLE: AEROPORT
-- =====================================================
CREATE TABLE aeroport (
    id SERIAL PRIMARY KEY,
    code_iata VARCHAR(3) NOT NULL UNIQUE,
    nom VARCHAR(100) NOT NULL,
    ville VARCHAR(100) NOT NULL,
    pays VARCHAR(100) NOT NULL,
    adresse TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- TABLE: HOTEL
-- =====================================================
CREATE TABLE hotel (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(150) NOT NULL,
    adresse TEXT NOT NULL,
    ville VARCHAR(100) NOT NULL,
    code_postal VARCHAR(20),
    telephone VARCHAR(20),
    email VARCHAR(100),
    nombre_etoiles INT CHECK (nombre_etoiles BETWEEN 1 AND 5),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- TABLE: VOL
-- =====================================================
CREATE TABLE vol (
    id SERIAL PRIMARY KEY,
    numero_vol VARCHAR(20) NOT NULL,
    compagnie_aerienne VARCHAR(100) NOT NULL,
    aeroport_id INT NOT NULL REFERENCES aeroport(id),
    date_heure_depart TIMESTAMP,
    date_heure_arrivee TIMESTAMP,
    type_vol VARCHAR(20) CHECK (type_vol IN ('ARRIVEE', 'DEPART')),
    terminal VARCHAR(10),
    statut VARCHAR(20) DEFAULT 'PROGRAMME' CHECK (statut IN ('PROGRAMME', 'EN_VOL', 'ATTERRI', 'ANNULE', 'RETARDE')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- TABLE: CLIENT
-- =====================================================
CREATE TABLE client (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE,
    telephone VARCHAR(20) NOT NULL,
    numero_passeport VARCHAR(50),
    nationalite VARCHAR(50),
    adresse TEXT,
    hotel_id INT REFERENCES hotel(id),
    numero_chambre VARCHAR(20),
    date_checkin DATE,
    date_checkout DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- TABLE: CATEGORIE_VOITURE
-- =====================================================
CREATE TABLE categorie_voiture (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    capacite_passagers INT NOT NULL,
    capacite_bagages INT NOT NULL,
    tarif_base DECIMAL(10, 2) NOT NULL,
    tarif_km DECIMAL(10, 2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- TABLE: CHAUFFEUR
-- =====================================================
CREATE TABLE chauffeur (
    id SERIAL PRIMARY KEY,
    matricule VARCHAR(20) NOT NULL UNIQUE,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    telephone VARCHAR(20) NOT NULL,
    email VARCHAR(150),
    numero_permis VARCHAR(50) NOT NULL,
    date_expiration_permis DATE NOT NULL,
    statut VARCHAR(20) DEFAULT 'DISPONIBLE' CHECK (statut IN ('DISPONIBLE', 'EN_COURSE', 'REPOS', 'CONGE', 'INACTIF')),
    note_moyenne DECIMAL(3, 2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- TABLE: VOITURE
-- =====================================================
CREATE TABLE voiture (
    id SERIAL PRIMARY KEY,
    immatriculation VARCHAR(20) NOT NULL UNIQUE,
    marque VARCHAR(50) NOT NULL,
    modele VARCHAR(50) NOT NULL,
    annee INT NOT NULL,
    couleur VARCHAR(30),
    categorie_id INT NOT NULL REFERENCES categorie_voiture(id),
    kilometrage INT DEFAULT 0,
    statut VARCHAR(20) DEFAULT 'DISPONIBLE' CHECK (statut IN ('DISPONIBLE', 'EN_COURSE', 'MAINTENANCE', 'HORS_SERVICE')),
    date_derniere_revision DATE,
    date_prochaine_revision DATE,
    assurance_expiration DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- TABLE: DISPONIBILITE_VOITURE
-- Gestion des créneaux de disponibilité des voitures
-- =====================================================
CREATE TABLE disponibilite_voiture (
    id SERIAL PRIMARY KEY,
    voiture_id INT NOT NULL REFERENCES voiture(id),
    date_debut TIMESTAMP NOT NULL,
    date_fin TIMESTAMP NOT NULL,
    est_disponible BOOLEAN DEFAULT TRUE,
    motif_indisponibilite VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_dates CHECK (date_fin > date_debut)
);

-- =====================================================
-- TABLE: TRAJET
-- Définition des trajets possibles avec estimation de temps
-- =====================================================
CREATE TABLE trajet (
    id SERIAL PRIMARY KEY,
    hotel_id INT NOT NULL REFERENCES hotel(id),
    aeroport_id INT NOT NULL REFERENCES aeroport(id),
    distance_km DECIMAL(10, 2) NOT NULL,
    duree_estimee_minutes INT NOT NULL,
    duree_trafic_dense_minutes INT,
    description_itineraire TEXT,
    tarif_supplementaire DECIMAL(10, 2) DEFAULT 0,
    actif BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(hotel_id, aeroport_id)
);

-- =====================================================
-- TABLE: RESERVATION
-- Réservation principale (peut être sans voiture précise)
-- =====================================================
CREATE TABLE reservation (
    id SERIAL PRIMARY KEY,
    numero_reservation VARCHAR(20) NOT NULL UNIQUE,
    client_principal_id INT NOT NULL REFERENCES client(id),
    
    -- Type de trajet
    type_transfert VARCHAR(20) NOT NULL CHECK (type_transfert IN ('HOTEL_AEROPORT', 'AEROPORT_HOTEL')),
    
    -- Origine et destination
    hotel_id INT NOT NULL REFERENCES hotel(id),
    vol_id INT REFERENCES vol(id),
    aeroport_id INT NOT NULL REFERENCES aeroport(id),
    
    -- Horaires
    date_reservation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_heure_prise_en_charge TIMESTAMP NOT NULL,
    date_heure_arrivee_estimee TIMESTAMP,
    
    -- Voiture et chauffeur (peuvent être NULL si non assignés)
    voiture_id INT REFERENCES voiture(id),
    chauffeur_id INT REFERENCES chauffeur(id),
    categorie_demandee_id INT REFERENCES categorie_voiture(id),
    
    -- Informations passagers
    nombre_passagers INT NOT NULL DEFAULT 1,
    nombre_bagages INT DEFAULT 0,
    
    -- Tarification
    tarif_total DECIMAL(10, 2),
    acompte_paye DECIMAL(10, 2) DEFAULT 0,
    mode_paiement VARCHAR(30) CHECK (mode_paiement IN ('ESPECES', 'CARTE', 'VIREMENT', 'FACTURE_HOTEL')),
    
    -- Statut
    statut VARCHAR(30) DEFAULT 'EN_ATTENTE' CHECK (statut IN (
        'EN_ATTENTE',      -- Réservation créée, en attente de confirmation
        'CONFIRMEE',       -- Réservation confirmée
        'VOITURE_ASSIGNEE',-- Voiture et chauffeur assignés
        'EN_COURS',        -- Transfert en cours
        'TERMINEE',        -- Transfert terminé
        'ANNULEE',         -- Réservation annulée
        'NO_SHOW'          -- Client non présenté
    )),
    
    -- Informations supplémentaires
    commentaires TEXT,
    numero_vol_info VARCHAR(20),
    terminal_info VARCHAR(20),
    lieu_rdv TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- TABLE: RESERVATION_PASSAGER
-- Passagers supplémentaires pour une réservation
-- =====================================================
CREATE TABLE reservation_passager (
    id SERIAL PRIMARY KEY,
    reservation_id INT NOT NULL REFERENCES reservation(id) ON DELETE CASCADE,
    client_id INT REFERENCES client(id),
    
    -- Si le passager n'est pas un client enregistré
    nom VARCHAR(100),
    prenom VARCHAR(100),
    telephone VARCHAR(20),
    
    est_passager_principal BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- INDEX POUR OPTIMISATION
-- =====================================================
CREATE INDEX idx_reservation_date ON reservation(date_heure_prise_en_charge);
CREATE INDEX idx_reservation_statut ON reservation(statut);
CREATE INDEX idx_reservation_client ON reservation(client_principal_id);
CREATE INDEX idx_voiture_statut ON voiture(statut);
CREATE INDEX idx_voiture_categorie ON voiture(categorie_id);
CREATE INDEX idx_disponibilite_voiture ON disponibilite_voiture(voiture_id, date_debut, date_fin);
CREATE INDEX idx_chauffeur_statut ON chauffeur(statut);
CREATE INDEX idx_vol_date ON vol(date_heure_arrivee, date_heure_depart);
CREATE INDEX idx_client_hotel ON client(hotel_id);

-- =====================================================
-- INSERTION DE DONNEES DE TEST
-- =====================================================

-- Aéroports
INSERT INTO aeroport (code_iata, nom, ville, pays, adresse) VALUES
('TNR', 'Aéroport International d''Ivato', 'Antananarivo', 'Madagascar', 'Ivato, Antananarivo'),
('MJN', 'Aéroport d''Amborovy', 'Mahajanga', 'Madagascar', 'Amborovy, Mahajanga'),
('DIE', 'Aéroport d''Antsiranana', 'Antsiranana', 'Madagascar', 'Arrachart, Antsiranana');

-- Hôtels
INSERT INTO hotel (nom, adresse, ville, code_postal, telephone, nombre_etoiles, latitude, longitude) VALUES
('Carlton Madagascar', 'Rue Pierre Stibbe, Anosy', 'Antananarivo', '101', '+261 20 22 260 60', 5, -18.9137, 47.5228),
('Hotel Colbert', 'Rue Prince Ratsimamanga', 'Antananarivo', '101', '+261 20 22 202 02', 4, -18.9167, 47.5200),
('Radisson Blu', 'Route de l''aéroport', 'Antananarivo', '101', '+261 20 23 456 78', 5, -18.8500, 47.4800),
('Hotel Sakamanga', 'Rue Andrianary Ratianarivo', 'Antananarivo', '101', '+261 20 22 358 09', 3, -18.9120, 47.5260);

-- Catégories de voiture
INSERT INTO categorie_voiture (nom, description, capacite_passagers, capacite_bagages, tarif_base, tarif_km) VALUES
('ECONOMIQUE', 'Voiture économique standard', 4, 2, 50000, 500),
('CONFORT', 'Berline confortable', 4, 3, 80000, 700),
('VAN', 'Mini-van pour groupes', 7, 6, 120000, 1000),
('VIP', 'Véhicule luxe avec chauffeur', 4, 4, 200000, 1500),
('SUV', 'SUV tout terrain', 5, 4, 150000, 1200);

-- Chauffeurs
INSERT INTO chauffeur (matricule, nom, prenom, telephone, numero_permis, date_expiration_permis, statut) VALUES
('CHF001', 'RAKOTO', 'Jean', '+261 34 00 001 01', 'PERM-2020-001', '2027-12-31', 'DISPONIBLE'),
('CHF002', 'RABE', 'Marie', '+261 34 00 002 02', 'PERM-2020-002', '2026-06-30', 'DISPONIBLE'),
('CHF003', 'RANDRIA', 'Paul', '+261 34 00 003 03', 'PERM-2019-003', '2026-12-31', 'EN_COURSE'),
('CHF004', 'RASOA', 'Hery', '+261 34 00 004 04', 'PERM-2021-004', '2028-03-15', 'DISPONIBLE');

-- Voitures
INSERT INTO voiture (immatriculation, marque, modele, annee, couleur, categorie_id, kilometrage, statut) VALUES
('1234 TAA', 'Toyota', 'Corolla', 2022, 'Blanc', 1, 25000, 'DISPONIBLE'),
('2345 TAB', 'Toyota', 'Camry', 2023, 'Noir', 2, 15000, 'DISPONIBLE'),
('3456 TAC', 'Toyota', 'Hiace', 2021, 'Gris', 3, 45000, 'DISPONIBLE'),
('4567 TAD', 'Mercedes', 'Classe E', 2023, 'Noir', 4, 8000, 'DISPONIBLE'),
('5678 TAE', 'Toyota', 'Fortuner', 2022, 'Blanc', 5, 30000, 'EN_COURSE'),
('6789 TAF', 'Hyundai', 'Accent', 2021, 'Gris', 1, 55000, 'MAINTENANCE');

-- Trajets (estimation temps et distance)
INSERT INTO trajet (hotel_id, aeroport_id, distance_km, duree_estimee_minutes, duree_trafic_dense_minutes, description_itineraire) VALUES
(1, 1, 18.5, 35, 60, 'Carlton -> Route digue -> Aéroport Ivato'),
(2, 1, 17.0, 30, 55, 'Colbert -> Tunnel Ambohidahy -> Aéroport Ivato'),
(3, 1, 5.0, 10, 20, 'Radisson Blu -> Route directe -> Aéroport Ivato'),
(4, 1, 18.0, 35, 60, 'Sakamanga -> By-pass -> Aéroport Ivato');

-- Clients
INSERT INTO client (nom, prenom, email, telephone, nationalite, hotel_id, numero_chambre, date_checkin, date_checkout) VALUES
('DUPONT', 'Pierre', 'pierre.dupont@email.com', '+33 6 12 34 56 78', 'Française', 1, '405', '2026-01-28', '2026-02-05'),
('SMITH', 'John', 'john.smith@email.com', '+1 555 123 4567', 'Américaine', 2, '302', '2026-01-30', '2026-02-10'),
('TANAKA', 'Yuki', 'yuki.tanaka@email.com', '+81 90 1234 5678', 'Japonaise', 1, '512', '2026-02-01', '2026-02-08');

-- Vols
INSERT INTO vol (numero_vol, compagnie_aerienne, aeroport_id, date_heure_depart, date_heure_arrivee, type_vol, terminal, statut) VALUES
('MD201', 'Air Madagascar', 1, '2026-02-05 14:30:00', NULL, 'DEPART', 'A', 'PROGRAMME'),
('AF934', 'Air France', 1, NULL, '2026-02-06 06:15:00', 'ARRIVEE', 'A', 'PROGRAMME'),
('KQ250', 'Kenya Airways', 1, '2026-02-08 22:00:00', NULL, 'DEPART', 'A', 'PROGRAMME');

-- Réservations exemple
INSERT INTO reservation (
    numero_reservation, client_principal_id, type_transfert, hotel_id, vol_id, aeroport_id,
    date_heure_prise_en_charge, categorie_demandee_id, nombre_passagers, nombre_bagages,
    statut, commentaires
) VALUES
('RES-2026-0001', 1, 'HOTEL_AEROPORT', 1, 1, 1, '2026-02-05 11:00:00', 2, 2, 3, 'CONFIRMEE', 'Client VIP - Attention particulière'),
('RES-2026-0002', 2, 'AEROPORT_HOTEL', 2, 2, 1, '2026-02-06 07:00:00', 3, 4, 5, 'EN_ATTENTE', 'Groupe de 4 personnes'),
('RES-2026-0003', 3, 'HOTEL_AEROPORT', 1, 3, 1, '2026-02-08 18:30:00', NULL, 1, 2, 'EN_ATTENTE', 'Pas de préférence de voiture');

-- Passagers supplémentaires pour réservation groupe
INSERT INTO reservation_passager (reservation_id, nom, prenom, telephone, est_passager_principal) VALUES
(2, 'SMITH', 'Mary', '+1 555 123 4568', FALSE),
(2, 'SMITH', 'Tom', '+1 555 123 4569', FALSE),
(2, 'JOHNSON', 'Lisa', '+1 555 987 6543', FALSE);

-- =====================================================
-- VUES UTILES
-- =====================================================

-- Vue: Voitures disponibles par catégorie
CREATE OR REPLACE VIEW v_voitures_disponibles AS
SELECT 
    v.id,
    v.immatriculation,
    v.marque,
    v.modele,
    c.nom AS categorie,
    c.capacite_passagers,
    c.capacite_bagages,
    c.tarif_base
FROM voiture v
JOIN categorie_voiture c ON v.categorie_id = c.id
WHERE v.statut = 'DISPONIBLE';

-- Vue: Réservations du jour avec détails
CREATE OR REPLACE VIEW v_reservations_jour AS
SELECT 
    r.numero_reservation,
    r.date_heure_prise_en_charge,
    r.type_transfert,
    c.nom || ' ' || c.prenom AS client,
    c.telephone AS tel_client,
    h.nom AS hotel,
    a.code_iata AS aeroport,
    v.numero_vol,
    r.nombre_passagers,
    COALESCE(vo.immatriculation, 'NON ASSIGNEE') AS voiture,
    COALESCE(ch.nom || ' ' || ch.prenom, 'NON ASSIGNE') AS chauffeur,
    r.statut
FROM reservation r
JOIN client c ON r.client_principal_id = c.id
JOIN hotel h ON r.hotel_id = h.id
JOIN aeroport a ON r.aeroport_id = a.id
LEFT JOIN vol v ON r.vol_id = v.id
LEFT JOIN voiture vo ON r.voiture_id = vo.id
LEFT JOIN chauffeur ch ON r.chauffeur_id = ch.id
WHERE DATE(r.date_heure_prise_en_charge) = CURRENT_DATE
ORDER BY r.date_heure_prise_en_charge;

-- Vue: Estimation temps trajet
CREATE OR REPLACE VIEW v_estimation_trajets AS
SELECT 
    h.nom AS hotel,
    a.code_iata || ' - ' || a.nom AS aeroport,
    t.distance_km,
    t.duree_estimee_minutes || ' min' AS duree_normale,
    t.duree_trafic_dense_minutes || ' min' AS duree_trafic,
    t.description_itineraire
FROM trajet t
JOIN hotel h ON t.hotel_id = h.id
JOIN aeroport a ON t.aeroport_id = a.id
WHERE t.actif = TRUE;

-- =====================================================
-- FONCTIONS UTILES
-- =====================================================

-- Fonction: Trouver voiture disponible pour une réservation
CREATE OR REPLACE FUNCTION fn_trouver_voiture_disponible(
    p_date_prise_charge TIMESTAMP,
    p_duree_minutes INT,
    p_nb_passagers INT,
    p_nb_bagages INT
) RETURNS TABLE (
    voiture_id INT,
    immatriculation VARCHAR,
    categorie VARCHAR,
    tarif DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        v.id,
        v.immatriculation,
        c.nom,
        c.tarif_base
    FROM voiture v
    JOIN categorie_voiture c ON v.categorie_id = c.id
    WHERE v.statut = 'DISPONIBLE'
      AND c.capacite_passagers >= p_nb_passagers
      AND c.capacite_bagages >= p_nb_bagages
      AND v.id NOT IN (
          SELECT r.voiture_id 
          FROM reservation r 
          WHERE r.voiture_id IS NOT NULL
            AND r.statut NOT IN ('TERMINEE', 'ANNULEE', 'NO_SHOW')
            AND r.date_heure_prise_en_charge BETWEEN 
                p_date_prise_charge - INTERVAL '30 minutes' 
                AND p_date_prise_charge + (p_duree_minutes || ' minutes')::INTERVAL
      )
    ORDER BY c.tarif_base ASC;
END;
$$ LANGUAGE plpgsql;

-- Fonction: Calculer tarif estimation
CREATE OR REPLACE FUNCTION fn_calculer_tarif(
    p_hotel_id INT,
    p_aeroport_id INT,
    p_categorie_id INT
) RETURNS DECIMAL AS $$
DECLARE
    v_tarif_base DECIMAL;
    v_tarif_km DECIMAL;
    v_distance DECIMAL;
    v_supplement DECIMAL;
BEGIN
    SELECT tarif_base, tarif_km INTO v_tarif_base, v_tarif_km
    FROM categorie_voiture WHERE id = p_categorie_id;
    
    SELECT distance_km, tarif_supplementaire INTO v_distance, v_supplement
    FROM trajet WHERE hotel_id = p_hotel_id AND aeroport_id = p_aeroport_id;
    
    IF v_distance IS NULL THEN
        v_distance := 20; -- Distance par défaut
        v_supplement := 0;
    END IF;
    
    RETURN v_tarif_base + (v_distance * v_tarif_km) + COALESCE(v_supplement, 0);
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FIN DU SCRIPT
-- =====================================================

SELECT 'Base de données créée avec succès!' AS message;
SELECT 'Tables créées: aeroport, hotel, vol, client, categorie_voiture, chauffeur, voiture, disponibilite_voiture, trajet, reservation, reservation_passager' AS tables;
