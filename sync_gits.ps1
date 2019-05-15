# Very basic and simple script; doesn't handle conflicts between repos
$TEMP_FOLDER = "temp_folder"

$repo_lines = Get-Content -Path "repos.csv"

$temp_path = join-path -path $PSScriptRoot -childpath $TEMP_FOLDER

# For each repo:
# clone bare
# add mirror
# fetch everything from all repos
# push everywhere
foreach ($repo_line in $repo_lines) {
    $repo_list = $repo_line.Split("{,}")
    for ($i=0; $i -lt $repo_list.length; $i++) {
        if ($i -eq 0){
            Write-Host "Cloning " $repo_list[$i] -ForegroundColor Green
            git clone --bare $repo_list[$i] $temp_path
            cd $temp_path
        }
        else {
            Write-Host "Adding remote " $repo_list[$i] -ForegroundColor Green
            git remote add --mirror=fetch "repo_$i" $repo_list[$i]
        }
    }
    Write-Host "Fetching " $repo_list[0] -ForegroundColor Green
    git fetch origin --tags
    for ($i=1; $i -lt $repo_list.length; $i++) {
        Write-Host "Fetching " $repo_list[$i] -ForegroundColor Green
        git fetch "repo_$i" --tags
    }
    Write-Host "Pushing " $repo_list[0] -ForegroundColor Green
    git push origin --all
    git push origin --tags
    for ($i=1; $i -lt $repo_list.length; $i++) {
        Write-Host "Pushing " $repo_list[$i] -ForegroundColor Green
        git push  "repo_$i" --all
        git push  "repo_$i" --tags
    }

    cd $PSScriptRoot
    rm "$temp_path" -r -fo
}


