----Cr�ation d'une t�che annexe
if exists(select 1 from INFORMATION_SCHEMA.ROUTINES
		where SPECIFIC_SCHEMA = 'dbo' and SPECIFIC_NAME = 'usp_CreationTacheAnnexe')
drop procedure dbo.usp_CreationTacheAnnexe
go
create procedure usp_CreationTacheAnnexe @nom nvarchar(30), @descrip nvarchar(100), @login nvarchar(10)
as
begin
	insert jo.tache( id, Libell�, Description, LoginPersonne) values
( newid(),@nom, @descrip,@login)
select top(1) ID from jo.Tache
order by 1 desc

insert jo.TacheAnnexe(Id) 
 select top(1) ID from jo.Tache
order by 1 desc 

	
end
go

----Cr�ation d'une t�che de production
if exists(select 1 from INFORMATION_SCHEMA.ROUTINES
		where SPECIFIC_SCHEMA = 'dbo' and SPECIFIC_NAME = 'usp_CreationTacheProduction')
drop procedure dbo.usp_CreationTacheProduction
go
create procedure usp_CreationTacheProduction @nom nvarchar(30), @descrip nvarchar(100), @login nvarchar(10),
		@module nvarchar(10),@version bigint, @activit� nvarchar(10), @dur�ePr�vue int, @dur�eEstim�e int
as
begin
declare @idtache uniqueidentifier
	insert jo.tache( id, Libell�, Description, LoginPersonne) values
(NEWID(), @nom, @descrip,@login)

 set @idtache = (select top(1) Id from jo.Tache
order by 1 desc) 

insert jo.TacheProduction(Id) values (@idtache)

insert jo.IdentificationTacheProd(Module_Code,ActiviteProd_Code,TacheProduction_Id,VersionLogiciel_Num�ro,
Dur�ePr�vue, Dur�eEstim�e) values
(@module, @activit�,@idtache,@version,@dur�ePr�vue,@dur�eEstim�e) 

	
end
go


--Saisie de temps sur une t�che
if exists(select 1 from INFORMATION_SCHEMA.ROUTINES
		where SPECIFIC_SCHEMA = 'dbo' and SPECIFIC_NAME = 'usp_SaisieTempsTache')
drop procedure dbo.usp_SaisieTempsTache
go
create procedure usp_SaisieTempsTache  @nomLogiciel nvarchar(30), @personne nvarchar(30), @numVersion bigint, 
	@module nvarchar(10), @activit� nvarchar(10), @idTache int, @tempsPass� int, @dur�eEstim�e int
as
begin
	declare @idModule nvarchar(10), @idLogiciel nvarchar(30), @idActivite int, @dur�ePr�vue int
	
	set @idLogiciel = (select code from jo.Logiciel where Nom = @nomLogiciel)
	 
	if @tempsPass� > 8
	begin
		RAISERROR(50001, 12, 1)
		return
	end
	
	set @dur�ePr�vue = (select top(1) Dur�ePr�vue from jo.IdentificationTacheProd
		where Module_Code=@module and ActiviteProd_Code=@activit� and TacheProduction_Id= @idTache 
		and VersionLogiciel_Num�ro =@numVersion)
	begin try
		insert jo.TachePersonne(DateJour, LoginPersonne,Tache_Id,TempsPass�) values
		(GETDATE(),@personne,@idTache,@tempsPass�)
	end try
	begin catch
		
		if ERROR_NUMBER() = 2627
			begin
			print 'coucou'
			update jo.TachePersonne set TempsPass� = @tempsPass�
			where LoginPersonne = @personne and Tache_Id=@idTache and DATEDIFF(day,dateJour, getdate())=0
			end
	end catch
		
	insert jo.IdentificationTacheProd(Module_Code,ActiviteProd_Code,TacheProduction_Id,VersionLogiciel_Num�ro,Dur�ePr�vue, 
	Dur�eEstim�e) values
	(@module,@activit�,@idTache,@numVersion,@dur�ePr�vue,@dur�eEstim�e)
	print 'Au: ' + convert(varchar, GETDATE(),103)
	print'Dur�e initiale: ' + convert(varchar,@dur�ePr�vue)
	print 'Dur�e estim�e:' + convert(varchar,@dur�eEstim�e)
	
end
go

--Remplissage des liste d�roulante
if exists(select 1 from INFORMATION_SCHEMA.VIEWS
		where TABLE_SCHEMA = 'dbo' and TABLE_NAME = 'RemplissageListe')
drop view RemplissageListe
go
create view RemplissageListe as (
select l.Nom, vl.Num�ro, m.Code,  convert(varchar,t.Id)+ ' - '+convert(varchar,t.Libell�) as tache, itp.Dur�eEstim�e, itp.Dur�ePr�vue
from jo.TachePersonne tp
inner join jo.Tache t on tp.LoginPersonne= tp.LoginPersonne
inner join jo.TacheProduction tpro on tpro.Id= t.Id
inner join jo.IdentificationTacheProd itp on Itp.TacheProduction_Id= tpro.Id
inner join jo.Module m on m.Code= itp.Module_Code
inner join jo.ActiviteProd ap on ap.Code= itp.ActiviteProd_Code
inner join jo.VersionLogiciel vl on vl.Num�ro= itp.VersionLogiciel_Num�ro
inner join jo.Logiciel l on l.Code= vl.Logiciel_Code
)

--V�rification par le manager du fait que tout le monde a bien saisi ses 8h par jour
if exists(select 1 from INFORMATION_SCHEMA.ROUTINES
		where SPECIFIC_SCHEMA = 'dbo' and SPECIFIC_NAME = 'usp_VerifTempsSaisi')
drop procedure dbo.usp_VerifTempsSaisi
go
create procedure usp_VerifTempsSaisi  
as
begin
select LoginPersonne
from jo.TachePersonne
where TempsPass� < 8
end
go

--Suppression de toutes les donn�es li�es � une version d'un logiciel
if exists(select 1 from INFORMATION_SCHEMA.ROUTINES
		where SPECIFIC_SCHEMA = 'dbo' and SPECIFIC_NAME = 'usp_SupprDonn�esLogiciel')
drop procedure dbo.usp_SupprDonn�esLogiciel
go
create procedure usp_SupprDonn�esLogiciel  @nomLogiciel nvarchar(10)
as
begin
	--Je r�cup�re d'abord le code du logiciel
	declare @codelog nvarchar(10)
	set @codelog = ( select code from jo.Logiciel where Nom = @nomLogiciel)
	
	--Je d�clare un tableau permettant de r�cup�rer toutes les t�ches d'activit� li�es � ce logiciel 
	declare @TableTaches table
(
	Id uniqueidentifier primary key
)
	insert @TableTaches(Id) (
	select distinct TacheProduction_Id from jo.IdentificationTacheProd where Module_Code in(
		select code from jo.Module where Logiciel_Code = @codelog
		)
		and VersionLogiciel_Num�ro in (
		select Num�ro from jo.VersionLogiciel where Logiciel_Code = @codelog
		)
	)
	
	--On vide la table identificationTacheProd. On est s�r de ne supprimer que les t�ches li�es au logiciel sp�cifi�
	--parce que les id des t�ches sont uniques
	delete from jo.IdentificationTacheProd where TacheProduction_Id in (select * from @TableTaches)
	
	--On vide la table TachePersonne
	delete from jo.TachePersonne where Tache_Id in (select * from @TableTaches)
	
	--On vide la table TacheProduction
	delete from jo.TacheProduction where ID in (select * from @TableTaches)
	
	--On vide la table Tache
	delete from jo.Tache where ID in (select * from @TableTaches)
	
	--On vide la table releaseVersion
	delete from jo.ReleaseVersion where VersionLogiciel_Num�ro in
	(
	select Num�ro from jo.VersionLogiciel where Logiciel_Code = @codelog
	)
	-- On vide enfin les tables module et version
	delete from jo.Module where Logiciel_Code = @codelog
	delete from jo.VersionLogiciel where Logiciel_Code = @codelog
	
end
go
