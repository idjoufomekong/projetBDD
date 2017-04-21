if exists(select 1 from INFORMATION_SCHEMA.ROUTINES
		where SPECIFIC_SCHEMA = 'dbo' and SPECIFIC_NAME = 'usp_TestAndDropAllTablesAndFK')
drop procedure usp_TestAndDropAllTablesAndFK
go
create procedure usp_TestAndDropAllTablesAndFK
as
begin
	declare @SQLDropFK nvarchar(max) = '' 
	declare @SQLDropTable nvarchar(max) = '' 
	
	-- Pour chaque FK, je rajoute le drop de cette dernière dans la variable @SQLDropFK
	select @SQLDropFK = @SQLDropFK + 'Alter table ' + TABLE_SCHEMA + '.' + TABLE_NAME + ' drop constraint ' + CONSTRAINT_NAME + CHAR(13)
	from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
	where CONSTRAINT_TYPE = 'FOREIGN KEY'
	
	-- J'affiche la requete puis l'execute
	print @SQLDropFK
	exec sp_Executesql @SQLDropFK
	
	-- Pour chaque table, je rajoute le drop de cette dernière dans la variable @SQLDropTable
	select @SQLDropTable = @SQLDropTable + 'Drop table ' + TABLE_SCHEMA + '.' + TABLE_NAME+ CHAR(13)
	from INFORMATION_SCHEMA.TABLES where TABLE_TYPE = 'BASE TABLE'
		
	-- J'affiche le drop de mes tables et l'execute
	print @SQLDropTable
	exec sp_Executesql @SQLDropTable
end
go

exec usp_TestAndDropAllTablesAndFK


-----------------------------------------------------------------------------------------------
--Création des Tables--


CREATE
  TABLE jo.ActiviteMetier
  (
    ActiviteProd_Code NVARCHAR (10) NOT NULL ,
    Metier_Code NVARCHAR (10) NOT NULL
  )
  
GO
ALTER TABLE jo.ActiviteMetier ADD CONSTRAINT ActiviteMetier_PK PRIMARY KEY
CLUSTERED (ActiviteProd_Code, Metier_Code)
GO


CREATE
  TABLE jo.IdentificationTacheProd
  (
    Id INTEGER identity NOT NULL ,
    Module_Code NVARCHAR (10) NOT NULL ,
    ActiviteProd_Code NVARCHAR (10) NOT NULL ,
    TacheProduction_Id uniqueidentifier NOT NULL ,
    VersionLogiciel_Numéro BIGINT NOT NULL ,
    DuréePrévue  INTEGER NOT NULL ,
    DuréeEstimée INTEGER NOT NULL DEFAULT 0
  )
  
GO
ALTER TABLE jo.IdentificationTacheProd ADD CONSTRAINT
IdentificationTacheProd_PK PRIMARY KEY CLUSTERED (Id, Module_Code,
ActiviteProd_Code, TacheProduction_Id, VersionLogiciel_Numéro)
GO


CREATE
  TABLE jo.Module
  (
    Code NVARCHAR (10) NOT NULL ,
    Libellé NVARCHAR (30) NOT NULL ,
    ModuleParent NVARCHAR (10) ,
    Logiciel_Code NVARCHAR (10) NOT NULL
  )
  
GO
ALTER TABLE jo.Module ADD CONSTRAINT Module_PK PRIMARY KEY CLUSTERED (Code)
GO


CREATE
  TABLE jo.ReleaseVersion
  (
    Id             INTEGER identity NOT NULL ,
    DateDeCréation DATE NOT NULL ,
    VersionLogiciel_Numéro BIGINT NOT NULL
  )
  
GO
ALTER TABLE jo.ReleaseVersion
ADD
CHECK ( Id BETWEEN 1 AND 999 )
GO
ALTER TABLE jo.ReleaseVersion ADD CONSTRAINT ReleaseVersion_PK PRIMARY KEY
CLUSTERED (Id)
GO




CREATE
  TABLE jo.VersionLogiciel
  (
    Numéro BIGINT NOT NULL ,
    Millésime        INTEGER NOT NULL ,
    DateOuverture    DATE NOT NULL ,
    DateSortiePrévue DATE NOT NULL ,
    DateSortie       DATE ,
    Logiciel_Code NVARCHAR (10) NOT NULL
  )
  
GO
ALTER TABLE jo.VersionLogiciel ADD CONSTRAINT VersionLogiciel_PK PRIMARY KEY
CLUSTERED (Numéro)
GO


CREATE
  TABLE jo.Logiciel
  (
    Code NVARCHAR (10) NOT NULL ,
    Nom NVARCHAR (30) NOT NULL ,
      Filiere_Code NVARCHAR (10) NOT NULL
  )
  
GO
ALTER TABLE jo.Logiciel ADD CONSTRAINT Logiciel_PK PRIMARY KEY CLUSTERED (Code)
GO


CREATE
  TABLE jo.ActiviteProd
  (
    Code NVARCHAR (10) NOT NULL ,
    Libellé NVARCHAR (30) NOT NULL
  )
  
GO
ALTER TABLE jo.ActiviteProd ADD CONSTRAINT ActiviteProd_PK PRIMARY KEY
CLUSTERED (Code)
GO



CREATE
  TABLE jo.EquipePersonne
  (
    DateArrivée DATE NOT NULL ,
    TauxProductivité FLOAT NOT NULL DEFAULT 0 ,
    Equipe_Id INTEGER NOT NULL ,
    Personne_LoginPersonne NVARCHAR (10) NOT NULL
  )
  
GO
ALTER TABLE jo.EquipePersonne ADD CONSTRAINT EquipePersonne_PK PRIMARY KEY
CLUSTERED (Equipe_Id, Personne_LoginPersonne)
GO



CREATE
  TABLE jo.ActiviteAnnexe
  (
    Id INTEGER NOT NULL ,
    Libellé NVARCHAR (100) NOT NULL ,
    TacheAnnexe_Id uniqueidentifier NOT NULL
  )
  
GO
ALTER TABLE jo.ActiviteAnnexe ADD CONSTRAINT ActiviteAnnexe_PK PRIMARY KEY
CLUSTERED (Id)
GO


CREATE
  TABLE jo.TachePersonne
  (
    DateJour   DATE NOT NULL ,
    TempsPassé INTEGER NOT NULL ,
    LoginPersonne NVARCHAR (10) NOT NULL ,
    Tache_Id uniqueidentifier NOT NULL
  )
  
GO
ALTER TABLE jo.TachePersonne ADD CONSTRAINT TachePersonne_PK PRIMARY KEY
CLUSTERED (LoginPersonne, Tache_Id,DateJour)
GO


CREATE
  TABLE jo.TacheAnnexe
  (
    Id uniqueidentifier NOT NULL
  )
  
GO
ALTER TABLE jo.TacheAnnexe ADD CONSTRAINT TacheAnnexe_PK PRIMARY KEY CLUSTERED
(Id)
GO


CREATE
  TABLE jo.TacheProduction
  (
    Id uniqueidentifier NOT NULL
  )
  
GO
ALTER TABLE jo.TacheProduction ADD CONSTRAINT TacheProduction_PK PRIMARY KEY
CLUSTERED (Id)
GO


CREATE
  TABLE jo.Tache
  (
    Id uniqueidentifier NOT NULL ,
    Libellé NVARCHAR (30) NOT NULL ,
    Description NVARCHAR (100) ,
    LoginPersonne NVARCHAR (10) NOT NULL
  )
  
GO
ALTER TABLE jo.Tache ADD CONSTRAINT Tache_PK PRIMARY KEY CLUSTERED (Id)
GO


CREATE
  TABLE jo.Metier
  (
    Code NVARCHAR (10) NOT NULL ,
    Libellé NVARCHAR (30) NOT NULL
  )
  
GO
ALTER TABLE jo.Metier ADD CONSTRAINT Metier_PK PRIMARY KEY CLUSTERED (Code)
GO




CREATE
  TABLE jo.Personne
  (
    LoginPersonne NVARCHAR (10) NOT NULL ,
    Nom NVARCHAR (30) NOT NULL ,
    Prénom NVARCHAR (30) NOT NULL ,
    Sexe BIT NOT NULL ,
    Manager NVARCHAR (10),
    MétierCode NVARCHAR (10) NOT NULL
  )
  
GO
ALTER TABLE jo.Personne
ADD
CHECK ( Sexe IN (0, 1) )
GO
ALTER TABLE jo.Personne ADD CONSTRAINT Personne_PK PRIMARY KEY CLUSTERED (
LoginPersonne)
GO


CREATE
  TABLE jo.Equipe
  (
    Id INTEGER NOT NULL ,
    Filiere_Code NVARCHAR (10) NOT NULL ,
    Service_Code NVARCHAR (10) NOT NULL
  )
  
GO
ALTER TABLE jo.Equipe ADD CONSTRAINT Equipe_PK PRIMARY KEY CLUSTERED (Id)
GO


CREATE
  TABLE jo.ServiceFiliere
  (
    Code NVARCHAR (10) NOT NULL ,
    Nom NVARCHAR (30) NOT NULL
  )
  
GO
ALTER TABLE jo.ServiceFiliere ADD CONSTRAINT ServiceFiliere_PK PRIMARY KEY
CLUSTERED (Code)
GO



CREATE
  TABLE jo.Filiere
  (
    Code NVARCHAR (10) NOT NULL ,
    Nom NVARCHAR (30) NOT NULL
  )
  
GO
ALTER TABLE jo.Filiere ADD CONSTRAINT Filiere_PK PRIMARY KEY CLUSTERED (Code)
GO



--------------------------------------------------------------------------------------------
--Ajout des contraintes de clés étrangères
ALTER TABLE jo.ActiviteAnnexe
ADD CONSTRAINT ActiviteAnnexe_TacheAnnexe_FK FOREIGN KEY
(
TacheAnnexe_Id
)
REFERENCES jo.TacheAnnexe
(
Id
)
GO

ALTER TABLE jo.EquipePersonne
ADD CONSTRAINT EquipePersonne_Equipe_FK FOREIGN KEY
(
Equipe_Id
)
REFERENCES jo.Equipe
(
Id
)
GO

ALTER TABLE jo.EquipePersonne
ADD CONSTRAINT EquipePersonne_Personne_FK FOREIGN KEY
(
Personne_LoginPersonne
)
REFERENCES jo.Personne
(
LoginPersonne
)
GO

ALTER TABLE jo.Equipe
ADD CONSTRAINT Equipe_Filiere_FK FOREIGN KEY
(
Filiere_Code
)
REFERENCES jo.Filiere
(
Code
)
GO

ALTER TABLE jo.Equipe
ADD CONSTRAINT Equipe_Service_FK FOREIGN KEY
(
Service_Code
)
REFERENCES jo.ServiceFiliere
(
Code
)
GO

ALTER TABLE jo.ActiviteMetier
ADD CONSTRAINT FK_ASS_3 FOREIGN KEY
(
ActiviteProd_Code
)
REFERENCES jo.ActiviteProd
(
Code
)
GO

ALTER TABLE jo.ActiviteMetier
ADD CONSTRAINT FK_ASS_4 FOREIGN KEY
(
Metier_Code
)
REFERENCES jo.Metier
(
Code
)
GO

ALTER TABLE jo.IdentificationTacheProd
ADD CONSTRAINT IdentificationTacheProd_ActiviteProd_FK FOREIGN KEY
(
ActiviteProd_Code
)
REFERENCES jo.ActiviteProd
(
Code
)
GO

ALTER TABLE jo.IdentificationTacheProd
ADD CONSTRAINT IdentificationTacheProd_Module_FK FOREIGN KEY
(
Module_Code
)
REFERENCES jo.Module
(
Code
)
GO

ALTER TABLE jo.IdentificationTacheProd
ADD CONSTRAINT IdentificationTacheProd_TacheProduction_FK FOREIGN KEY
(
TacheProduction_Id
)
REFERENCES jo.TacheProduction
(
Id
)
GO

ALTER TABLE jo.IdentificationTacheProd
ADD CONSTRAINT IdentificationTacheProd_VersionLogiciel_FK FOREIGN KEY
(
VersionLogiciel_Numéro
)
REFERENCES jo.VersionLogiciel
(
Numéro
)
GO

ALTER TABLE jo.Logiciel
ADD CONSTRAINT Logiciel_Filiere_FK FOREIGN KEY
(
Filiere_Code
)
REFERENCES jo.Filiere
(
Code
)
GO

ALTER TABLE jo.Module
ADD CONSTRAINT Module_Logiciel_FK FOREIGN KEY
(
Logiciel_Code
)
REFERENCES jo.Logiciel
(
Code
)
GO

ALTER TABLE jo.Module
ADD CONSTRAINT Module_ModuleParent_FK FOREIGN KEY
(
ModuleParent
)
REFERENCES jo.Module
(
Code
)
GO

ALTER TABLE jo.Personne
ADD CONSTRAINT Personne_Manager_FK FOREIGN KEY
(
Manager
)
REFERENCES jo.Personne
(
LoginPersonne
)
GO

ALTER TABLE jo.Personne
ADD CONSTRAINT Personne_Metier_FK FOREIGN KEY
(
MétierCode
)
REFERENCES jo.Metier
(
Code
)
GO

ALTER TABLE jo.ReleaseVersion
ADD CONSTRAINT ReleaseVersion_VersionLogiciel_FK FOREIGN KEY
(
VersionLogiciel_Numéro
)
REFERENCES jo.VersionLogiciel
(
Numéro
)
GO

ALTER TABLE jo.TacheAnnexe
ADD CONSTRAINT TacheAnnexe_Tache_FK FOREIGN KEY
(
Id
)
REFERENCES jo.Tache
(
Id
)
GO

ALTER TABLE jo.TachePersonne
ADD CONSTRAINT TachePersonne_Personne_FK FOREIGN KEY
(
LoginPersonne
)
REFERENCES jo.Personne
(
LoginPersonne
)
GO

ALTER TABLE jo.TachePersonne
ADD CONSTRAINT TachePersonne_Tache_FK FOREIGN KEY
(
Tache_Id
)
REFERENCES jo.Tache
(
Id
)
GO

ALTER TABLE jo.TacheProduction
ADD CONSTRAINT TacheProduction_Tache_FK FOREIGN KEY
(
Id
)
REFERENCES jo.Tache
(
Id
)
GO

ALTER TABLE jo.Tache
ADD CONSTRAINT Tache_Personne_FK FOREIGN KEY
(
LoginPersonne
)
REFERENCES jo.Personne
(
LoginPersonne
)
GO

ALTER TABLE jo.VersionLogiciel
ADD CONSTRAINT VersionLogiciel_Logiciel_FK FOREIGN KEY
(
Logiciel_Code
)
REFERENCES jo.Logiciel
(
Code
)
GO
