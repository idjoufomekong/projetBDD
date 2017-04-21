select p.LoginPersonne, p.Nom ,P.Prénom, p.Manager , e.Id, e.Filiere_Code,  f.Nom, e.Service_Code, sf.Nom
from jo.Personne p
inner join jo.EquipePersonne ep on p.LoginPersonne= ep.Personne_LoginPersonne
inner join jo.Equipe e on e.Id= ep.Equipe_Id
inner join jo.Filiere f on f.Code= e.Filiere_Code
inner join jo.ServiceFiliere sf on sf.Code= e.Service_Code

select VersionLogiciel_Numéro, sum(DuréePrévue-DuréeEstimée)
from jo.IdentificationTacheProd itp
inner join jo.VersionLogiciel  vl on itp.VersionLogiciel_Numéro =vl.Logiciel_Code
group by VersionLogiciel_Numéro


