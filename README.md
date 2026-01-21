De NL-SBB begrippenstandaard biedt een gestructureerde manier om concepten en hun relaties vast te leggen. 
Binnen ArchiMate kan dit ook worden toegepast met het Meaning-object uit de Motivatielaag, gecombineerd met eigenschappen zoals skos:definition en skos:altLabel. 
Hierbij kun je een view gebruiken om de begrippen op te zetten en waar de nodig te relateren.

Archi, een populaire tool voor ArchiMate-modellering, biedt een intuïtieve manier om begrippen en hun semantiek vast te leggen:
*	Gebruik van het Meaning-object om een begrip te definiëren binnen een model.
*	Het formulier van Archi kan worden gebruikt om skos:definition (Nederlandse definitie) en skos:altLabel (alternatieve termen) eenvoudig in te voeren. En andere kenmerken uiteraard.

Om deze begrippen vanuit Archi te publiceren als NL-SBB-compliant Turtle (TTL)-bestanden, wordt een R-script gebruikt. Dit script:
1.	Extraheert de Meaning-objecten en hun properties vanuit een Archimate Exchange XML-bestand.
2.	Converteert de relaties naar SKOS-triples zoals skos:related en skos:narrower.
3.	Genereert een geldig TTL-bestand dat kan worden ingeladen in een triplestore, zoals BegrippenXL.

Het resultaat kan dan weer ingeladen worden in een begrippenviewer zoals BegrippenXL : https://www.begrippenxl.nl/ai/nl/


