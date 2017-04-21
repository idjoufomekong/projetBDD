----2.1 A: Cleints sans num�ro de t�l�phone
select distinct c.CLI_ID, c.CLI_NOM 
from client c
inner join TELEPHONE t on t.CLI_ID=c.CLI_ID
where t.CLI_ID not in (
select CLI_ID from TELEPHONE where TYP_CODE ='GSM')
--85 clients sans t�l�phone


--2.1 B Client avec au moins 1 t�l�phone ou un email
Select c.CLI_ID, c.CLI_NOM , t.TEL_NUMERO, e.EML_ADRESSE
from client c
left outer join TELEPHONE t on t.CLI_ID=c.CLI_ID
left outer join EMAIL e on e.CLI_ID=c.CLI_ID
where  EML_ADRESSE is not null or TEL_NUMERO is not null
--178 lignes 

 
 --2.1 C Mise � jour du format t�l�phone
 
 begin tran
 update TELEPHONE
 set TEL_NUMERO= '+33' + REPLACE(SUBSTRING(TEL_NUMERO,2,13), '-', '')
 
 rollback
 --174 lignes 


--2.1 D Client qui ont pay� avec 2 moyens de paiement au cours d'un m�me mois
select c.CLI_ID, c.CLI_NOM, DATENAME(M,FAC_PMDATE) Mois, year(FAC_PMDATE) Ann�e
from CLIENT c  
inner join FACTURE f on f.CLI_ID= c.CLI_ID
group by c.CLI_ID, c.CLI_NOM, DATENAME(M,FAC_PMDATE) , year(FAC_PMDATE)
having count (f.PMCODE)>1
order by 4,3
 --33 lignes
 
--2.1 E Client de la m�me ville qui se sont d�j� retrouv�s dans en m�me temps dans l'h�tel


--2.3 A.	Valeur absolue et pourcentage d�augmentation du tarif de chaque chambre sur l�ensemble de la p�riode

begin tran
--Je d�clare une table temporaire qui stocke les prix aux dates initiale et finale
declare @TablePrix table
	(
	Id int primary key ,
	Prix1 money ,
	Prix2 money 
	)
	
insert @TablePrix(Id, Prix1)
(select CHB_ID, TRF_CHB_PRIX
from TRF_CHB
where TRF_DATE_DEBUT = ( select top(1) TRF_DATE_DEBUT from TRF_CHB order by TRF_DATE_DEBUT)
)
update @TablePrix set Prix2 = 
(select TRF_CHB_PRIX
from TRF_CHB
where CHB_ID = Id and TRF_DATE_DEBUT = ( select top(1) TRF_DATE_DEBUT from TRF_CHB order by TRF_DATE_DEBUT desc)
)
--Je fais le calcul sur les prix de ma table
select abs(Prix2 - Prix1) Diff�rence, round((Prix2 - Prix1)*100/Prix1,2) Pourcentage
from @TablePrix
--20 lignes


--2.3 B.	Chiffre d'affaire de l�h�tel par trimestre de chaque ann�e
select DATEPART(QUARTER, f.FAC_DATE) as Trimestre,YEAR(f.FAC_DATE) Ann�e, 
	round(sum((((LIF_MONTANT*LIF_QTE)*(1+LIF_TAUX_TVA/100)) *(1- ISNULL( LIF_REMISE_POURCENT,0)/100))- isnull(LIF_REMISE_MONTANT,0)),2) CA
from LIGNE_FACTURE lf
inner join facture f on f.FAC_ID = lf.FAC_ID
group by DATEPART(QUARTER, f.FAC_DATE),YEAR(f.FAC_DATE) 
order by 2,1
-- 9 lignes

--2.3 C.	Chiffre d'affaire de l�h�tel par mode de paiement et par an, avec les modes de paiement en colonne et les ann�es en ligne.

select CAParMode.*
from (
	select  YEAR(f.FAC_DATE) Ann�e, f.PMCODE,
	(((LIF_MONTANT*LIF_QTE)*(1+LIF_TAUX_TVA/100)) *(1- ISNULL( LIF_REMISE_POURCENT,0)/100))- isnull(LIF_REMISE_MONTANT,0) CA
	from LIGNE_FACTURE lf
	inner join facture f on f.FAC_ID = lf.FAC_ID
	
) as Source
pivot (
	sum(CA)
	for PMCODE in ([CB],[CHQ],[ESP])
	) as CAParMode
	

--2.3 D.	D�lai moyen de paiement des factures par ann�e et par mode de paiement, avec les modes de paiement en colonne et les ann�es en ligne.

select DelaiParMode.*
from (
	select PMCODE,YEAR(FAC_DATE) Ann�e,DATEDIFF(d,fac_date,fac_pmdate) delai 
	from FACTURE
) as Source
pivot (
	avg(delai)
	for PMCODE in ([CB],[CHQ],[ESP])
	) as DelaiParMode

--2.3 E.	Compter le nombre de clients dans chaque tranche de 5000 F de chiffre d�affaire total g�n�r�, en partant de 20000 F jusqu�� + de 45 000 F. 
begin tran
--d�claration d'une table
declare @CAParClient table
(
	ClientId int primary key,
	CA  money not null,
	Tranche varchar(20)
)
--Remplissage de la table
insert @CAParClient(ClientId, CA)  
(select CLI_ID,  round(sum((((LIF_MONTANT*LIF_QTE)*(1+LIF_TAUX_TVA/100)) *(1- ISNULL( LIF_REMISE_POURCENT,0)/100))- isnull(LIF_REMISE_MONTANT,0)),2) as CA
from LIGNE_FACTURE lf
inner join facture f on f.FAC_ID = lf.FAC_ID
group by CLI_ID)


--mise � jour de la table avec les tranches
--Rq: les clients ayant g�n�r� moins de 20000  et plus de 45000 de CA ne sont pas pris en compte et n'appartiennent � aucune tranche
update @CAParClient set Tranche = 
(
		case
			when CA >= 20000 and CA < 25000 then 'T1'
			when CA < 30000 then 'T2'
			when CA < 35000 then 'T3'
			when CA < 40000 then 'T4'
			when CA < 45000 then 'T5'
			else 'non calcul�'
		end 
	)


--comptage du nombre de client par tranche du chiffre d'affaire
select Tranche, COUNT(*)
 from @CAParClient
 group by tranche
 -- 4 lignes
 
 
--2.3 F.	A partir du 01/09/2017, augmenter les tarifs des chambres du rez-de-chauss�e de 5%, celles du 1er �tage de 4% et celles du 2d �tage de 2%.

begin tran
--On fait d'abord l'insert de la date dans la table tarif
insert TARIF(TRF_DATE_DEBUT,TRF_TAUX_TAXES,TRF_PETIDEJEUNE)
(
select getdate(),TRF_TAUX_TAXES,TRF_PETIDEJEUNE
from TARIF 
where TRF_DATE_DEBUT = ( select top(1) TRF_DATE_DEBUT from TARIF order by TRF_DATE_DEBUT desc)
)
-- On le fait ensuite dans la table trf_chb
insert TRF_CHB (CHB_ID,TRF_CHB_PRIX,TRF_DATE_DEBUT)
(
 select distinct tf.CHB_ID, TRF_CHB_PRIX*105/100 ,GETDATE() 
 from TRF_CHB tf
 inner join CHAMBRE C on c.CHB_ID = tf.CHB_ID
 where TRF_DATE_DEBUT = ( select top(1) TRF_DATE_DEBUT from TRF_CHB order by TRF_DATE_DEBUT desc)and c.CHB_ETAGE = 'RDC'
)

insert TRF_CHB (CHB_ID,TRF_CHB_PRIX,TRF_DATE_DEBUT)
(
 select distinct tf.CHB_ID, TRF_CHB_PRIX*104/100 ,GETDATE() 
 from TRF_CHB tf
 inner join CHAMBRE C on c.CHB_ID = tf.CHB_ID
 where TRF_DATE_DEBUT = ( select top(1) TRF_DATE_DEBUT from TRF_CHB order by TRF_DATE_DEBUT desc)and c.CHB_ETAGE = '1er'
)

insert TRF_CHB (CHB_ID,TRF_CHB_PRIX,TRF_DATE_DEBUT)
(
 select distinct tf.CHB_ID, TRF_CHB_PRIX*102/100 ,GETDATE() 
 from TRF_CHB tf
 inner join CHAMBRE C on c.CHB_ID = tf.CHB_ID
 where TRF_DATE_DEBUT = ( select top(1) TRF_DATE_DEBUT from TRF_CHB order by TRF_DATE_DEBUT desc)and c.CHB_ETAGE = '2e'
)

rollback




--2.2 A.	Taux moyen d�occupation de l�h�tel par mois-ann�e. 
--Autrement dit, pour chaque mois-ann�e valeur moyenne sur les chambres du ratio 
--(nombre de jours d'occupation dans le mois / nombre de jours du mois)


--2.2 B.	Taux moyen d�occupation de chaque �tage par ann�e

--2.2 C	Chambre la plus occup�e pour chacune des ann�es

--2.2 D.	Taux moyen de r�servation par mois-ann�e

--2.2 E.	Clients qui ont pass� au total au moins 7 jours � l�h�tel au cours d�un m�me mois (Id, Nom,) mois 
--o� ils ont pass� au moins 7 jours).

--2.2 F.	Nombre de clients qui sont rest�s � l�h�tel au moins deux jours de suite au cours de l�ann�e 2015


--2.2 G.	Clients qui ont fait un s�jour � l�h�tel au moins deux mois de suite

--2.2 H.	Nombre quotidien moyen de clients pr�sents dans l�h�tel pour chaque mois de l�ann�e 2016, en tenant compte du nombre de personnes dans les chambres

-- 2.2 I.	Clients qui ont r�serv� plusieurs fois la m�me chambre au cours d�un m�me mois, mais pas deux jours d�affil�e