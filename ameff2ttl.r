# Install en laad benodigde pakketten
library(stringr)
library(htmltools)
library(dplyr)
library(xml2)

# Functie om taallabel te zetten bij een SKOS definition of altLabel
taallabel <- function(label) {
  if ((label=="skos:definition") || (label=="skos:altLabel")) result <- "@nl ;" else result <- " ;"
  return(result)
}

# Functie om dataframe om te zetten naar SKOS Turtle-formaat
generate_ttl <- function(df,df_filtered_relationships, output_file) {
  ttl_lines <- c("@prefix skos: <http://www.w3.org/2004/02/skos/core#>.",
                 "@prefix dct: <http://purl.org/dc/terms/>.",
                 "@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>.",
                 "@prefix ameff: <http://archimate.org/> .", "")  # Pas de prefix aan naar je eigen namespace
  
  # Loop door alle unieke SKOS-concepten
  for (concept_id in unique(df$identifier)) {
    concept_rows <- df[df$identifier == concept_id, ]  # Selecteer alle rijen die bij dit concept horen
    subject <- paste0("ameff:", concept_id)
    
    ttl_lines <- c(ttl_lines, paste0(subject, " a skos:Concept ;"))
    ttl_lines <- c(ttl_lines, paste0("    skos:prefLabel \"", concept_rows$name[1], "\"@nl ;"))  # Neem eerste naam, want die is identiek binnen één concept
    
    # Voeg alle properties toe per concept
    for (i in 1:nrow(concept_rows)) {
      if (!is.na(concept_rows$propertyDefinitionName[i]) && !is.na(concept_rows$value[i])) {
        ttl_lines <- c(ttl_lines, paste0("    ", concept_rows$propertyDefinitionName[i], " \"", concept_rows$value[i], "\"", taallabel(concept_rows$propertyDefinitionName[i])))
      }
    }
    
    # Voeg alle relaties toe per concept
    related_rows <- df_filtered_relationships[df_filtered_relationships$source == concept_id, ]
    related_rows <- related_rows %>% filter(!is.na(target) & !is.na(type))
    related_rows <- na.omit(related_rows)  

    if (nrow(related_rows) > 0) {
      for (i in 1:nrow(related_rows)) {
        if (!is.na(related_rows$target[i]) && (related_rows$type[i]=="Association")) {
          ttl_lines <- c(ttl_lines, paste0("    skos:related ameff:", related_rows$target[i], " ;"))
        }
        if (!is.na(related_rows$target[i]) && (related_rows$type[i]=="Specialization")) {
          ttl_lines <- c(ttl_lines, paste0("    skos:narrower ameff:", related_rows$target[i], " ;"))
        }
        if (!is.na(related_rows$target[i]) && (related_rows$type[i]=="Composition")) {
          ttl_lines <- c(ttl_lines, paste0("    skos:narrower ameff:", related_rows$target[i], " ;"))
        }
      
      }
    }

    ttl_lines[length(ttl_lines)] <- sub(" ;$", " .", ttl_lines[length(ttl_lines)])  # Eindig laatste regel correct
    ttl_lines <- c(ttl_lines, "")
  } 
  
    # Schrijf naar TTL-bestand
    writeLines(ttl_lines, output_file)
  }
  
# Laad het Archimate Exchange XML-bestand
xml_file <- "C:\\Users\\jwvve\\Dropbox\\ArchiMate\\AI Architectuur2.xml"
xml_data <- read_xml(xml_file)
# Registreer de namespace
ns <- xml_ns(xml_data)

# Zoek alle propertyDefinition elementen
property_definitions <- xml_find_all(xml_data, "//*[local-name()='propertyDefinition']")
property_map <- setNames(xml_text(xml_find_all(property_definitions, "*[local-name()='name']")),
                         xml_attr(property_definitions, "identifier"))

# Zoek alle elementen met xsi:type="Meaning"
meaning_elements <- xml_find_all(xml_data, "//*[local-name()='element' and @xsi:type='Meaning']")

# Functie om properties veilig te extraheren
extract_properties <- function(element) {
  properties <- xml_find_all(element, ".//*[local-name()='property']")
  
  if (length(properties) == 0) {
    return(data.frame(identifier = xml_attr(element, "identifier"),
                      name = xml_text(xml_find_first(element, "*[local-name()='name']")),
                      propertyDefinitionName = NA,
                      value = NA,
                      stringsAsFactors = FALSE))
  }
  
  property_ids <- xml_attr(properties, "propertyDefinitionRef")
  property_values <- xml_text(xml_find_all(properties, "*[local-name()='value']"))
  
  # Vervang propertyDefinitionRef door de bijbehorende naam (let op : hierin moet de namespace worden opgenomen)
  property_names <- property_map[property_ids]
  
  data.frame(identifier = xml_attr(element, "identifier"),
             name = xml_text(xml_find_first(element, "*[local-name()='name']")),
             propertyDefinitionName = property_names,
             value = str_replace_all(htmlEscape(property_values),"[\r\n\"]"," "),
             stringsAsFactors = FALSE)
}

# Maak een dataframe met alle Meaning-elementen en hun properties
df_list <- lapply(meaning_elements, extract_properties)
df <- do.call(rbind, df_list)

# Zoek relaties
relationships <- xml_find_all(xml_data, "//*[local-name()='relationship']", ns)

# Extraheer details, inclusief xsi:type met expliciete namespace
df_relationships <- data.frame(
  identifier = xml_attr(relationships, "identifier"),
  source = xml_attr(relationships, "source"),
  target = xml_attr(relationships, "target"),
  type = xml_attr(relationships, "xsi:type", ns),  # Gebruik expliciete namespace
  stringsAsFactors = FALSE
)

# Filter relaties waarbij zowel source als target SKOS-concepten zijn
df_filtered_relationships <- df_relationships %>%
  filter(!is.na(source) & !is.na(target) & source %in% df$identifier & target %in% df$identifier)
  
# Voer de conversie uit en schrijf het NL-SBB SKOS bestand
generate_ttl(df,df_filtered_relationships, "nl-sbb.ttl")
