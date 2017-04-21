--Insert table M�tier
Insert jo.metier(Code, Libell�) values
('ANA', 'Analyste'),
('CDP', 'Chef de Projet'),
('DEV', 'D�veloppeur'),
('DES', 'Designer'),
('TES', 'Testeur')

--Insert table Activit�Production
Insert jo.ActiviteProd(Code, Libell�) values
('DBE', 'D�finition des besoins'),
('ARF', 'ChefArchitecture fonctionnelle'),
('ANF', 'Analyse fonctionnelle'),
('DES', 'Design'),
('INF', 'Infographie'),
('ART', 'Architecture technique'),
('ANT', 'Analyse technique'),
('DEV', 'D�veloppement'),
('RPT', 'R�daction de plan de test'),
('TES', 'Test')


--Insert table Service
insert jo.ServiceFiliere (Code, nom) values
('MKT', 'Marketing'),
('DEV', 'D�veloppement'),
('TEST', 'Test'),
('SL', 'Support Logiciel')


--Insert table Fili�re
insert jo.Filiere(Code,Nom) values
('BIOH', 'Biologie humaine'),
('BIOA', 'Biologie animale'),
('BIOV', 'Biologie v�g�tale')

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
Insert jo.Personne (LoginPersonne, Nom, Pr�nom, sexe, Manager, M�tierCode) values
('GLECLERCK','LECLERCQ','Genevi�ve',1,'BNORMAND','ANA'), 
('AFERRAND','FERRAND','Ang�le',1,'GLECLERCK','ANA'),
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
Insert jo.VersionLogiciel (Num�ro,Mill�sime,DateOuverture,dateSortiePr�vue,dateSortie, Logiciel_Code) values
(1.00,2017,'2016-01-16','2017-01-08','2017-01-08', 'Geno'),
(2.00,2018,'2016-12-28','2018-01-01', null, 'Geno')

--Insert table Module
insert jo.Module(Code, Libell�, ModuleParent, Logiciel_Code) values
('SEQUENCAGE','Sequen�age',null,'Geno'),
('MARQUAGE','Marquage',null,'Geno'),
('SEPARATION','S�paration','SEQUENCAGE','Geno'),
('ANALYSE','Analyse','SEQUENCAGE','Geno'),
('POLYMOR','Sequen�age','SEQUENCAGE','Geno'),
('VAR_ALLELE','Sequen�age',null,'Geno'),
('UTIL_DRO','Sequen�age',null,'Geno'),
('PARAMETRES','Sequen�age',null,'Geno')


--insert table Release
Insert jo.ReleaseVersion (DateDeCr�ation, VersionLogiciel_Num�ro) values
('2016-02-02',1.00),
('2016-11-05',1.00),
('2017-01-01',2.00),
('2017-05-02',2.0)


--insert Table EquipePersonne
insert jo.EquipePersonne(DateArriv�e, TauxProductivit�, Equipe_Id, Personne_LoginPersonne) values
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
insert jo.tache( Id, Libell�, Description, LoginPersonne) values
( newid(),'tache1', 'Code1','MWEBER'),
( newid(),'tache2', 'Code2','MWEBER'),
( newid(), 'tache3', 'Code3','HKLEIN')


--insert table tachepersonnes
insert jo.TachePersonne(LoginPersonne,Tache_Id,TempsPass�, DateJour) values
( 'GLECLERCK', (select id from jo.Tache where Libell� = 'tache1'),3,'05-06-2001'),
( 'GLECLERCK', (select id from jo.Tache where Libell� = 'tache2'),4, '05-06-2012')


--insert table ActiviteMetier
insert jo.ActiviteMetier(ActiviteProd_Code, Metier_Code) values
( 'DBE', 'TES' ),
( 'DBE', 'DES')

--insert table TacheAnnexe
insert jo.TacheAnnexe(Id)
(select id from jo.Tache where Libell� = 'tache3')



--insert table ActiviteAnnexe
insert jo.ActiviteAnnexe(Id,Libell�,TacheAnnexe_Id) values
( 1, 'formation',(select id from jo.Tache where Libell� = 'tache3') )


--Insert table TacheProd
insert jo.tacheproduction(Id) 
(select id from jo.Tache where Libell� = 'tache1')
insert jo.tacheproduction(Id) 
(select id from jo.Tache where Libell� = 'tache2')



--Insert table IdentificationTacheProd
Insert jo.IdentificationTacheProd(Module_Code,ActiviteProd_Code , tacheProduction_Id, VersionLogiciel_Num�ro, Dur�ePr�vue, Dur�eEstim�e) values
('SEQUENCAGE','DBE',(select id from jo.Tache where Libell� = 'tache1'),1.00,150,20),
('MARQUAGE','ARF',(select id from jo.Tache where Libell� = 'tache2'),1.00,120,25)
