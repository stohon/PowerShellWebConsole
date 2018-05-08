
add-type -Language CSharpVersion3 -TypeDefinition @"
    public class OutputToWeb { public string Name { get; set; } public string Value { get; set; } public string OutString { get; set; } }
"@

function write-out ($objectResults, $objectName) {
    if ($outputFormat -eq $null) {
        return $objectResults
    } 
    if ($outputFormat -eq "json") {
        $results = New-Object OutputToWeb
        $results.Name = $objectName
        $results.Value = ConvertTo-Json -Depth 1 $objectResults
        $results.OutString = $objectResults | Out-String
        return $results
    }
}

function write-out-all ($objectResults, $objectName) {
    write-out ($objectResults | Select-Object *) $objectName
}

function write-in ($jsonParams) {
    $jsonParamObject = ""
    if ($postData -ne $null) {
        $jsonParamObject = ConvertFrom-Json $postData
    } else {
        $jsonParamObject = ConvertFrom-Json $jsonParams
    }
    
    $jsonParamObject |
        get-member | 
        ? { $_.ToString().Split("=").Length -eq 2 } | 
        % { 
            $propertyName = $_.ToString().Split("=")[0].Split(" ")[1] 
            Remove-Variable $propertyName -Scope 1 -ErrorAction SilentlyContinue
            New-Variable -Name $propertyName -Value $jsonParamObject.$propertyName -Scope 1
        }
}