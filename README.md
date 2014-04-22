## Chef cookbook to handle removing puppet and it's crons

I wrote this a looong time ago. There is a re-implementation of the cron provider so that it understands puppet crons. 
This provider needs a rewrite to chef11.

## Recipes

### Default
  removes puppet and facter packages.
  Includes an example of a puppet cron remove
