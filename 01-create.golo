module create

import artemia.redis

----
 id is mandatory for "artemia model"
----
struct human = {
		id
	,	firstName
	, lastName
}

struct animal = {
	id, name, species
}
----
 redis helper
----
struct redisHelper = {
  db, models, model
}
augment redisHelper with jedisCollection

----
 Create some humans
 run it:
 golo golo --classpath jars/*.jar --files imports/artemia.jedis.collection.golo 01-create.golo
----
function main = |args| {
	let redis = jedis("localhost", 6379)

	let humansCollection = 
		redisHelper()
			: model(human())
			: db(redis)

	let animalsCollection = 
		redisHelper()
			: model(animal())
			: db(redis)
			
	let bob = human(id="bob_morane", firstName="Bob", lastName="Morane")
	let john = human(id="john_doe", firstName="John", lastName="Doe")
	let jane = human(id="jane_doe", firstName="Jane", lastName="Doe")
	
	let wolf = animal("wolf", "Wolf", "dog")
	let pinky = animal("pinky", "Pinky", "pig")
	
	humansCollection: save(bob)
	humansCollection: save(john)
	humansCollection: save(jane)
	
	println("all humans are saved")
	
	animalsCollection: save(wolf)
	animalsCollection: save(pinky)	
	
	println("all animals are saved")
}