CREATE TABLE IF NOT EXISTS OLYMPICS_HISTORY
(
    id          INT,
    name        VARCHAR,
    sex         VARCHAR,
    age         VARCHAR,
    height      VARCHAR,
    weight      VARCHAR,
    team        VARCHAR,
    noc         VARCHAR,
    games       VARCHAR,
    year        INT,
    season      VARCHAR,
    city        VARCHAR,
    sport       VARCHAR,
    event       VARCHAR,
    medal       VARCHAR
);

DROP TABLE IF EXISTS OLYMPICS_HISTORY_NOC_REGIONS;
CREATE TABLE IF NOT EXISTS OLYMPICS_HISTORY_NOC_REGIONS
(
    noc         VARCHAR,
    region      VARCHAR,
    notes       VARCHAR
);


select * from olympics_history;
select * from olympics_history_noc_regions;

-- Problem Statements

-- 1. How many olympics games have been held?

select Count(distinct games) as Olympics_Games from olympics_history;

-- 2. List down all Olympics games held so far?
select distinct year,season,city from olympics_history order by year;

-- 3. Mention the total no of nations who participated in each olympics game?
 
select games, count(distinct noc) as total_no_of_nations from olympics_history group by games;

-- 4.  Which year saw the highest and lowest no of countries participating in olympics?
 with all_countries as
              (select games, nr.region
              from olympics_history oh
              join olympics_history_noc_regions nr ON nr.noc=oh.noc
              group by games, nr.region),
          tot_countries as
              (select games, count(1) as total_countries
              from all_countries
              group by games)
      select distinct
      concat(first_value(games) over(order by total_countries)
      , ' - '
      , first_value(total_countries) over(order by total_countries)) as Lowest_Countries,
      concat(first_value(games) over(order by total_countries desc)
      , ' - '
      , first_value(total_countries) over(order by total_countries desc)) as Highest_Countries
      from tot_countries
      order by 1;



-- 5. Which nation has participated in all of the olympic games?

with tot_games as
              (select count(distinct games) as total_games
              from olympics_history),
          countries as
              (select games, nr.region as country
              from olympics_history oh
              join olympics_history_noc_regions nr ON nr.noc=oh.noc
              group by games, nr.region),
          countries_participated as
              (select country, count(1) as total_participated_games
              from countries
              group by country)
      select cp.*
      from countries_participated cp
      join tot_games tg on tg.total_games = cp.total_participated_games
      order by 1;
-- 6. Identify the sport which was played in all summer olympics.

with season as (
select Count(distinct games) as total_games from olympics_history where season = 'Summer'
),
sports as(
select distinct sport,count(distinct games) as no_of_games
from olympics_history where season='Summer' group by sport)
select s.*,ss.total_games
      from sports s
      join season ss on ss.total_games = s.no_of_games ;

-- 7. Which Sports were just played only once in the olympics.

with sport as(
select sport,count( distinct games) as no_of_games from olympics_history group by sport 
having count(distinct games)=1
)
select distinct s.*,oh.games from sport s join olympics_history oh on s.sport = oh.sport;

-- 8. Fetch the total no of sports played in each olympic games.

select distinct games, count(distinct sport) as no_of_sports
from olympics_history group by games order by count(distinct sport) desc;

-- 9. Fetch oldest athletes to win a gold medal
with temp as
            (select name,sex,cast(case when age = 'NA' then '0' else age end as int) as age
              ,team,games,city,sport, event, medal
            from olympics_history),
        ranking as
            (select *, rank() over(order by age desc) as rnk
            from temp
            where medal='Gold')
    select *
    from ranking
    where rnk = 1;

-- 10.  Find the Ratio of male and female athletes participated in all olympic games.
with t1 as
        	(select sex, count(1) as cnt
        	from olympics_history
        	group by sex),
        t2 as
        	(select *, row_number() over(order by cnt) as rn
        	 from t1),
        min_cnt as
        	(select cnt from t2	where rn = 1),
        max_cnt as
        	(select cnt from t2	where rn = 2)
    select concat('1 : ', round(max_cnt.cnt::decimal/min_cnt.cnt, 2)) as ratio
    from min_cnt, max_cnt;

-- 11. Fetch the top 5 athletes who have won the most gold medals.

with medal as (select name,team,count(medal) as medals
from olympics_history where medal='Gold' group by name,
team order by count(medal) desc),
t2 as(
select * ,
dense_rank() over(order by medals desc) as rank
from medal
)
select * from t2
where rank <=5

-- 12.Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
with t1 as(select name,team,count(medal) as Medal
from olympics_history 
where medal='Gold' or medal='Silver' or Medal ='Bronze' 
group by name,team order by count(medal) desc),
t2 as(
select *,
dense_rank() over(order by Medal desc ) as rnk
from t1
)
select * from t2 where rnk <= 5;

-- 13.Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
with temp1 as(select n.region,count(oh.medal) as total_no_of_medal
from olympics_history oh join olympics_history_noc_regions n on oh.noc = n.noc
where medal in ('Gold','Silver','Bronze')
group by n.region order by count(oh.medal) desc),

temp2 as(
select *, rank() over(order by total_no_of_medal desc) as rnk from temp1)
)
select * from temp2 where rnk <=5;

-- 14. List down total gold, silver and bronze medals won by each country.

with t1 as(select n.region,
sum(case when medal='Gold'then 1 else 0 end) as Gold_medals,
sum(case when medal='Silver'then 1 else 0 end) as Silver_medals,
sum(case when medal='Bronze'then 1 else 0 end) as Bronze_medals,
count(oh.medal) as total_no_of_medal
from olympics_history oh join olympics_history_noc_regions n on oh.noc = n.noc
where medal in ('Gold','Silver','Bronze')
group by n.region order by count(oh.medal) desc)

select * from t1;
-- 15.List down total gold, silver and bronze medals won 
-- by each country corresponding to each olympic games.
with temp as (
select oh.games,n.region as country,
sum(case when medal='Gold'then 1 else 0 end) as Gold_medals,
sum(case when medal='Silver'then 1 else 0 end) as Silver_medals,
sum(case when medal='Bronze'then 1 else 0 end) as Bronze_medals
from olympics_history oh join olympics_history_noc_regions n on oh.noc = n.noc
group by n.region,oh.games 
HAVING
  SUM(CASE WHEN medal = 'Gold' THEN 1 ELSE 0 END) > 0
  OR SUM(CASE WHEN medal = 'Silver' THEN 1 ELSE 0 END) > 0
  OR SUM(CASE WHEN medal = 'Bronze' THEN 1 ELSE 0 END) > 0
order by oh.games,country
)
select * from temp limit 10;

-- 16.Identify which country won the most gold, most silver and most bronze medals
-- in each olympic games.
CREATE EXTENSION TABLEFUNC;
 WITH temp as
    	(SELECT substring(games, 1, position(' - ' in games) - 1) as games
    	 	, substring(games, position(' - ' in games) + 3) as country
            , coalesce(gold, 0) as gold
            , coalesce(silver, 0) as silver
            , coalesce(bronze, 0) as bronze
    	FROM CROSSTAB('SELECT concat(games, '' - '', nr.region) as games
    					, medal
    				  	, count(1) as total_medals
    				  FROM olympics_history oh
    				  JOIN olympics_history_noc_regions nr ON nr.noc = oh.noc
    				  where medal <> ''NA''
    				  GROUP BY games,nr.region,medal
    				  order BY games,medal',
                  'values (''Bronze''), (''Gold''), (''Silver'')')
    			   AS FINAL_RESULT(games text, bronze bigint, gold bigint, silver bigint))
    select distinct games
    	, concat(first_value(country) over(partition by games order by gold desc)
    			, ' - '
    			, first_value(gold) over(partition by games order by gold desc)) as Max_Gold
    	, concat(first_value(country) over(partition by games order by silver desc)
    			, ' - '
    			, first_value(silver) over(partition by games order by silver desc)) as Max_Silver
    	, concat(first_value(country) over(partition by games order by bronze desc)
    			, ' - '
    			, first_value(bronze) over(partition by games order by bronze desc)) as Max_Bronze
    from temp
    order by games;

-- 17. Identify which country won the most gold, most silver,
-- most bronze medals and the most medals in each olympic games.
with temp as
    	(SELECT substring(games, 1, position(' - ' in games) - 1) as games
    		, substring(games, position(' - ' in games) + 3) as country
    		, coalesce(gold, 0) as gold
    		, coalesce(silver, 0) as silver
    		, coalesce(bronze, 0) as bronze
    	FROM CROSSTAB('SELECT concat(games, '' - '', nr.region) as games
    					, medal
    					, count(1) as total_medals
    				  FROM olympics_history oh
    				  JOIN olympics_history_noc_regions nr ON nr.noc = oh.noc
    				  where medal <> ''NA''
    				  GROUP BY games,nr.region,medal
    				  order BY games,medal',
                  'values (''Bronze''), (''Gold''), (''Silver'')')
    			   AS FINAL_RESULT(games text, bronze bigint, gold bigint, silver bigint)),
    	tot_medals as
    		(SELECT games, nr.region as country, count(1) as total_medals
    		FROM olympics_history oh
    		JOIN olympics_history_noc_regions nr ON nr.noc = oh.noc
    		where medal <> 'NA'
    		GROUP BY games,nr.region order BY 1, 2)
    select distinct t.games
    	, concat(first_value(t.country) over(partition by t.games order by gold desc)
    			, ' - '
    			, first_value(t.gold) over(partition by t.games order by gold desc)) as Max_Gold
    	, concat(first_value(t.country) over(partition by t.games order by silver desc)
    			, ' - '
    			, first_value(t.silver) over(partition by t.games order by silver desc)) as Max_Silver
    	, concat(first_value(t.country) over(partition by t.games order by bronze desc)
    			, ' - '
    			, first_value(t.bronze) over(partition by t.games order by bronze desc)) as Max_Bronze
    	, concat(first_value(tm.country) over (partition by tm.games order by total_medals desc nulls last)
    			, ' - '
    			, first_value(tm.total_medals) over(partition by tm.games order by total_medals desc nulls last)) as Max_Medals
    from temp t
    join tot_medals tm on tm.games = t.games and tm.country = t.country
    order by games;

-- 18. Which countries have never won gold medal but have won silver/bronze medals?

with temp as (
select n.region as country,
sum(case when medal='Gold'then 1 else 0 end) as Gold_medals,
sum(case when medal='Silver'then 1 else 0 end) as Silver_medals,
sum(case when medal='Bronze'then 1 else 0 end) as Bronze_medals
from olympics_history oh join olympics_history_noc_regions n on oh.noc = n.noc
group by n.region,oh.games 
order by country
)
select * from temp where Gold_medals =0
order by Silver_medals,Bronze_medals desc limit 10;

-- 19. In which Sport/event, India has won highest medals.

with t1 as (select sport as sport, 
count(medal) as total_no_medal from
olympics_history 
where noc='IND' and medal in('Gold','Silver','Bronze')
group by sport),
t2 as(
select  
max(total_no_medal) as max from t1
)
select t1.sport,t1.total_no_medal from t1
join t2 on t1.total_no_medal = t2.max;

-- 20. Break down all olympic games where India
-- won medal for Hockey and how many medals in each olympic games

select team,sport,games, count(medal) as total_medals
from olympics_history where team='India' 
and sport= 'Hockey' and medal in ('Gold','Silver','Bronze')
group by team,sport,games order by count(medal) desc ;
