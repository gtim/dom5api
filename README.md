# dom5api

REST API for the excellent [dom5inspector](https://github.com/larzm42/dom5inspector) data for Dominions 5. Although this project is in an early phase, you are very welcome to use it. If you'd like some particular endpoint or other feature for whatever project you're working on, please let me know and I'll make sure to prioritise it. 

## Examples

Access item by ID: [GET /items/337](https://dom5api.illwiki.com/items/337)

    {"id":337,
     "name":"Lightless Lantern",
     "type":"misc",
     "constlevel":6,
     "mainlevel":1,
     "mpath":"F1",
     "gemcost":"5F",
     "screenshot":"/items/337/screenshot"
    }
    
Access commander by exact name: [GET /commanders?name=sauromancer](https://dom5api.illwiki.com/commanders?name=sauromancer)

    {"commanders":[
      {"id":161,
       "name":"Sauromancer",
       "hp":12,
       "size":2,
       "screenshot":"/commanders/161/screenshot"
      },
      {"id":1036,
       "name":"Sauromancer",
       "hp":11,
       "size":2,
       "screenshot":"/commanders/1036/screenshot"
      }
    ]}
    
Access sites by fuzzy name matching: [GET /sites?name=flying+monks&match=fuzzy](https://dom5api.illwiki.com/sites?name=flying+monks&match=fuzzy)

    {"sites":[
      {"id":896,
       "name":"Temple of Flying Monkeys",
       "path":"Holy",
       "level":1,
       "rarity":"Rare",
       "screenshot":"/sites/896/screenshot"
      }
    ]}


## Endpoints

* `GET /items/:id`
* `GET /items/:id/screenshot`
* `GET /items?name=:name`
* `GET /items?match=fuzzy&name=:name`

* `GET /spells/:id`
* `GET /spells/:id/screenshot`
* `GET /spells?name=:name`
* `GET /spells?match=fuzzy&name=:name`

* `GET /commanders/:id`
* `GET /commanders/:id/screenshot`
* `GET /commanders?name=:name`
* `GET /commanders?match=fuzzy&name=:name`

* `GET /sites/:id`
* `GET /sites/:id/screenshot`
* `GET /sites?name=:name`
* `GET /sites?match=fuzzy&name=:name`

* `GET /mercs/:id`
* `GET /mercs/:id/screenshot`
* `GET /mercs?name=:name`
* `GET /mercs?match=fuzzy&name=:name`

Feel free to use it. It's available at https://dom5api.illwiki.com/
