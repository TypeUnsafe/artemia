module fetchall

import artemia.redis

----
 id is mandatory for "artemia model"
----
struct human = {
		id
	,	firstName
	, lastName
}
augment human {
	function display = |this| ->
		println(
			"Human: id="+ this: id() + 
			" firstName=" + this: firstName() + 
			" lastName=" + this: lastName()
		)
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
 fetch all humans
 run it:
 golo golo --classpath jars/*.jar --files imports/artemia.jedis.collection.golo 02-fetch.golo
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
	
	# give me Bob
	println("=== Who is this Bob ===")
	let bob = humansCollection: fetch("bob_morane")
	bob: display()
	
	# fetch all human
	println("=== All humans ===")
	humansCollection: fetchAll("*"): each(|human| -> human: display())

	# fetch Doe Family
	println("=== Doe Family ===")
	humansCollection: fetchAll("*_doe"): each(|human| -> human: display())
	
	# fetch all animals
	println("=== All animals ===")
	animalsCollection: fetchAll("*"): each(|animal| -> println(animal))	

}