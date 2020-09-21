# covid_france
Covid-19 has clearly touched virtually everyone of us globally, and while there are already a large number of very fine graphs and metrics to track Covid trend, I was interested to track three key measures in France, and visually see where hot spots are taking place. I specifically opted to not cover the number of cases, as a more volatile and not interesting figure.  Rather I looked at the three following  

- Hospitalization rate
- Death rate
- Mortality rate

The shiny application can be found at https://mrcherve.shinyapps.io/covid_france2/

Users can select:
- A look back period ranging from 1 to 62 days (i.e. 2 months)
- One of the three tracking metric
- Either "France" or one of the 95 departments (equivalent of US counties or state)

Data are pooled from 4 inputs:
- Cumulative data from Covid-19 inception to date (www.data.gouv.fr/fr/datasets)
- Daily new (i.e. delta from T-1) data from Covid-19 inception to date (www.data.gouv.fr/fr/datasets)
- Population by department (insee.fr/en/statistiques)
- Department names and GPS location (insee.fr/en/statistiques)
