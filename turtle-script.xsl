
<xsl:transform version="2.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xsd="http://www.w3.org/2001/XMLSchema"
               xmlns:my="http://example.com/myfunctions">

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

    <xsl:param name="lsysName" as="xsd:string" select="//LSys[1]/Name"/> <!--par default prend le 1er lsysteme-->
    <xsl:param name="n" as="xsd:integer" select="2"/> <!--par default le rang vaut 2-->

    <!-- Fonction pour appliquer les itérations récursivement -->
    <xsl:function name="my:applyIterations" as="xsd:string">
        <xsl:param name="axiom" as="xsd:string"/>
        <xsl:param name="symbols" as="element(Symbol)*"/>
        <xsl:param name="substitutions" as="element(Substitution)*"/>
        <xsl:param name="currentIteration" as="xsd:integer"/>
        <xsl:param name="totalIterations" as="xsd:integer"/>

        <!-- Contenu de la fonction my:applyIterations -->
        <xsl:choose>
            <xsl:when test="$currentIteration eq $totalIterations">
                <!-- Résultat de l'itération courante -->
                <xsl:value-of select="$axiom"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- Appliquer les substitutions pour obtenir le nouvel axiome -->
                <xsl:variable name="newAxiom" select="my:applySubstitutions($axiom, $symbols, $substitutions)"/>
                <!-- Appel récursif pour les itérations suivantes -->
                <xsl:sequence select="my:applyIterations($newAxiom, $symbols, $substitutions, $currentIteration + 1, $totalIterations)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

 
    <!-- Fonction pour appliquer les substitutions -->
    <xsl:function name="my:applySubstitutions" as="xsd:string">
        <xsl:param name="axiom" as="xsd:string"/>
        <xsl:param name="symbols" as="element(Symbol)*"/>
        <xsl:param name="substitutions" as="element(Substitution)*"/>

        <!-- Contenu de la fonction my:applySubstitutions -->
        <xsl:variable name="resultSequence" as="item()*">
            <!-- Parcours de chaque caractère de l'axiome -->
            <xsl:for-each select="string-to-codepoints($axiom)">
                <xsl:variable name="symbol" as="xsd:string" select="codepoints-to-string(.)"/>
                <!-- Recherche de la substitution associée -->
                <xsl:variable name="substitution" as="element(Substitution)*" select="$substitutions[SymbolRef/@idref = $symbols[text() = $symbol]/@id]"/>
                <!-- Ajout de l'image associée à la substitution à la séquence de résultats -->
                <xsl:sequence select="$substitution/Image"/>
            </xsl:for-each>
        </xsl:variable>

        <!-- Concaténation des résultats sans espaces -->
        <xsl:value-of select="string-join($resultSequence, '')"/>
    </xsl:function>


    <!-- Fonction pour interpréter les symboles -->
    <xsl:function name="my:interpretSymbols" as="element(Instruction)*">
        <xsl:param name="result" as="xsd:string"/>
        <xsl:param name="interpretations" as="element(Interpretation)*"/>
        <xsl:param name="symbols" as="element(Symbol)*"/>

        <!-- Contenu de la fonction my:interpretSymbols -->
        <xsl:variable name="instructions" as="element(Instruction)*">
            <!-- Parcours de chaque symbole de la chaîne résultante -->
            <xsl:for-each select="string-to-codepoints($result)">
                <xsl:variable name="symbol" as="xsd:string" select="codepoints-to-string(.)"/>
                <xsl:choose>
                    <xsl:when test="$symbol = '['"> <!-- Si le symbole est '[' -->
                        <Instruction>
                            <Type>STORE</Type>
                        </Instruction>
                    </xsl:when>
                    <xsl:when test="$symbol = ']'"> <!-- Si le symbole est ']' -->
                        <Instruction>
                            <Type>RESTORE</Type>
                        </Instruction>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Recherche de l'interprétation associée au symbole -->
                        <xsl:variable name="interpretation" as="element(Interpretation)*" select="$interpretations[SymbolRef/@idref = $symbols[text() = $symbol]/@id]"/>
                        <!-- Séparation du type et de la valeur -->
                        <xsl:variable name="instructionParts" select="tokenize($interpretation/Instruction, '\s+')"/>
                        <!-- Ajout de l'instruction correspondante à la séquence de résultats -->
                        <Instruction>
                            <Type><xsl:value-of select="$instructionParts[1]"/></Type>
                            <Value><xsl:value-of select="$instructionParts[2]"/></Value>
                        </Instruction>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>

        <!-- Renvoie la séquence d'instructions -->
        <xsl:sequence select="$instructions"/>
    </xsl:function>

    
    <!-- Modèle principal -->
    <xsl:template match="/">
        <!-- Sélectionne le LSys correspondant au nom spécifié -->
        <xsl:variable name="selectedLSys" select="//LSys[Name=$lsysName]" />
        <!-- Récupère l'axiome initial -->
        <xsl:variable name="axiom" select="$selectedLSys/Axiom"/>
        
        <TortueScript>
            <Instructions>
                <!-- Vérifie que $n est strictement supérieur à 0 -->
                <xsl:choose>
                    <xsl:when test="$n > 0">
                        <!-- Applique les itérations pour le nombre spécifié -->
                        <xsl:variable name="result" select="my:applyIterations($axiom, $selectedLSys/Symbols/Symbol, $selectedLSys/Substitutions/Substitution, 1, $n)"/>
                        <!-- Interprète les symboles pour obtenir les instructions -->
                        <xsl:variable name="instructions" select="my:interpretSymbols($result, $selectedLSys/Interpretations/Interpretation, $selectedLSys/Symbols/Symbol)"/>
                        <!-- Parcours les instructions -->
                        <xsl:copy-of select="$instructions"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Si $n n'est pas supérieur à 0, affiche un message d'erreur -->
                        <xsl:text>Erreur : La valeur de n doit être strictement supérieure à 0.</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </Instructions>
        </TortueScript>
    </xsl:template>


</xsl:transform>