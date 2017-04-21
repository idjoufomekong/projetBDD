--Insert table Métier
Insert jo.metier(Code, Libellé) values
('ANA', 'Analyste'),
('CDP', 'Chef de Projet'),
('DEV', 'Développeur'),
('DES', 'Designer'),
('TES', 'Testeur')

--Insert table ActivitéProduction
Insert jo.ActiviteProd(Code, Libellé) values
('DBE', 'Définition des besoins'),
('ARF', 'ChefArchitecture fonctionnelle'),
('ANF', 'Analyse fonctionnelle'),
('DES', 'Design'),
('INF', 'Infographie'),
('ART', 'Architecture technique'),
('ANT', 'Analyse technique'),
('DEV', 'Développement'),
('RPT', 'Rédaction de plan de test'),
('TES', 'Test')


--Insert table Service
insert jo.ServiceFiliere (Code, nom) values
('MKT', 'Marketing'),
('DEV', 'Développement'),
('TEST', 'Test'),
('SL', 'Support Logiciel')


--Insert table Filière
insert jo.Filiere(Code,Nom) values
('BIOH', 'Biologie humaine'),
('BIOA', 'Biologie animale'),
('BIOV', 'Biologie végétale')

--Insert table Equipe
Insert jo.Equipe(Id,Filiere_Code,Service_Code) values
(1,'BIOH','MKT'),
(2,'BIOA','MKT'),
(3,'BIOV','MKT'),
(4,'BIOH','DEV'),
(5,'BIOA','DEV'),
(6,'BIOV','DEV'),
(7,'BIOH','TEST'),
(8,'BIOA','TEST'),
(9,'BIOV','TEST')

--Insert table personne----
Insert jo.Personne (LoginPersonne, Nom, Prénom, sexe, Manager, MétierCode) values
('GLECLERCK','LECLERCQ','Geneviève',1,'BNORMAND','ANA'), 
('AFERRAND','FERRAND','Angèle',1,'GLECLERCK','ANA'),
('BNORMAND','NORMAND','Balthazar',0,null,'CDP'),
('RFISHER','FISHER','Raymond',0,'LBUTLER','DEV'),
('LBUTLER','BUTLER','Lucien',0,'BNORMAND','DEV'),
('RBEAUMONT','BEAUMONT','Roseline',1,'LBUTLER','DEV'),
('MWEBER','WEBER','Marguerite',1,'GLECLERCK','DES'),
('HKLEIN','KLEIN','Hilaire',0,'GLECLERCK','TES'),
('NPALMER','PALMER','Nino',0,'GLECLERCK','TES')


--Insert table Logiciel
insert jo.Logiciel(Code, Nom,Filiere_Code) values
('Geno', 'Genomica','BIOH'),
('Reno', 'Renomica', 'BIOH')


--Insert table VersionLogiciel 
Insert jo.VersionLogiciel (Numéro,Millésime,DateOuverture,dateSortiePrévue,dateSortie, Logiciel_Code) values
(1.00,2017,'2016-01-16','2017-01-08','2017-01-08', 'Geno'),
(2.00,2018,'2016-12-28','2018-01-01', null, 'Geno')

--Insert table Module
insert jo.Module(Code, Libellé, ModuleParent, Logiciel_Code) values
('SEQUENCAGE','Sequençage',null,'Geno'),
('MARQUAGE','Marquage',null,'Geno'),
('SEPARATION','Séparation','SEQUENCAGE','Geno'),
('ANALYSE','Analyse','SEQUENCAGE','Geno'),
('POLYMOR','Sequençage','SEQUENCAGE','Geno'),
('VAR_ALLELE','Sequençage',null,'Geno'),
('UTIL_DRO','Sequençage',null,'Geno'),
('PARAMETRES','Sequençage',null,'Geno')


--insert table Release
Insert jo.ReleaseVersion (DateDeCréation, VersionLogiciel_Numéro) values
('2016-02-02',1.00),
('2016-11-05',1.00),
('2017-01-01',2.00),
('2017-05-02',2.0)


--insert Table EquipePersonne
insert jo.EquipePersonne(DateArrivée, TauxProductivité, Equipe_Id, Personne_LoginPersonne) values
('2000-12-05',90,1,'GLECLERCK'),
('2001-12-05',90,3,'AFERRAND'),
('2000-12-05',90,1,'BNORMAND'),
('2010-12-05',90,2,'RFISHER'),
('2011-12-05',90,1,'LBUTLER'),
('2012-12-05',90,2,'RBEAUMONT'),
('2009-12-05',90,3,'MWEBER'),
('2016-12-05',90,3,'HKLEIN'),
('2017-12-05',90,3,'NPALMER')


--insert table Tache
insert jo.tache( Id, Libellé, Description, LoginPersonne) values
( newid(),'tache1', 'Code1','MWEBER'),
( newid(),'tache2', 'Code2','MWEBER'),
( newid(), 'tache3', 'Code3','HKLEIN')


--insert table tachepersonnes
insert jo.TachePersonne(LoginPersonne,Tache_Id,TempsPassé, DateJour) values
( 'GLECLERCK', (select id from jo.Tache where Libellé = 'tache1'),3,'05-06-2001'),
( 'GLECLERCK', (select id from jo.Tache where Libellé = 'tache2'),4, '05-06-2012')


--insert table ActiviteMetier
insert jo.ActiviteMetier(ActiviteProd_Code, Metier_Code) values
( 'DBE', 'TES' ),
( 'DBE', 'DES')

--insert table TacheAnnexe
insert jo.TacheAnnexe(Id)
(select id from jo.Tache where Libellé = 'tache3')



--insert table ActiviteAnnexe
insert jo.ActiviteAnnexe(Id,Libellé,TacheAnnexe_Id) values
( 1, 'formation',(select id from jo.Tache where Libellé = 'tache3') )


--Insert table TacheProd
insert jo.tacheproduction(Id) 
(select id from jo.Tache where Libellé = 'tache1')
insert jo.tacheproduction(Id) 
(select id from jo.Tache where Libellé = 'tache2')



--Insert table IdentificationTacheProd
Insert jo.IdentificationTacheProd(Module_Code,ActiviteProd_Code , tacheProduction_Id, VersionLogiciel_Numéro, DuréePrévue, DuréeEstimée) values
('SEQUENCAGE','DBE',(select id from jo.Tache where Libellé = 'tache1'),1.00,150,20),
('MARQUAGE','ARF',(select id from jo.Tache where Libellé = 'tache2'),1.00,120,25)
