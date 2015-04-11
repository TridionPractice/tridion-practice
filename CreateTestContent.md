
# Create Test Content #
## Introduction ##

One challenge we face when testing our templates, either manually or automatically, is that creating test components can be a lot of work. Perhaps sometimes this task would be more thoroughly done if we had a means to create test components programmatically. This recipe builds on the ChangeContentOrMetadata recipe, to provide a scripted approach to this problem.

As a cookbook recipe, this is intended to show a possible technique. It is rather unlikely that it will suit you without modification. It does not include an exhaustive implementation of all field types, and the strategies used to choose default values are perhaps naive.


## Details ##

The script is written in Powershell, and is available at https://code.google.com/p/tridion-practice/source/browse/CreateTestContent/CreateTestContent.ps1

You will need to import the modules specified in the comment at the top of the script.

You will also need [Tridion.Practice.ChangeContentOrMetadata.dll](https://code.google.com/p/tridion-practice/source/browse/CreateTestContent/Tridion.Practice.ChangeContentOrMetadata.dll) This assembly is a build from the code in the same GIT repository, so you may wish to make your own.

### Setup ###
The script will read all the schemas in the folder specified in the $systemSchemasFolderURL variable. You should modify this webdav URL to suit your own system.
Test components will be created under a folder which you will need to create. This is identified in the script by the variable $perSchemaFolderURL. Within this folder, the script will create folders matching the names of your schemas, and create components within them. The number at the end of the component name is the version of the schema upon which it is based.

In order to allow component link fields to be populated, you should also provide a target component for each schema whose components can be the target of a link. These should be in a folder which is identified in the script as $shouldResolveComponentsFolder. The components should be given the same names as their respective schemas. (It is envisaged that it will be useful to test component links which resolve, and those that don't. In this version of the script, only components which should resolve are handled, hence the name of the variable.)
