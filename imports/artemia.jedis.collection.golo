module artemia.redis

import redis.clients.jedis.Jedis

----
Old version of toMap
function toMap = |instanceStructure| {
  let mp = map[]
  let itr = instanceStructure: iterator()
  while itr: hasNext() {
    let tpl = itr: next()
    mp: put(tpl: get(0), tpl: get(1))
  }
  return mp
}
----
function toMap = |instanceStructure| -> 
  map[[fld: get(0), fld: get(1)] foreach fld in instanceStructure]

function fromMap = |instanceStructure, mapFields| {
  instanceStructure: members(): each(|fieldName| {
    instanceStructure: set(fieldName, mapFields: get(fieldName))
  })
  return instanceStructure
}

function jedis = |host, port| -> Jedis(host, port)


# generic augmentation
augmentation jedisCollection = {
  ----
    ## save: add to models() and save to redis database
    
    ## todo: change return value, check type of model
  ----
  function save = |this, instanceOfModel| {
    let type = instanceOfModel: getClass(): getSimpleName()   
    if this: models() is null { this: models(map[]) }
    this: models(): put(type+":"+instanceOfModel: id(), instanceOfModel)
    return this: db(): set(type+":"+instanceOfModel: id(), JSON.stringify(instanceOfModel))
  }
  function fetch = |this, key| {
    let type = this: model(): getClass(): getSimpleName() 
    if this: models() is null { this: models(map[]) }
    let model = fromMap(this: model(): copy(), JSON.parse(this: db(): get(type+":"+key)))
    this: models(): put(model: id(), model)
    return model
  }
  function fetchAll = |this, key| {
    let type = this: model(): getClass(): getSimpleName() 
    if this: models() is null { this: models(map[]) }
    let models = list[]
    this: db(): keys(type+":"+key): each(|key| {
      let model = fromMap(this: model(): copy(), JSON.parse(this: db(): get(key)))
      this: models(): put(model: id(), model)
      models: add(model)
    })
    return models
  }
  function destroy = |this, instanceOfModel| {
    let type = instanceOfModel: getClass(): getSimpleName() 
    this: db(): del(type+":"+instanceOfModel: id())
    this: models(): remove(type+":"+instanceOfModel: id())
  } 

} 
