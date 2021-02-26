#This is a template for creating text based menu in Powershell
#Not yet working

using namespace System.Management.Automation.Host

function New-Menu {
    [CmdletBinding()]
    parm(
        [Paramter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Title,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Question

    )

    $red = [ChoiceDescription]::new('&Red', 'Favorite color: Red')
    $blue = [ChoiceDescription]::new('&Blue', 'Favorite color: Blue')
    $yellow = [ChoiceDescription]::new('&Yellow', 'Favorite color: Yellow')

    $options = [ChoiceDescription[]]::new($red, $blue, $yellow)

    $result = $Host.UI.PromptForChoice($Title, $Question $options, 0)

    switch ($result) {
        0 {'Your favorite color is Red' }
        1 {'Your favorite color is Blue' }
        2 {'Your favorite color is Yellow' }

    }
}
    

New-Menu -Title 'Colors' -Question 'What is your favorite color?'
