# dom5api

REST API for Dominions 5 data via the [dom5inspector](https://github.com/larzm42/dom5inspector). Although this project is in an early phase, you are already welcome to use it. If you'd like some particular endpoint or other feature for whatever project you're working on, please let me know and I'll make sure to prioritise it. The API is available at [dom5api.illwiki.com](https://dom5api.illwiki.com/).


## Examples

Get item by ID: [GET /items/337](https://dom5api.illwiki.com/items/337)

    {"id":337,
     "name":"Lightless Lantern",
     "type":"misc",
     "constlevel":6,
     "mainlevel":1,
     "mpath":"F1",
     "gemcost":"5F",
     "screenshot":"/items/337/screenshot"
    }
    
Get commander by exact name: [GET /commanders?name=sauromancer](https://dom5api.illwiki.com/commanders?name=sauromancer)

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
    
Get sites by fuzzy name matching: [GET /sites?name=flying+monks&match=fuzzy](https://dom5api.illwiki.com/sites?name=flying+monks&match=fuzzy)

    {"sites":[
      {"id":896,
       "name":"Temple of Flying Monkeys",
       "path":"Holy",
       "level":1,
       "rarity":"Rare",
       "screenshot":"/sites/896/screenshot"
      }
    ]}


## API Endpoints


| Endpoint | Response | Description |
| --- | --- | --- |
| **By ID** |  | |
| [/items/:id](https://dom5api.illwiki.com/items/337) | Item | Get item by ID |
| [/spells/:id](https://dom5api.illwiki.com/spells/808) | Spell | Get spell by ID |
| [/commanders/:id](https://dom5api.illwiki.com/commanders/479) | Unit | Get commander by ID |
| [/units/:id](https://dom5api.illwiki.com/units/538) | Unit | Get unit by ID |
| [/sites/:id](https://dom5api.illwiki.com/sites/584) | Site | Get site by ID |
| [/mercs/:id](https://dom5api.illwiki.com/mercs/60) | Merc | Get mercenary by ID |
| **By exact name** |  | |
| [/items?name=:name](https://dom5api.illwiki.com/items?name=staff+of+elemental+mastery) | List of Items | Get items by exact name match |
| [/spells?name=:name](https://dom5api.illwiki.com/spells?name=acashic+record) | List of Spells | Get spells by exact name match |
| [/commanders?name=:name](https://dom5api.illwiki.com/commanders?name=jotun+skratti) | List of Units | Get commanders by exact name match |
| [/units?name=:name](https://dom5api.illwiki.com/units?name=theurg+communicant) | List of Units | Get units by exact name match |
| [/sites?name=:name](https://dom5api.illwiki.com/sites?name=library) | List of Sites | Get sites by exact name match |
| [/mercs?name=:name](https://dom5api.illwiki.com/mercs?name=Nergash's+Damned+Legion) | List of Mercs | Get mercenaries by exact name match |
| **By approximate name** |  | |
| [/items?name=:name&match=fuzzy](https://dom5api.illwiki.com/items?name=elemental+mastery&match=fuzzy) | List of Items | Get items by fuzzy name search |
| [/spells?name=:name&match=fuzzy](https://dom5api.illwiki.com/spells?name=acathic+record&match=fuzzy) | List of Spells | Get spells by fuzzy name search |
| [/commanders?name=:name&match=fuzzy](https://dom5api.illwiki.com/commanders?name=jotun+skurt&match=fuzzy) | List of Units | Get commanders by fuzzy name search |
| [/units?name=:name&match=fuzzy](https://dom5api.illwiki.com/units?name=communicant&match=fuzzy) | List of Units | Get units by fuzzy name search |
| [/sites?name=:name&match=fuzzy](https://dom5api.illwiki.com/sites?name=churning+ocean&match=fuzzy) | List of Sites | Get sites by fuzzy name search |
| [/mercs?name=:name&match=fuzzy](https://dom5api.illwiki.com/mercs?name=nergash&match=fuzzy) | List of Mercs | Get mercenaries by fuzzy name search |
| **Inspector screenshots** |  | |
| [/items/:id/screenshot](https://dom5api.illwiki.com/items/337/screenshot) | Image | Get dom5inspector screenshot of item by ID |
| [/spells/:id/screenshot](https://dom5api.illwiki.com/spells/808/screenshot) | Image | Get dom5inspector screenshot of spell by ID |
| [/commanders/:id/screenshot](https://dom5api.illwiki.com/commanders/479/screenshot) | Image | Get dom5inspector screenshot of commander by ID |
| [/units/:id/screenshot](https://dom5api.illwiki.com/units/538/screenshot) | Image | Get dom5inspector screenshot of unit by ID |
| [/sites/:id/screenshot](https://dom5api.illwiki.com/sites/584/screenshot) | Image | Get dom5inspector screenshot of site by ID |
| [/mercs/:id/screenshot](https://dom5api.illwiki.com/mercs/60/screenshot) | Image | Get dom5inspector screenshot of mercenary by ID |

## Response objects

All responses are JSON-encoded. The returned objects are currently bare-bones, but I aim to include all the information supplied by the dom5inspector. Property names are mostly the same as those used by the inspector. 

### Item

| Property | Example value | Notes | 
| -------- | ------------- | ----------- |
| id | 337 |  |
| name | Lightless lantern | |
| type | misc | Slot type, one of: 1-h wpn, 2-h wpn, shield, helm, crown, armor, boots, misc. |
| constlevel | 6 |  |
| mpath | F1 |  |
| gemcost | 5F | |
| screenshot | /items/337/screenshot | Link to dom5inspector screenshot |

### Spell

| Property | Example value | Notes | 
| -------- | ------------- | ----------- |
| id | 808 |  |
| name | Acashic Knowledge | |
| type | Ritual | Combat or Ritual |
| mpath | S3 |  |
| gemcost | 25S | |
| school | Conjuration | |
| researchlevel | 6 | |
| screenshot | /spells/808/screenshot | Link to dom5inspector screenshot |

### Unit (including commanders)

| Property | Example value | Notes | 
| -------- | ------------- | ----------- |
| id | 538 |  |
| name | Theurg Communicant | |
| size | 2 |  |
| hp | 10 | |
| screenshot | /units/538/screenshot | Link to dom5inspector screenshot |


### Site

| Property | Example value | Notes | 
| -------- | ------------- | ----------- |
| id | 584 |  |
| name | Library | |
| path | Astral |  |
| level | 0 | |
| rarity | Uncommon | Possible values are `Common`, `Uncommon`, `Rare`, `Never random`, `Throne lvl1`, `Throne lvl2` and `Throne lvl3`, corresponding to 0, 1, 2, 5, 11, 12, 13 as defined in Illwinter's [Modding Manual](https://www.illwinter.com/dom5/modmanual.html). |
| screenshot | /sites/584/screenshot | Link to dom5inspector screenshot |

### Merc

| Property | Example value | Notes | 
| -------- | ------------- | ----------- |
| id | 60 |  |
| name | Nergash's Damned Legion | |
| bossname | Nergash |  |
| commander_id | 310 | Key to `/commanders/:id` endpoint. |
| unit_id | 195 | Key to `/units/:id` endpoint. |
| nrunits | 80 | Key to `/units/:id` endpoint. |
| screenshot | /mercs/60/screenshot | Link to dom5inspector screenshot |



