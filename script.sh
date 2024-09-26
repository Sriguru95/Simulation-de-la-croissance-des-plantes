#!/bin/bash

# Vérifier le nombre d'arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <lsysName> <iterations>"
    exit 1
fi

# Assigner les arguments à des variables
lsysName="$1"
iterations="$2"

# Exécute les trois commandes l'un a la suite de l'autre
java -jar saxon-he-10.3.jar -s:l-systems.csv.xml -xsl:turtle-script.xsl lsysName="$lsysName" n="$iterations" -o:output1.xml 


java -jar saxon-he-10.3.jar -s:output1.xml -xsl:tracer-script.xsl -o:output2.xml 


java -jar saxon-he-10.3.jar -s:output2.xml -xsl:convertToSVG.xsl -o:output3.svg 


echo "Toutes les commandes ont été exécutées avec succès."
