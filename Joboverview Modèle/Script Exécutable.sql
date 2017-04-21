----Création d'une tâche annexe
--Entrez en paramètres dans l'odre: nom de la tâche, sa description et le code de la personne à qui l'affecter
exec usp_CreationTacheAnnexe tache5, code5, GLECLERCK


----Création d'une tâche de production
--Entrez en paramètres dans l'odre: nom de la tâche, sa description et le code de la personne à qui l'affecter,
--le module , la version et l'activité de production concernés, le temps prévu et le temps restant estimé
begin try
exec usp_CreationTacheProduction tacheprod2, développement, GLECLERCK, SEQUENCAGE,1.00, DBE, 150, 20
end try
begin catch
	if ERROR_NUMBER() = 547
		print 'L''activité ou le module ou la version que vous avez choisi n''existe pas !'
end catch


----Saisie de temps sur une tâche 
--Entrez les paramètres dans l'ordre: nom du logiciel, login de la personne, numéro de la version, code du module, 
--code de l'activité, identifiant de la tâche, le temps passé dans la journée puis la durée restante estimée
set language 'french'
exec sp_addmessage @msgnum = 50001, @severity = 12,
	@msgText = 'You can''t insert a value more than 8',
	@lang='us_english',
	@replace = 'replace'

exec sp_addmessage @msgnum = 50001, @severity = 12,
	@msgText = 'Vous ne pouvez pas insérer plus de 8h',
	@lang='French',
	@replace = 'replace'
	
exec usp_SaisieTempsTache Genomica, AFERRAND, 1.00, SEQUENCAGE,DBE, 1, 4,3
select * from jo.TachePersonne

--Vérification par le manager du fait que tout le monde a bien saisi ses 8h par jour
exec usp_VerifTempsSaisi

--Pour saisir les informations liées à un logiciel, il suffit d'appeler la procédure ci-dessous en donnant le nom du logiciel
exec usp_SupprDonnéesLogiciel Genomica




