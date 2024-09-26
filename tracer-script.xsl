<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math">
    
    <xsl:output method="xml" indent="yes"/>
    
    <!-- Déclaration de la constante π -->
    <xsl:variable name="pi" select="math:pi()"/>

    <!-- Template principal -->
    <xsl:template match="/">
        <TraceurScript>
            <!-- Initialisation des variables -->
            <xsl:variable name="currentX" select="0"/>
            <xsl:variable name="currentY" select="0"/>
            <xsl:variable name="currentAngle" select="0"/>
            <!-- Appel du template initial avec les paramètres initiaux -->
            <xsl:apply-templates select="/TortueScript/Instructions/Instruction[1]">
                <xsl:with-param name="x" select="$currentX"/>
                <xsl:with-param name="y" select="$currentY"/>
                <xsl:with-param name="angle" select="$currentAngle"/>
            </xsl:apply-templates>
        </TraceurScript>
    </xsl:template>

    <!-- Template pour le traitement de chaque instruction -->
    <xsl:template match="Instruction">
        <xsl:param name="x"/>
        <xsl:param name="y"/>
        <xsl:param name="angle"/>
        <xsl:variable name="value" select="number(Value)"/>
        <xsl:choose>
            <!-- Appel du template correspondant au type d'instruction -->
            <xsl:when test="Type = 'LINE'">
                <xsl:call-template name="ProcessLine">
                    <xsl:with-param name="x" select="$x"/>
                    <xsl:with-param name="y" select="$y"/>
                    <xsl:with-param name="angle" select="$angle"/>
                    <xsl:with-param name="value" select="$value"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="Type = 'MOVE'">
                <xsl:call-template name="ProcessMove">
                    <xsl:with-param name="x" select="$x"/>
                    <xsl:with-param name="y" select="$y"/>
                    <xsl:with-param name="angle" select="$angle"/>
                    <xsl:with-param name="value" select="$value"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="Type = 'TURN'">
                <xsl:call-template name="ProcessTurn">
                    <xsl:with-param name="x" select="$x"/>
                    <xsl:with-param name="y" select="$y"/>
                    <xsl:with-param name="angle" select="$angle"/>
                    <xsl:with-param name="value" select="$value"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="Type = 'STORE'">
                <!-- Balise STORE vide -->
                <STORE/>
                <!-- Appel récursif avec l'instruction suivante -->
                <xsl:apply-templates select="following-sibling::Instruction[1]">
                    <xsl:with-param name="x" select="$x"/>
                    <xsl:with-param name="y" select="$y"/>
                    <xsl:with-param name="angle" select="$angle"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="Type = 'RESTORE'">
                <!-- Balise RESTORE vide -->
                <RESTORE/>
                <!-- Appel récursif avec l'instruction suivante -->
                <xsl:apply-templates select="following-sibling::Instruction[1]">
                    <xsl:with-param name="x" select="$x"/>
                    <xsl:with-param name="y" select="$y"/>
                    <xsl:with-param name="angle" select="$angle"/>
                </xsl:apply-templates>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- Template pour le traitement des instructions de type LINE -->
    <xsl:template name="ProcessLine">
        <xsl:param name="x"/>
        <xsl:param name="y"/>
        <xsl:param name="angle"/>
        <xsl:param name="value"/>
        <!-- Calcul des nouvelles coordonnées -->
        <xsl:variable name="newX" select="round($x + $value * math:cos($pi * $angle div 180), 8)"/>
        <xsl:variable name="newY" select="round($y + $value * math:sin($pi * $angle div 180), 8)"/>
        <!-- Remplacement des valeurs très proches de zéro par zéro -->
        <xsl:variable name="finalX" select="if(abs($newX) &lt; 0.00000001) then 0 else $newX"/>
        <xsl:variable name="finalY" select="if(abs($newY) &lt; 0.00000001) then 0 else $newY"/>
        <!-- Création de l'élément LINETO -->
        <LINETO x="{$finalX}" y="{$finalY}"/>
        <!-- Appel récursif avec l'instruction suivante -->
        <xsl:apply-templates select="following-sibling::Instruction[1]">
            <xsl:with-param name="x" select="$finalX"/>
            <xsl:with-param name="y" select="$finalY"/>
            <xsl:with-param name="angle" select="$angle"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- Template pour le traitement des instructions de type MOVE -->
    <xsl:template name="ProcessMove">
        <xsl:param name="x"/>
        <xsl:param name="y"/>
        <xsl:param name="angle"/>
        <xsl:param name="value"/>
        <!-- Calcul des nouvelles coordonnées -->
        <xsl:variable name="newX" select="round($x + $value * math:cos($pi * $angle div 180), 8)"/>
        <xsl:variable name="newY" select="round($y + $value * math:sin($pi * $angle div 180), 8)"/>
        <!-- Remplacement des valeurs très proches de zéro par zéro -->
        <xsl:variable name="finalX" select="if(abs($newX) &lt; 0.00000001) then 0 else $newX"/>
        <xsl:variable name="finalY" select="if(abs($newY) &lt; 0.00000001) then 0 else $newY"/>
        <!-- Création de l'élément MOVETO -->
        <MOVETO x="{$finalX}" y="{$finalY}"/>
        <!-- Appel récursif avec l'instruction suivante -->
        <xsl:apply-templates select="following-sibling::Instruction[1]">
            <xsl:with-param name="x" select="$finalX"/>
            <xsl:with-param name="y" select="$finalY"/>
            <xsl:with-param name="angle" select="$angle"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- Template pour le traitement des instructions de type TURN -->
    <xsl:template name="ProcessTurn">
        <xsl:param name="x"/>
        <xsl:param name="y"/>
        <xsl:param name="angle"/>
        <xsl:param name="value"/>
        <!-- Mise à jour de l'angle -->
        <xsl:variable name="newAngle" select="$angle + $value"/>
        <!-- Appel récursif avec l'instruction suivante -->
        <xsl:apply-templates select="following-sibling::Instruction[1]">
            <xsl:with-param name="x" select="$x"/>
            <xsl:with-param name="y" select="$y"/>
            <xsl:with-param name="angle" select="$newAngle"/>
        </xsl:apply-templates>
    </xsl:template>

</xsl:transform>

