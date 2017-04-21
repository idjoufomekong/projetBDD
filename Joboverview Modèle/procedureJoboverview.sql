----Création d'une tâche annexe
if exists(select 1 from INFORMATION_SCHEMA.ROUTINES
		where SPECIFIC_SCHEMA = 'dbo' and SPECIFIC_NAME = 'usp_CreationTacheAnnexe')
drop procedure dbo.usp_CreationTacheAnnexe
go
create procedure usp_CreationTacheAnnexe @nom nvarchar(30), @descrip nvarchar(100), @login nvarchar(10)
as
begin
	insert jo.tache( id, Libellé, Description, LoginPersonne) values
( newid(),@nom, @descrip,@login)
select top(1) ID from jo.Tache
order by 1 desc

insert jo.TacheAnnexe(Id) 
 select top(1) ID from jo.Tache
order by 1 desc 

	
end
go

----Création d'une tâche de production
if exists(select 1 from INFORMATION_SCHEMA.ROUTINES
		where SPECIFIC_SCHEMA = 'dbo' and SPECIFIC_NAME = 'usp_CreationTacheProduction')
drop procedure dbo.usp_CreationTacheProduction
go
create procedure usp_CreationTacheProduction @nom nvarchar(30), @descrip nvarchar(100), @login nvarchar(10),
		@module nvarchar(10),@version bigint, @activité nvarchar(10), @duréePrévue int, @duréeEstimée int
as
begin
declare @idtache uniqueidentifier
	insert jo.tache( id, Libellé, Description, LoginPersonne) values
(NEWID(), @nom, @descrip,@login)

 set @idtache = (select top(1) Id from jo.Tache
order by 1 desc) 

insert jo.TacheProduction(Id) values (@idtache)

insert jo.IdentificationTacheProd(Module_Code,ActiviteProd_Code,TacheProduction_Id,VersionLogiciel_Numéro,
DuréePrévue, DuréeEstimée) values
(@module, @activité,@idtache,@version,@duréePrévue,@duréeEstimée) 

	
end
go


--Saisie de temps sur une tâche
if exists(select 1 from INFORMATION_SCHEMA.ROUTINES
		where SPECIFIC_SCHEMA = 'dbo' and SPECIFIC_NAME = 'usp_SaisieTempsTache')
drop procedure dbo.usp_SaisieTempsTache
go
create procedure usp_SaisieTempsTache  @nomLogiciel nvarchar(30), @personne nvarchar(30), @numVersion bigint, 
	@module nvarchar(10), @activité nvarchar(10), @idTache int, @tempsPassé int, @duréeEstimée int
as
begin
	declare @idModule nvarchar(10), @idLogiciel nvarchar(30), @idActivite int, @duréePrévue int
	
	set @idLogiciel = (select code from jo.Logiciel where Nom = @nomLogiciel)
	 
	if @tempsPassé > 8
	begin
		RAISERROR(50001, 12, 1)
		return
	end
	
	set @duréePrévue = (select top(1) DuréePrévue from jo.IdentificationTacheProd
		where Module_Code=@module and ActiviteProd_Code=@activité and TacheProduction_Id= @idTache 
		and VersionLogiciel_Numéro =@numVersion)
	begin try
		insert jo.TachePersonne(DateJour, LoginPersonne,Tache_Id,TempsPassé) values
		(GETDATE(),@personne,@idTache,@tempsPassé)
	end try
	begin catch
		
		if ERROR_NUMBER() = 2627
			begin
			print 'coucou'
			update jo.TachePersonne set TempsPassé = @tempsPassé
			where LoginPersonne = @personne and Tache_Id=@idTache and DATEDIFF(day,dateJour, getdate())=0
			end
	end catch
		
	insert jo.IdentificationTacheProd(Module_Code,ActiviteProd_Code,TacheProduction_Id,VersionLogiciel_Numéro,DuréePrévue, 
	DuréeEstimée) values
	(@module,@activité,@idTache,@numVersion,@duréePrévue,@duréeEstimée)
	print 'Au: ' + convert(varchar, GETDATE(),103)
	print'Durée initiale: ' + convert(varchar,@duréePrévue)
	print 'Durée estimée:' + convert(varchar,@duréeEstimée)
	
end
go

--Remplissage des liste déroulante
if exists(select 1 from INFORMATION_SCHEMA.VIEWS
		where TABLE_SCHEMA = 'dbo' and TABLE_NAME = 'RemplissageListe')
drop view RemplissageListe
go
create view RemplissageListe as (
select l.Nom, vl.Numéro, m.Code,  convert(varchar,t.Id)+ ' - '+convert(varchar,t.Libellé) as tache, itp.DuréeEstimée, itp.DuréePrévue
from jo.TachePersonne tp
inner join jo.Tache t on tp.LoginPersonne= tp.LoginPersonne
inner join jo.TacheProduction tpro on tpro.Id= t.Id
inner join jo.IdentificationTacheProd itp on Itp.TacheProduction_Id= tpro.Id
inner join jo.Module m on m.Code= itp.Module_Code
inner join jo.ActiviteProd ap on ap.Code= itp.ActiviteProd_Code
inner join jo.VersionLogiciel vl on vl.Numéro= itp.VersionLogiciel_Numéro
inner join jo.Logiciel l on l.Code= vl.Logiciel_Code
)

--Vérification par le manager du fait que tout le monde a bien saisi ses 8h par jour
if exists(select 1 from INFORMATION_SCHEMA.ROUTINES
		where SPECIFIC_SCHEMA = 'dbo' and SPECIFIC_NAME = 'usp_VerifTempsSaisi')
drop procedure dbo.usp_VerifTempsSaisi
go
create procedure usp_VerifTempsSaisi  
as
begin
select LoginPersonne
from jo.TachePersonne
where TempsPassé < 8
end
go

--Suppression de toutes les données liées à une version d'un logiciel
if exists(select 1 from INFORMATION_SCHEMA.ROUTINES
		where SPECIFIC_SCHEMA = 'dbo' and SPECIFIC_NAME = 'usp_SupprDonnéesLogiciel')
drop procedure dbo.usp_SupprDonnéesLogiciel
go
create procedure usp_SupprDonnéesLogiciel  @nomLogiciel nvarchar(10)
as
begin
	--Je récupère d'abord le code du logiciel
	declare @codelog nvarchar(10)
	set @codelog = ( select code from jo.Logiciel where Nom = @nomLogiciel)
	
	--Je déclare un tableau permettant de récupérer toutes les tâches d'activité liées à ce logiciel 
	declare @TableTaches table
(
	Id uniqueidentifier primary key
)
	insert @TableTaches(Id) (
	select distinct TacheProduction_Id from jo.IdentificationTacheProd where Module_Code in(
		select code from jo.Module where Logiciel_Code = @codelog
		)
		and VersionLogiciel_Numéro in (
		select Numéro from jo.VersionLogiciel where Logiciel_Code = @codelog
		)
	)
	
	--On vide la table identificationTacheProd. On est sûr de ne supprimer que les tâches liées au logiciel spécifié
	--parce que les id des tâches sont uniques
	delete from jo.IdentificationTacheProd where TacheProduction_Id in (select * from @TableTaches)
	
	--On vide la table TachePersonne
	delete from jo.TachePersonne where Tache_Id in (select * from @TableTaches)
	
	--On vide la table TacheProduction
	delete from jo.TacheProduction where ID in (select * from @TableTaches)
	
	--On vide la table Tache
	delete from jo.Tache where ID in (select * from @TableTaches)
	
	--On vide la table releaseVersion
	delete from jo.ReleaseVersion where VersionLogiciel_Numéro in
	(
	select Numéro from jo.VersionLogiciel where Logiciel_Code = @codelog
	)
	-- On vide enfin les tables module et version
	delete from jo.Module where Logiciel_Code = @codelog
	delete from jo.VersionLogiciel where Logiciel_Code = @codelog
	
end
go
