
## Notes from MS course: Windows PowerShell: Foundation Skills

*	The standard powershell is just used to run scripts
    *	Ctrl+space is graphical autocomplete (show all options, properties etc)
    *	External commands - powershell passes to dos – free text comes back – can’t interrogate objects / return rich objects. Non standard names.
*	ISE is used to create scripts
    *	Ctrl+j is used to open snipets window
*	Use GetCommand to find all possible commands!
    *	After typing a command type name type dash (-) then use ctrl-space to list all possible params
    *	Use `get-command [command name] -syntax` to find out details of a command
    *	Get-command  -noun object <- finds all command for objects.
*	“Parameter sets” is the list of different overloads/signatures for the same method
*	Use shift+enter to continue on a new line, or just start with { (or backtick or empty pipe)
*	For help: `Get-Help [cmdlet name] -full`
    *	`get-help Select-Object -ShowWindow` <- open in popup
*	Get-alias to see aliases for other commands – use this to see external commands?
*	To get members
    `$ser = get-service -name bits
    _get-member_ -inputobject $ser`
    * You can pipe an output to get-member to have a look at it! `get-service bits | get-member`
    * Collections and objects seemed to be mashed together – e.g. calling get-member on a collection gives the type of the individual items rather than a collection of the types
    *	To interrogate a type do `Get-Member -inputobject ([DateTime]) -static`    <- e.g. to get static members
*	$null, $true, $false are built in vars; $error = last error?, $host. 
*	There are *-variable commands – generally don’t think you would use these to manipulate variables? Have to use new-variable with “-option constant” to get consts. Have to use set-variable to update a readonly var (!!!)
*	Single quotes is literal (‘the variable is $var’ = no change) whereas a var in double quotes is expandable (“the variable is $var” = The variable is 5)
    *	“here strings” are multiline – prefix and append @, e.g. @”this could be multi line”@
*	___Pipelines!__ They use the | to pass output from left to right
    *	Arrays are enumerated and each item is passed to the next in the chain <- I’m not sure this is quite right; they’re still collections at the next step so whatev
    *	Frequently used: Sort-object, Select-Object, group-object, measure-object, compare-object
    *	`get-process | _sort-object_ -Property id` <- sort by the Id property
    *	_select-object_ is used to pick what properties you want and limit items in a collection
    *	`get-service | _group-object_ -Property Status` <- group kind of has some magic, just mashes ungrouped fields together
    *	_measure-object_ can calculate stuff, you have to pass flags (default is count)
      `get-childitem C:\temp\ | measure-object -Property Length -average -sum -maximum`
    *	compare object will look at two collections and tell you what is unique to each (or change flags to show just differences or similarities)
      `_compare-object_ -ReferenceObject $ref -DifferenceObject $dif -IncludeEqual -ExcludeDifferent`
    *	$_ and $PSItem are the same; they are the current item in a collection (e.g. foreach-object). You can name it with -PipelineVariable MyName
    *	_ForEach-object_ aka % or ForEach
        *	Pass it a scriptblock: `Get-Eventlog -LogName Application -newest 10 | foreach-object -begin { write-host "starting"} -Process {$_.Message} -End { write-host "done!" }`
        * You can make a function; `Function DoStuff { Begin {…} Process { $_.Message …} }`
    * _Where-object_ aka ? or Where - does filtering using a script block, script block needs to return a bool. $false, %null, and 0 are false, all else are true!
        * `get-service | Where-Object {$_.name -eq "Net"}`
        *	rather than using where-object to filter try to filter using params = much faster. Get-service -name “net”
    *	-eq, -ne (not equal), -gt, -ge (greater than or equal), -lt, -le, -like, -notlike. If you want it case sensitive prefix a c. e.g. -ceq for a case sensitive equality check. 
    *	-and, -or, -xor, -not (aka !)
    *	You can access properties of items by using the property name on collections!? just do (get-process).name and it will get all names of the processes
    *	`Ranges – 1..100 | Foreach-Object { …`	<- will generate 100 ints from 1 to 100 for the pipeline
    *	Bind names params, bind positional params, bind from pipeline by values with exact type match, bind from pipeline by value with type conversions, bind from pipeline by name with exact type match, bind from pipeline by name with type conversion
        *	If you pass an object to a cmdlet and that cmdlet is expecting a named param then if the object has a property with the same name as the param then it will match up (black magic)
  *	can make output pretty using Format_list, Format_table (this is the default), Format_wide (only shows 1 property, can set how many cols)
      *	`Get-ChildItem c:\windows | Sort-Object -Property attributes | format-table -Property attributes,lastwritetime,length,name -groupby attributes`
  *	input cmdlets = Import-csv, export-csv
  *	output cmdlets, where is output going, specific paging
      *	out-default is the default for ps, which is set to out-host (write to ps host/screen)
      *	out-file [path] to send to a file, out-null will trash it
      *	out-girdview will popup a window with a grid of data, has filters and sorting etc. You can to -passthrough which will popup the window before passing it down to the next command in the pipeline so you filter and select var for next step. You could use this for a crappy kind of debugging
  *	ConvertTo/From – ConvertTo-CSV, ConvertFrom-CSV, ConvertTo-Json, ConvertFrom-Json, ConvertTo-Html
  *	Write-host will just output some text
  *	Functions! – Function [FunctionName] {}
      *	Params are declared on the first line (can have comments above): `param($svc, $computername  = "localhost" ) `
      *	You can strongly type params by `[string]$paramName = default`
  *	Script blocks. You can just put stuff in {} and it’s a script block.
      *	You can put script blocks into variables: `$what = { Get-service }`. To execute either use $what.Invoke() or Invoke-Command -scriptblock $what
  *	Variables and functions can be global, script, local, or private scope. Function global:myfunction {}
  *	Help system : use a -? Param or get-help [command]
      *	Use -examples or -full, -detailed etc to get more info. -online will launch a browser! -showwindow is a popup window
  *	Scripts
      *	They can have params same as functions. Call with `.\scriptname.ps1 -paramname valuetouse`
      *	A #requires comment can be used to put in requirements that if not met will stop the script from running e.g. `#requires -version 3` <- needs at least PSv3, or `#requires -RunAsAdministrator` <- needs to be running PS as an admin
  *	Get-ExecutionPolicy -List will show the current execution policies; drop the -list to see what is applies
  *	Modules -> powershellgallery.com. Can use Find-Module [name] (searches the gallery) and then Install-Module [name]
      *	You can manually download the module, put it in one of the module paths (view them in $env:PSModulePath) and then run install
  *	Types – by default variables are reusable across types (e.g. put a 6 in it then put “wow” in it, go crazy)
      *	You can cast by putting the type in square brackets e.g. `$total = [int]’1000’ + 100` . Every object has a GetType()
      *	Strongly type a variable by first using it with a type `[int]myVar = 1000`. Then you can’t put another type in it later.
      *	Static members are accessed using :: after the type. e.g. `[int]::MaxValue`  or `[datetime]::Today`
      *	Enums are accessed same as above `[DayOfWeek]::Friday`. Create them by `enum Seasons { Winter; Summer;Spring;Autumn; }`
          *	Have look at enum values with: `show-enum -type ([System.ConsoleColor])`
      *	Can use -is and -isnot on types e.g. `$var -is [int]` or `$var -is $otherVar.gettype()`
  *	Back tick (\`) is the escape character e.g. “\`$Home is $Home” <- outputs “$Home is [the value of $home]”
      *	\`t = tab, \`n = new line. There’s other garbage.
  *	Get-variable will get all existing variables (including predefined)

