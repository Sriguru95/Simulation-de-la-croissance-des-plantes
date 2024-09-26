**Projet de XML : Les L-Systèmes**

**Informations des Étudiant**
- ****Nom**** : ELUMALAI
- ****Prénom**** : Sriguru
- ****Numéro étudiant**** : 22320777
- ****Nom**** : MAMBILA TETE
- ****Prénom**** : Jean-Philipp
- ****Numéro étudiant**** : 22304110

**Description du Projet**
Ce projet vise à utiliser les L-Systèmes pour générer des dessins en utilisant des transformations XML. Le processus comprend l'extraction de données, la transformation via XSLT, et la génération de fichiers SVG.

**Commandes**

**1. Extraction des données csv avec** **`csv_to_xml.c`**

```bash
gcc csv_to_xml.c

./a.out fichier.csv
```

Cela générera le fichier suivant : `fichier.csv.xml`.

**2. Exécution des 3 transformations XSLT à la suite, utilisez le script** **`script.sh`**

```bash
./script.sh nom_du_lsysteme nbre_iterations
```

Cela générera les fichiers suivants : `output1.xml`, `output2.xml`, `output3.svg`.

**3. Exécution manuelle des transformations**

**a) Extraction du script pour la Tortue à partir du fichier `l-systems.csv.xml`.**

Utilisez la commande suivante :

```bash
java -jar saxon-he-10.3.jar -s:l-systems.csv.xml -xsl:turtle-script.xsl lsysName="nom_du_lsysteme" n="nbre_iterations" -o:output1.xml
```

Cela générera le fichier `output1.xml`.

**b) Conversion en un script pour le Traceur à partir du fichier `output1.xml`.**

Utilisez la commande suivante :

```bash
java -jar saxon-he-10.3.jar -s:output1.xml -xsl:tracer-script.xsl -o:output2.xml
```

Cela générera le fichier `output2.xml`.

**c) Conversion au format SVG  à partir du fichier `output2.xml`.**

Utilisez la commande suivante :

```bash
java -jar saxon-he-10.3.jar -s:output2.xml -xsl:convertToSVG.xsl -o:output3.svg
```

Cela générera le fichier `output3.svg`.

**Remarques**

   - Le script `csv_to_xml.c` doit être compilé et exécuter avant dexecuter les commandes suivantes.
   - Assurez-vous que tous les fichiers XSLT (`turtle-script.xsl`, `tracer-script.xsl`, `convertToSVG.xsl`) sont présents dans le même répertoire que