## http://www.leeholmes.com/blog/2007/06/19/invoking-generic-methods-on-non-generic-classes-in-powershell/
## Invoke-GenericMethod.ps1 

## Invoke a generic method on a non-generic type: 

## 

## Usage: 

## 

##   ## Load the DLL that contains our class

##   [Reflection.Assembly]::LoadFile(“c:\temp\GenericClass.dll”)

##

##   ## Invoke a generic method on a non-generic instance

##   $nonGenericClass = New-Object NonGenericClass

##   Invoke-GenericMethod $nonGenericClass GenericMethod String “How are you?”

##

##   ## Including one with multiple arguments

##   Invoke-GenericMethod $nonGenericClass GenericMethod String (“How are you?”,5)

##

##   ## Ivoke a generic static method on a type

##   Invoke-GenericMethod ([NonGenericClass]) GenericStaticMethod String “How are you?”

## 

param(

    $instance = $(throw “Please provide an instance on which to invoke the generic method”),

    [string] $methodName = $(throw “Please provide a method name to invoke”),

    [string[]] $typeParameters = $(throw “Please specify the type parameters”),

    [object[]] $methodParameters = $(throw “Please specify the method parameters”)

    ) 


## Determine if the types in $set1 match the types in $set2, replacing generic

## parameters in $set1 with the types in $genericTypes

function ParameterTypesMatch([type[]] $set1, [type[]] $set2, [type[]] $genericTypes)

{

    $typeReplacementIndex = 0

    $currentTypeIndex = 0


    ## Exit if the set lengths are different

    if($set1.Count -ne $set2.Count)

    {

        return $false

    }


    ## Go through each of the types in the first set

    foreach($type in $set1)

    {

        ## If it is a generic parameter, then replace it with a type from

        ## the $genericTypes list

        if($type.IsGenericParameter)

        {

            $type = $genericTypes[$typeReplacementIndex]

            $typeReplacementIndex++

        }


        ## Check that the current type (i.e.: the original type, or replacement

        ## generic type) matches the type from $set2

        if($type -ne $set2[$currentTypeIndex])

        {

            return $false

        }

        $currentTypeIndex++

    }


    return $true

}


## Convert the type parameters into actual types

[type[]] $typedParameters = $typeParameters


## Determine the type that we will call the generic method on. Initially, assume

## that it is actually a type itself.

$type = $instance


## If it is not, then it is a real object, and we can call its GetType() method

if($instance -isnot “Type”)

{

    $type = $instance.GetType()

}


## Search for the method that:

##    – has the same name

##    – is public

##    – is a generic method

##    – has the same parameter types

foreach($method in $type.GetMethods())

{

    # Write-Host $method.Name

    if(($method.Name -eq $methodName) -and

       ($method.IsPublic) -and

       ($method.IsGenericMethod))

    {

        $parameterTypes = @($method.GetParameters() | % { $_.ParameterType })

        $methodParameterTypes = @($methodParameters | % { $_.GetType() })

        if(ParameterTypesMatch $parameterTypes $methodParameterTypes $typedParameters)

        {

            ## Create a closed representation of it

            $newMethod = $method.MakeGenericMethod($typedParameters)


            ## Invoke the method

            $newMethod.Invoke($instance, $methodParameters)


            return

        }

    }

}


## Return an error if we couldn’t find that method

throw “Could not find method $methodName”
