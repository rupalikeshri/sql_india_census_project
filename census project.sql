--number of rows into our dataset
  
  select count(*) from project..Data1;
  select count(*) from project.. data2;


  --dataset for jharkhand and bihar

  select * from project..data1 where state in('jharkhand','bihar'); 

  --population of india

  select sum(population) as population from data2;

--avg growth

select state,avg(growth)*100 as avg_growth from data1
group by state;


--avg sex ratio per state

select state,round(avg(sex_ratio),0) as avg_sex_ratio from data1
group by state
order by avg_sex_ratio desc;

--avg literacy rate

select state, round(avg(literacy),0)  from data1 
group by state having round(avg(literacy),0) > 90
order by round(avg(literacy),0) desc;

--top 3 states with highest avg growth percentage

select top 3 state,avg(growth)*100  as avg_growth_percentage from data1 
group by state
order by avg_growth_percentage desc ;

--bottom 3 states showing lowest  sex_ratio

select top 3 state, avg(sex_ratio) as avg_sex_ratio from data1
group by state 
order by avg_sex_ratio;

--top 3 and  bottom 3 states  in literacy rate
  

  --for top states
 drop table if exists #topstates;
create table #topstates
(state nvarchar(225),topstates float)
insert into #topstates 
 select top 3 state, round(avg(literacy),0) as avg_literacy from data1
 group by state
 order by avg_literacy desc;

 --for bottomstates
 drop table if exists #bottomstates
 create table #bottomstates 
(state nvarchar(225),bottomstates float)
insert into #bottomstates
select top 3 state,ROUND(avg(literacy),0) as bottom_literacy from data1
group by state
order by bottom_literacy;

select * from #topstates
union
select * from #bottomstates;

--states starting from letter a or b

select distinct state from data1 where state like 'a%' or state like 'b%';

--state names starting with letter a and end with letter m

select distinct state from project..Data1 where lower(state) like 'a%' and lower(state) like '%m';

-- total no. of males and total no. of females


select d.state,sum(d.males) as total_males ,sum(d.females) total_females from
(select c.district ,c.state,round(c.population/(c.sex_ratio+1),0) as males,round(c.population*(c.sex_ratio)/(c.sex_ratio+1),0)
as females from 
(select data1.sex_ratio/1000 as sex_ratio, data2.population ,data1.district,data1.state from data1 
join data2 on data1.district=data2.district) c) d
group by d.state;


--total literarcy rate


select  c.state,sum(literate_people) as total_literate, sum(illiterate_people) as total_illiterate  from 
(select d.district,d.state,round(d.literacy_ratio*d.population,0) as literate_people,round((1-d.literacy_ratio)*d.population,0)as
illiterate_people from 
(select data1.literacy/100 as literacy_ratio , data2.population ,data1.district,data1.state from data1 
join data2 on data1.district=data2.district) d) c
group by c.state;


--population in previous census


select sum(m.previous_census_population) as previous_census_population,sum(m.current_census_population) as current_census_population from (
select e.state,sum(e.previous_census_population) as previous_census_population,sum(e.current_census_population) as current_census_population
from (select d.district,d.state,round(d.population/(1+growth),0) as previous_census_population,d.population as
current_census_population from
(select a.district,a.state,a.growth as growth,b.population from  data1 a inner join data2 b on a.district=b.district) d) e
group  by e.state) m;


--population vs area

select (g.total_area/previous_census_population) as previous_census_population_vs_area,(g.total_area/current_census_population) as 
current_census_population_vs_area from
(select q.*,r.total_area from
(select '1' as keyy,n.*from
(select sum(m.previous_census_population) as previous_census_population,sum(m.current_census_population) as current_census_population from (
select e.state,sum(e.previous_census_population) as previous_census_population,sum(e.current_census_population) as current_census_population
from (select d.district,d.state,round(d.population/(1+growth),0) as previous_census_population,d.population as
current_census_population from
(select a.district,a.state,a.growth as growth,b.population from  data1 a inner join data2 b on a.district=b.district) d) e
group  by e.state) m) n) q join (

select '1' as keyy,z.* from
(select sum(area_km2) total_area from data2)  z) r on q.keyy=r.keyy) g;


--top 3 district from each state with highest literacy rate


select a.* from
(select district,state,literacy,rank() over(partition by state order by literacy desc) rnk from data1)a
where a.rnk in (1,2,3)
order by state;


