# double round-robin generator for up to 20 players

* generates a simple, randomized HTML table and corresponding SQL querys
* edit players.txt
* then run:

```
perl ./\roundrobin_generator.pl >out.html
```

```
Execute querys form sql.txt in tournament.sqlite
```

* start results and rankings server
```
cd results/bin
perl ./\app.pl
```

