<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!-- Default XSL for FO output -->
<xsl:import href="../tools/docbook/fo/docbook.xsl"/>

<!-- Bring in title page customizations -->
<xsl:include href="custom-titlepage.xsl" />

<!-- Page margins -->
<xsl:param name="body.start.indent" select="'0pt'" />
<xsl:param name="page.margin.inner" select="'0.5in'" />
<xsl:param name="page.margin.outer" select="'0.5in'" />

<!-- Font Selection -->
<xsl:param name="body.font.family" >Helvetica</xsl:param>
<xsl:param name="title.font.family" >Helvetica</xsl:param>

<!-- Chapter and section autolabeling -->
<xsl:param name="chapter.autolabel" select="1" />
<xsl:param name="section.autolabel" select="1" />
<xsl:param name="section.label.includes.component.label" select="1" />

<!-- Disable TOC generation for everything but <book /> -->
<xsl:param name="generate.toc" select="'book toc'"/>

<!-- Font properties for <title> -->
<xsl:attribute-set name="component.title.properties">
	<xsl:attribute name="font-size">
		<xsl:value-of select="$body.font.master * 1.6" />
		<xsl:text>pt</xsl:text>
	</xsl:attribute>
</xsl:attribute-set>

<!-- Font properties for <sect1> -->
<xsl:attribute-set name="section.title.level1.properties">
	<xsl:attribute name="background-color">#E0E0E0</xsl:attribute>
	
	<xsl:attribute name="font-size">
		<xsl:value-of select="$body.font.master * 1.4" />
		<xsl:text>pt</xsl:text>
	</xsl:attribute>
</xsl:attribute-set>

<!-- Font properties for <sect2> -->
<xsl:attribute-set name="section.title.level2.properties">
	<xsl:attribute name="font-size">
		<xsl:value-of select="$body.font.master * 1.2" />
		<xsl:text>pt</xsl:text>
	</xsl:attribute>
</xsl:attribute-set>

<!-- Font properties for <sect3> -->
<xsl:attribute-set name="section.title.level3.properties">
	<xsl:attribute name="font-size">
		<xsl:value-of select="$body.font.master * 1.0" />
		<xsl:text>pt</xsl:text>
	</xsl:attribute>
</xsl:attribute-set>

<!-- Adjust the spacing and margins for a list block -->
<xsl:attribute-set name="list.block.spacing">
	<xsl:attribute name="margin-left">
		<xsl:choose>
			<xsl:when test="self::itemizedlist">0.25in</xsl:when>
			<xsl:otherwise>0pt</xsl:otherwise>
		</xsl:choose>
	</xsl:attribute>
</xsl:attribute-set>

<!-- Adjust the spacing between list items -->
<xsl:attribute-set name="list.item.spacing">
	<xsl:attribute name="space-before.optimum">0.2em</xsl:attribute>
	<xsl:attribute name="space-before.minimum">0.1em</xsl:attribute>
	<xsl:attribute name="space-before.maximum">0.3em</xsl:attribute>
</xsl:attribute-set>

</xsl:stylesheet>
