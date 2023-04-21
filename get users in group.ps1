


class UserInGroup {
    [string]$Name
    [string]$Path
}

function Get-UsersFromGroup {
    param($groupName, $pathSoFar)
    <#
    .SYNOPSIS

    Gets a list of users in a given group - will go into sub-groups

    .EXAMPLE
    
    $results  = GetUsersFromGroup [machine name]\Administrators
    will get all users in the administrators group on the local machine (or users in groups that are in the administrator group)

    .EXAMPLE
    
    $results  = GetUsersFromGroup [domain name]\Administrators
    will get all the users in the admininstrators group on the domain

    .NOTES

    Will potentially get duplicates, but this is good because it will show the different paths that users are in
    
    #>

    $users = New-Object -TypeName system.collections.ArrayList
    
    $localMachine = hostname;

    # split the domain and the name
    $domain = ""
    $position = $groupName.IndexOf("\") 
    if($position -ge 0) {  
        $domain = $groupName.Substring(0, $position)
        $groupName = $groupName.Substring($position+1)
    }

    # keep track of what group is nested in what
    $pathSoFar = "$pathSoFar\$groupName"

    # if no domain name then assume it is a group on the local machine? sure I guess ...
    if($domain -eq "" -or $domain.toLower() -ne $localMachine) {
        $members = get-ADGroupMember $groupName
    } else {
        $members = Get-LocalGroupMember -Group $groupName
    }

    foreach($member in $members) {
        #write-host "Having a look at $($member.name)"
        if($member.objectClass -eq "user") {
            #write-host("Adding member $($member.name)")
            #$users.Add("$($member.name) because of $pathSoFar") > $null
            
            $newUserInGroup = [UserInGroup]::new()
            $newUserInGroup.Name = $member.name
            $newUserInGroup.Path = $pathSoFar
            
            $users.Add( $newUserInGroup ) > $null

        } elseif ($member.objectClass -eq "group") { 
            write-host("looking at group called $($member.name)")
            # we have to use the samaccountname name rather than name, if they are different and we try to look up groups by name it will fail to find the group
            $subGroupUsers = Get-UsersFromGroup -groupName $member.SamAccountName -pathSoFar $pathSoFar
            
            # if no users in the group then null is return (which is stupid)
            if($subGroupUsers -ne $null) {
                # why is this sometimes an object and sometimes an array of objects? heck if I know
                # if the group only has one object then it is not returned as an array (stupid)
                if($subGroupUsers -is [array]) {
                    $users.AddRange($subGroupUsers);
                } else {
                    $users.Add( $subGroupUsers ) > $null
                }
            }
        } else {
            #write-host "For $member.name we got an object of type $member.objectClass and I don't know what to do with that"
        }
    }
     
    return $users
}

