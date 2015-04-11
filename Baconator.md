# Introduction #

I wrote this PowerShell script as I wanted the ability to create lots of Components with random content for test purposes. While searching for "lorem ipsum" alternatives, I came across the meat-flavored [baconipsum.com](http://www.baconipsum.com). So I wrote this script to pull down the generator paragraphs and create article Components based on them.

**Important**: The script requires the [Tridion PowerShell Modules](https://code.google.com/p/tridion-powershell-modules/) available on Google Project.

# Details #

To use the script, load it using the dot notation:

`. .\Baconator.ps1`



Then create the Schema by calling Add-SchemaForBaconArticles and passing in the TCM URI of the Folder where you want it to be stored.


Example:

`Add-SchemaForBaconArticles -folderId 'tcm:1-2-2'`



After that, you can create as many Components as you want by calling Add-BaconArticles and specifying the TCM URI of the Folder where you want them to be stored, and the TCM URI of the Schema created above. Optionally, specify the number of Components to create (the default is 5).


Example:

`Add-BaconArticles -folderId 'tcm:1-3-2' -schemaId 'tcm:1-58-8' -numberOfArticles 10`


That's all, folks!
Use the Baconator with care ;)


# The Script #
Save the following code as 'Baconator.ps1' in a directory of your choosing:

```
#Requires -version 2.0

# Allows using relative paths for scripts and other files in the same directory as this script (use Join-Path)
$scriptPath = Split-Path -parent $MyInvocation.MyCommand.Definition


Function Get-ShortTitle
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]$title,
		
        [Parameter(Mandatory=$false)]
        [string]$maximumCharacters = 45
    )
	
	Process
	{
		if ([string]::IsNullOrWhitespace($title))
		{
			return $title;
		}
		
		if ($title.Length -le $maximumCharacters)
		{		
			return $title;
		}
		
		$indexes = @(	0,
				$title.LastIndexOf(" ", $maximumCharacters), 
				$title.LastIndexOf(".", $maximumCharacters), 
				$title.LastIndexOf(",", $maximumCharacters)
				);
					
		$highest = ($indexes | Measure-Object -Maximum).Maximum
		return $title.Substring(0, $highest).TrimEnd(" .") + "...";
	}
}


Function Add-SchemaForBaconArticles
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]$folderId
    )

	Process
	{
		trap { break; }
		
		if ([string]::IsNullOrWhitespace($folderId))
		{
			Write-Error "You must specify the ID of the Folder where the Schema should be created."
			return;
		}
		
		$client = Get-TridionCoreServiceClient
		$readOptions = New-Object Tridion.ContentManager.CoreService.Client.ReadOptions
		
		$schema = $client.GetDefaultData(8, $folderId, $readOptions)
		$schema.Title = "Bacon Article";
		$schema.Description = "Fake articles created using the Bacon Ipsum website.";
		$schema.RootElementName = "Article";
		$schema.Xsd = (Get-Content (Join-Path $scriptPath '\Baconator-Schema.xsd'))

		return $client.Create($schema, $readOptions);
	}
}

Function Add-BaconArticles
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        [string]$folderId,
		
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]$schemaId,

        [Parameter(Mandatory=$false)]
        [int]$numberOfArticles = 5
    )

	Process
	{
		trap { break; }
		
		$url = "http://www.baconipsum.com/?paras=$numberOfArticles&type=all-meat"
		
		Write-Verbose "Fetching bacon from $url..."
		
		$content = (New-Object System.Net.WebClient).DownloadString($url)
		
		$index = $content.IndexOf('<div class="entry-content">')
		if ($index -gt 0)
		{
			$beginning = $content.Substring($index)
			$endIndex = $beginning.IndexOf("</div>");
			$entries = $beginning.Substring(0, $endIndex);
			
			$pattern = '<p>(.+?)</p>'
			$matches = $entries | Select-String -AllMatches $pattern | foreach { $_.Matches } | foreach { $_.Groups[0].Value }
			
			$readOptions = New-Object Tridion.ContentManager.CoreService.Client.ReadOptions
			
			$client = Get-TridionCoreServiceClient
			
			foreach($paragraph in $matches)
			{
				$title = Get-ShortTitle($paragraph.Substring(3))
				$timestamp = [System.DateTime]::Now.ToString("yyyy-MM-ddTHH:mm:ss")
				
				$component = $client.GetDefaultData(16, $folderId, $readOptions)
				$component.Title = $title
				$component.Schema = New-Object Tridion.ContentManager.CoreService.Client.LinkToSchemaData
				$component.Schema.IdRef = $schemaId
				$component.Content = "<Article xmlns=""urn:bacon-article""><Author>Bacon Ipsum</Author><Headline>$title</Headline><Date>$timestamp</Date><Content><div xmlns='http://www.w3.org/1999/xhtml'>$paragraph</div></Content></Article>"
				$client.Create($component, $readOptions) > $null
				Write-Verbose "Created: $title"
			}
			
			Write-Host "Bacon's ready!"
		}
		else
		{
			Write-Error "Something went wrong when retrieving the text content from Bacon Ipsum. No bacon."
		}
	}
}
```


# The Schema #
Save this XSD as 'Baconator-Schema.xsd' and put it in the same directory as the script:

```
<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="urn:bacon-article" xmlns:tcm="http://www.tridion.com/ContentManager/5.0" xmlns:tcmi="http://www.tridion.com/ContentManager/5.0/Instance" elementFormDefault="qualified" targetNamespace="urn:bacon-article">
  <xsd:import namespace="http://www.tridion.com/ContentManager/5.0/Instance" schemaLocation="cm_xml_inst.xsd"></xsd:import>
  <xsd:annotation>
    <xsd:appinfo>
      <tcm:Labels>
        <tcm:Label ElementName="Author" Metadata="false">Author</tcm:Label>
        <tcm:Label ElementName="Headline" Metadata="false">Headline</tcm:Label>
        <tcm:Label ElementName="Date" Metadata="false">Date</tcm:Label>
        <tcm:Label ElementName="Content" Metadata="false">Content</tcm:Label>
      </tcm:Labels>
    </xsd:appinfo>
  </xsd:annotation>
  <xsd:element name="Article">
    <xsd:complexType>
      <xsd:sequence>
        <xsd:element name="Author" minOccurs="1" maxOccurs="1" type="xsd:normalizedString">
          <xsd:annotation>
            <xsd:appinfo>
              <tcm:ExtensionXml/>
            </xsd:appinfo>
          </xsd:annotation>
        </xsd:element>
        <xsd:element name="Headline" minOccurs="1" maxOccurs="1" type="xsd:normalizedString">
          <xsd:annotation>
            <xsd:appinfo>
              <tcm:ExtensionXml/>
            </xsd:appinfo>
          </xsd:annotation>
        </xsd:element>
        <xsd:element name="Date" minOccurs="1" maxOccurs="1" type="xsd:dateTime">
          <xsd:annotation>
            <xsd:appinfo>
              <tcm:ExtensionXml/>
            </xsd:appinfo>
          </xsd:annotation>
        </xsd:element>
        <xsd:element name="Content" minOccurs="1" maxOccurs="1" type="tcmi:XHTML">
          <xsd:annotation>
            <xsd:appinfo>
              <tcm:ExtensionXml/>
              <tcm:Size>15</tcm:Size>
              <tcm:FilterXSLT>
                <stylesheet xmlns="http://www.w3.org/1999/XSL/Transform" version="1.0">
            <output omit-xml-declaration="yes" method="xml" cdata-section-elements="script"></output>
            <template name="FormattingFeatures">
              <FormattingFeatures xmlns="http://www.tridion.com/ContentManager/5.2/FormatArea" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
                <Doctype>Strict</Doctype>
                <AccessibilityLevel>3</AccessibilityLevel>
                <DisallowedActions>
                  <Underline></Underline>
                  <Strikethrough></Strikethrough>
                  <Subscript></Subscript>
                  <Superscript></Superscript>
                  <AlignLeft></AlignLeft>
                  <Center></Center>
                  <AlignRight></AlignRight>
                  <Font></Font>
                  <Background></Background>
                  <TableHeight></TableHeight>
                  <TableHAlign></TableHAlign>
                  <TableBackground></TableBackground>
                  <TableCellWidth></TableCellWidth>
                  <TableCellHeight></TableCellHeight>
                  <TableCellBackground></TableCellBackground>
                </DisallowedActions>
                <DisallowedStyles></DisallowedStyles>
              </FormattingFeatures>
            </template>
            <template match="/ | node() | @*">
              <copy>
                <apply-templates select="node() | @*"></apply-templates>
              </copy>
            </template>
            <template match="*[      (self::br or self::p or self::div)     and      normalize-space(translate(., &apos; &apos;, &apos;&apos;)) = &apos;&apos;     and      not(@*)     and      not(processing-instruction())     and      not(comment())     and      not(*[not(self::br) or @* or * or node()])     and      not(following::node()[not(         (self::text() or self::br or self::p or self::div)        and         normalize-space(translate(., &apos; &apos;, &apos;&apos;)) = &apos;&apos;        and         not(@*)        and         not(processing-instruction())        and         not(comment())        and         not(*[not(self::br) or @* or * or node()])       )])     ]">
              <!-- ignore all paragraphs and line-breaks at the end that have nothing but (non-breaking) spaces and line breaks -->
            </template>
            <template match="br[parent::div and not(preceding-sibling::node()) and not(following-sibling::node())]">
              <!-- Chrome generates <div><br/></div>. Renders differently in different browsers. Replace it with a non-breaking space -->
              <text> </text>
            </template>
          </stylesheet>
              </tcm:FilterXSLT>
            </xsd:appinfo>
          </xsd:annotation>
        </xsd:element>
      </xsd:sequence>
    </xsd:complexType>
  </xsd:element>
</xsd:schema>
```