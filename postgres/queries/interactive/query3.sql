select p_personid, p_firstname, p_lastname, ct1, ct2, total
from
 ( select k_person2id
   from knows
   where
   k_person1id = :Person
   union
   select k2.k_person2id
   from knows k1, knows k2
   where
   k1.k_person1id = :Person and k1.k_person2id = k2.k_person1id and k2.k_person2id <> :Person
 ) f,  person, place p1, place p2,
 (
  select chn.ps_c_creatorid, ct1, ct2, ct1 + ct2 as total
  from
   (
      select ps_creatorid as ps_c_creatorid, count(*) as ct1 from post, place
      where
        ps_locationid = pl_placeid and pl_name = :Country1 and
        ps_creationdate >= :Date0 and  ps_creationdate < (:Date0 + INTERVAL '1 days' * :Duration)
      group by ps_c_creatorid
   ) chn,
   (
      select ps_creatorid as ps_c_creatorid, count(*) as ct2 from post, place
      where
        ps_locationid = pl_placeid and pl_name = :Country2 and
        ps_creationdate >= :Date0 and  ps_creationdate < (:Date0 + INTERVAL '1 days' * :Duration)
      group by ps_creatorid --ps_c_creatorid
   ) ind
  where CHN.ps_c_creatorid = IND.ps_c_creatorid
 ) cpc
where
f.k_person2id = p_personid and p_placeid = p1.pl_placeid and
p1.pl_containerplaceid = p2.pl_placeid and p2.pl_name <> :Country1 and p2.pl_name <> :Country2 and
f.k_person2id = cpc.ps_c_creatorid
order by 6 desc, 1
limit 20
