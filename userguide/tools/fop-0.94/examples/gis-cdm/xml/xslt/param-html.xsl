<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:import href="H:/docbook-xsl-1.73.0/html/docbook.xsl"/>

<xsl:param name="html.stylesheet" select="'../css/common.css'"/>
<xsl:param name="chapter.autolabel" select="1" />
<xsl:param name="section.autolabel" select="1" />
<xsl:param name="section.label.includes.component.label" select="1" />

<!-- Disable TOC generation for everything but <book /> -->
<xsl:param name="generate.toc" select="'book toc'"/>

</xsl:stylesheet>