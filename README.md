# darkrp-cleanrpnames
A DarkRP module for removing RP names from old users.

Idk if this works or not, but if it does then great.

The idea is you probably restart your server every day or something, so this checks all your users' roleplay names once your server's started, and decides whether their name should be freed up or not based on the last time they've logged on.

Obviously that's probably a hell of a load for your server if you've got a lot of players in your database. So things *might* not perform great for a short bit.

Everytime a player connects this also updates a `last_joined` entry in the database with the current time. Further impacting your server's potential performance.
