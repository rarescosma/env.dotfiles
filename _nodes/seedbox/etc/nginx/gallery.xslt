<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" encoding="utf-8" indent="yes" />
<xsl:template match="/">
<xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
<html>
<head>
<title><xsl:value-of select="$title" /></title>
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<style>
body {
	margin: 0;
	padding: 0;
	background-color: black;
}

#photos {
	margin:auto;
	font-size: 0px;
}
</style>
</head>
<body>
<section id="photos">
<xsl:for-each select="list/file">
	<a href="{.}" title="click to enlarge"><img src="t/800x-/{.}" alt="{.}"/></a>
</xsl:for-each>
</section>
<script src="/Photos/.js/jquery-2.1.4.min.js"></script>
<script src="/Photos/.js/jquery.xgallerify.js"></script>
<script type="text/javascript">
$('#photos').gallerify({
	margin: 2,
	lastRow: 'adjust',
	mode: 'bootstrapv4',
	galleryMargin: 2,
});	
</script>
</body>
</html>
</xsl:template>
</xsl:stylesheet>
