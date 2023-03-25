use sakila;

# 1.List each pair of actors that have worked together.

# I will create a view containing a CTE for this exercise
create view collaborations as
with pairs_of_actors as (
	select 
    fa1.actor_id as actor_1,
    fa2.actor_id as actor_2,
    fa1.film_id
	from
    film_actor fa1
        join
    film_actor fa2
	where
    fa1.film_id = fa2.film_id
        and fa1.actor_id < fa2.actor_id)
select 
pa.actor_1, 
a1.first_name as first_name1, 
a1.last_name as last_name1, 
pa.actor_2, 
a2.first_name as first_name2, 
a2.last_name as last_name2, 
pa.film_id, 
f.title as film_title 
from 
pairs_of_actors pa
	join actor a1
		on pa.actor_1 = a1.actor_id # creating a connection between the correct actor_ids, in order to extract the name of the actor
	join actor a2
		on pa.actor_2 = a2.actor_id # same as above
	join film f
		using (film_id); # extracting the name of the film

select * from collaborations;
# 14915 rows returned


# 2.For each film, list actor that has acted in more films.

# I will first create a CTE, on which I will then perform a self join
with per_film_prolific as (
	select 
    fa.film_id, 
    f.title, 
    fa.actor_id, 
    a.first_name, 
    a.last_name 
    from 
    film_actor fa
		join actor a
			using (actor_id)
		join film f
			using (film_id))
select 
p1.title,
p2.first_name,
p2.last_name,
count(p2.film_id) as num_films
from 
per_film_prolific p1
	join
		per_film_prolific p2
			using (actor_id)
group by 
p1.title,
p2.first_name,
p2.last_name
having count(p2.film_id) in (select 
								count(film_id) as num_films
								from 
                                per_film_prolific	# referring to the same CTE in my subquery to access only those counts of films that correspond to the most prolific actors per film
								group by actor_id
                                order by num_films desc)
order by num_films desc;
# 5462 rows returned