<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <!-- Modèle correspondant au nœud racine du script Traceur -->
  <xsl:template match="/TraceurScript">

    <xsl:variable name="maxX">
      <xsl:value-of select="max(LINETO/@x)"/>
    </xsl:variable>
    <xsl:variable name="maxY">
      <xsl:value-of select="max(LINETO/@y)"/>
    </xsl:variable>
    <xsl:variable name="minX">
      <xsl:value-of select="min(LINETO/@x)"/>
    </xsl:variable>
    <xsl:variable name="minY">
      <xsl:value-of select="min(LINETO/@y)"/>
    </xsl:variable>
    
    <!-- Calcule la hauteur et la largeur du conteneur SVG en ajoutant les marges -->
    <xsl:variable name="svgHeight" select="$maxY - $minY"/>
    <xsl:variable name="svgWidth" select="$maxX - $minX"/>
 
    <!-- Définit le viewBox pour englober l'ensemble du dessin -->
    <xsl:variable name="viewBox" select="concat($minX, ' ', $minY, ' ', $svgWidth, ' ', $svgHeight)"/>
 
    <!-- Générer le chemin SVG -->
    <svg xmlns="http://www.w3.org/2000/svg" version="1.0" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="{$viewBox}">
     
        <path stroke="purple" stroke-width="3" fill="none">
          <xsl:attribute name="d">
            <!-- Utilise les coordonnées minimales comme point de départ -->
            <xsl:text>M </xsl:text>
            <xsl:value-of select="$minX - $minX"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="$minY - $minY"/>
            <!-- Applique les instructions MOVETO et LINETO -->
            <xsl:apply-templates select="MOVETO"/>
            <xsl:apply-templates select="LINETO"/>
          </xsl:attribute>
        </path>
    </svg>
  </xsl:template>
  
  <!-- Modèle correspondant à l'élément MOVETO -->
  <xsl:template match="MOVETO">
    <!-- Utilise les coordonnées ajustées pour MOVETO -->
    <xsl:value-of select="concat('M ', @x, ' ', @y, ' ')"/>
  </xsl:template>
  
  <!-- Modèle correspondant à l'élément LINETO -->
  <xsl:template match="LINETO">
    <!-- Utilise les coordonnées ajustées pour LINETO -->
    <xsl:value-of select="concat('L ', @x, ' ', @y, ' ')"/>
  </xsl:template>

  
</xsl:transform>