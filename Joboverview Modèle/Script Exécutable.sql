----Cr�ation d'une t�che annexe
--Entrez en param�tres dans l'odre: nom de la t�che, sa description et le code de la personne � qui l'affecter
exec usp_CreationTacheAnnexe tache5, code5, GLECLERCK


----Cr�ation d'une t�che de production
--Entrez en param�tres dans l'odre: nom de la t�che, sa description et le code de la personne � qui l'affecter,
--le module , la version et l'activit� de production concern�s, le temps pr�vu et le temps restant estim�
begin try
exec usp_CreationTacheProduction tacheprod2, d�veloppement, GLECLERCK, SEQUENCAGE,1.00, DBE, 150, 20
end try
begin catch
	if ERROR_NUMBER() = 547
		print 'L''activit� ou le module ou la version que vous avez choisi n''existe pas !'
end catch


----Saisie de temps sur une t�che 
--Entrez les param�tres dans l'ordre: nom du logiciel, login de la personne, num�ro de la version, code du module, 
--code de l'activit�, identifiant de la t�che, le temps pass� dans la journ�e puis la dur�e restante estim�e
set language 'french'
exec sp_addmessage @msgnum = 50001, @severity = 12,
	@msgText = 'You can''t insert a value more than 8',
	@lang='us_english',
	@replace = 'replace'

exec sp_addmessage @msgnum = 50001, @severity = 12,
	@msgText = 'Vous ne pouvez pas ins�rer plus de 8h',
	@lang='French',
	@replace = 'replace'
	
exec usp_SaisieTempsTache Genomica, AFERRAND, 1.00, SEQUENCAGE,DBE, 1, 4,3
select * from jo.TachePersonne

--V�rification par le manager du fait que tout le monde a bien saisi ses 8h par jour
exec usp_VerifTempsSaisi

--Pour saisir les informations li�es � un logiciel, il suffit d'appeler la proc�dure ci-dessous en donnant le nom du logiciel
exec usp_SupprDonn�esLogiciel Genomica




